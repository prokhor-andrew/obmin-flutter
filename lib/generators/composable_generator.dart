// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:obmin/annotations/composable.dart';
import 'package:source_gen/source_gen.dart';

final class ComposableGenerator extends GeneratorForAnnotation<Composable> {
  @override
  FutureOr<String> generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError('Generator cannot target `${element.runtimeType}`.');
    }

    if (!_isSubClassOfObject(element)) {
      throw "Annotated class must not have a superclass.";
    }

    if (_isClassFinal(element)) {
      if (element.fields.isEmpty) {
        throw InvalidGenerationSourceError('Annotated final class must have stored properties.');
      } else {
        bool isValid = false;
        for (final field in element.fields) {
          if (!_isComputedProperty(field)) {
            isValid = true;
            break;
          }
        }
        if (!isValid) {
          throw InvalidGenerationSourceError('Annotated final class must have stored properties.');
        }
      }

      return _generateFinalClass(element).toString();
    } else if (_isClassSealed(element)) {
      if (element.fields.isNotEmpty) {
        throw InvalidGenerationSourceError('Annotated sealed class must not have properties.');
      }

      final cases = _findSubclasses(element);

      if (cases.isEmpty) {
        throw InvalidGenerationSourceError('Annotated sealed class must have at least one subclass.');
      }

      for (final caseE in cases) {
        if (caseE.fields.isEmpty) {
          throw InvalidGenerationSourceError('Classes that extend annotated sealed class must have properties.');
        }

        if (!_isClassFinal(caseE)) {
          throw InvalidGenerationSourceError('Classes that extend annotated sealed class must be final.');
        }
      }

      return _generateSealedClass(element, cases).toString();
    } else {
      throw "Annotated class must either be final or sealed.";
    }
  }
}

StringBuffer _generateSealedClass(ClassElement element, List<ClassElement> cases) {
  final StringBuffer buffer = StringBuffer();

  _generateSealedClassCases(buffer, element, cases);

  _generateSealedOptics(buffer, element, cases);

  return buffer;
}

void _generateSealedClassCases(StringBuffer buffer, ClassElement element, List<ClassElement> cases) {
  final className = element.displayName;
  final String generics;

  if (element.typeParameters.isEmpty) {
    generics = "";
  } else {
    final params = _dropLastChar(element.typeParameters.fold("", (acc, element) {
      return "$acc$element,";
    }));
    generics = "<$params>";
  }

  buffer.writeln("extension _${className}ObminOpticToolMethodsExtension$generics on $className$generics {");

  String foldArgs = "";
  String foldCases = "";

  String getCaseOrNoneArgs(String selectedCase) {
    String acc = "";
    for (final caseE in cases) {
      final caseName = caseE.displayName;
      if (caseName == selectedCase) {
        acc += "if$caseName: Option.some,";
      } else {
        acc += "if$caseName: (_) => Option.none(),";
      }
    }
    return acc;
  }

  for (final caseE in cases) {
    final caseName = caseE.displayName;

    foldArgs += "required R Function($caseName$generics value) if$caseName, ";

    foldCases += "$caseName$generics() => if$caseName(value),";

    buffer.writeln("");
    buffer.writeln("");

    buffer.writeln("Option<$caseName$generics> ${_lowercaseFirstCharacter(caseName)}OrNone() => fold<Option<$caseName$generics>>(${getCaseOrNoneArgs(caseName)});");

    buffer.writeln("");
    buffer.writeln("");
  }

  buffer.writeln("");
  buffer.writeln("");

  buffer.writeln("R fold<R>({$foldArgs}) {");
  buffer.writeln("final value = this;");
  buffer.writeln("return switch (value) {");
  buffer.writeln(foldCases);
  buffer.writeln("};");
  buffer.writeln("}");

  buffer.writeln("}");

  for (final caseE in cases) {
    final caseName = caseE.displayName;

    buffer.writeln("extension ${caseName}ObminPathArrowExtension<Whole${generics.isEmpty ? "" : ",${_dropFirstChar(_dropLastChar(generics))}"}> on PathArrow<String, Whole, $caseName$generics> "
        "{");

    for (final field in caseE.fields) {
      if (!_isComputedProperty(field)) {
        buffer.writeln("");

        final fieldName = field.displayName;
        final fieldType = field.type;

        buffer.writeln('  PathArrow<String, Whole, $fieldType> $fieldName() => then(PathArrow.fromRun((val) => Path.fromKeyValue("$fieldName", val.$fieldName)));');
      }
    }

    buffer.writeln('}');

    // option arrow
    buffer.writeln("extension ${caseName}ObminOptionArrowExtension<Whole${generics.isEmpty ? "" : ",${_dropFirstChar(_dropLastChar(generics))}"}> on OptionArrow<Whole, $caseName$generics> "
        "{");

    for (final field in caseE.fields) {
      if (!_isComputedProperty(field)) {
        buffer.writeln("");

        final fieldName = field.displayName;
        final fieldType = field.type;

        buffer.writeln('  OptionArrow<Whole, $fieldType> $fieldName() => then(OptionArrow.fromRun((val) => Option.some(val.$fieldName)));');
      }
    }

    buffer.writeln('}');

    String constructObject(String modified) {
      String result = "$caseName(";
      if (caseE.fields.isNotEmpty) {
        for (final field in caseE.fields) {
          if (!_isComputedProperty(field)) {
            result += "${field.displayName == modified ? "function(${field.displayName})" : field.displayName},";
          }
        }
      }

      result += ");";

      return result;
    }

    buffer.writeln("extension _${caseName}UtilsExtension$generics on $caseName$generics {");

    buffer.writeln("");

    for (final field in caseE.fields) {
      if (!_isComputedProperty(field)) {
        final String fieldName = field.displayName;
        final fieldType = field.type;

        buffer.writeln("    $caseName$generics copyUpdate${_uppercaseFirstCharacter(fieldName)}($fieldType Function($fieldType $fieldName) function) {");
        buffer.writeln("        return ${constructObject(fieldName)}");
        buffer.writeln("    }");
        buffer.writeln("");

        buffer.writeln("    $caseName$generics copySet${_uppercaseFirstCharacter(fieldName)}($fieldType $fieldName) {");
        buffer.writeln("        return copyUpdate${_uppercaseFirstCharacter(fieldName)}((_) => $fieldName);");
        buffer.writeln("    }");
        buffer.writeln("");
      }
    }

    buffer.writeln('}');

    buffer.writeln("extension ${caseName}ObminOpticExtension<Whole${generics.isEmpty ? "" : ",${_dropFirstChar(_dropLastChar(generics))}"}> on Optic<Whole, $caseName$generics> {");

    for (final field in caseE.fields) {
      if (!_isComputedProperty(field)) {
        buffer.writeln("");

        final fieldName = field.displayName;
        final fieldType = field.type;

        buffer.writeln("  Optic<Whole, $fieldType> $fieldName() => then(");
        buffer.writeln("    Optic.lens<$caseName$generics, $fieldType>(");
        buffer.writeln("      (whole) => whole.$fieldName,");
        buffer.writeln("      (whole) => (part) => whole.copySet${_uppercaseFirstCharacter(fieldName)}(part),");
        buffer.writeln("    ),");
        buffer.writeln("  );");
      }
    }

    buffer.writeln('}');
  }
}

void _generateSealedOptics(StringBuffer buffer, ClassElement element, List<ClassElement> cases) {
  final String className = element.displayName;

  final String generics;

  if (element.typeParameters.isEmpty) {
    generics = "";
  } else {
    final params = _dropLastChar(element.typeParameters.fold("", (acc, element) {
      return "$acc$element,";
    }));
    generics = "<$params>";
  }

  buffer.writeln("extension ${className}ObminPathArrowExtension<Whole${generics.isEmpty ? "" : ",${_dropFirstChar(_dropLastChar(generics))}"}> on PathArrow<String, Whole, "
      "$className$generics> {");

  for (final caseE in cases) {
    final caseName = caseE.displayName;

    buffer.writeln("");

    buffer.writeln(
        "PathArrow<String, Whole, $caseName$generics> ${_lowercaseFirstCharacter(caseName)}() => then(PathArrow.fromRun((val) => val.${_lowercaseFirstCharacter(caseName)}OrNone().match(() => "
            "Path.empty(), "
        "(value) => Path.fromKeyValue(\"${caseName}\", value))));");
  }

  buffer.writeln('}');

  buffer.writeln("");
  buffer.writeln("");

  buffer.writeln("extension ${className}ObminOptionArrowExtension<Whole${generics.isEmpty ? "" : ",${_dropFirstChar(_dropLastChar(generics))}"}> on OptionArrow<Whole, "
      "$className$generics> {");

  for (final caseE in cases) {
    final caseName = caseE.displayName;

    buffer.writeln("");

    buffer.writeln(
        "OptionArrow<Whole, $caseName$generics> ${_lowercaseFirstCharacter(caseName)}() => then(OptionArrow.fromRun((val) => val.${_lowercaseFirstCharacter(caseName)}OrNone().match(() => Option"
            ".none(), "
            "(value) => Option.some(value) )));");
  }

  buffer.writeln('}');

  buffer.writeln("");
  buffer.writeln("");

  buffer.writeln("extension ${className}ObminOpticExtension<Whole${generics.isEmpty ? "" : ",${_dropFirstChar(_dropLastChar(generics))}"}> on Optic<Whole, $className$generics> {");

  for (final caseE in cases) {
    final caseName = caseE.displayName;

    buffer.writeln("  Optic<Whole, $caseName$generics> ${_lowercaseFirstCharacter(caseName)}() => then(");
    buffer.writeln("    Optic.prism<$className$generics, $caseName$generics>(");
    buffer.writeln("      (whole) => whole.${_lowercaseFirstCharacter(caseName)}OrNone(),");
    buffer.writeln("      (part) => part,");
    buffer.writeln("    ),");
    buffer.writeln("  );");
  }

  buffer.writeln('}');

  buffer.writeln("");
  buffer.writeln("");
}

StringBuffer _generateFinalClass(ClassElement element) {
  final StringBuffer buffer = StringBuffer();

  // Generate read only optics for fold
  _generateForPathArrow(buffer, element);

  // Generate mutator optics
  _generateForOptic(buffer, element);

  return buffer;
}

String _lowercaseFirstCharacter(String input) {
  if (input.isEmpty) return input;
  return input[0].toLowerCase() + input.substring(1);
}

String _uppercaseFirstCharacter(String input) {
  if (input.isEmpty) return input;

  return input[0].toUpperCase() + input.substring(1);
}

void _generateForPathArrow(StringBuffer buffer, ClassElement element) {
  final String className = element.displayName;

  final String generics;

  if (element.typeParameters.isEmpty) {
    generics = "";
  } else {
    final params = _dropLastChar(element.typeParameters.fold("", (acc, element) {
      return "$acc$element,";
    }));
    generics = "<$params>";
  }

  buffer.writeln("extension ${className}PathArrowExtension<Whole${generics.isEmpty ? "" : ",${_dropFirstChar(_dropLastChar(generics))}"}> on PathArrow<String, Whole, "
      "$className$generics> "
      "{");

  for (final field in element.fields) {
    if (!_isComputedProperty(field)) {
      buffer.writeln("");

      final fieldName = field.displayName;
      final fieldType = field.type;

      buffer.writeln('  PathArrow<String, Whole, $fieldType> $fieldName() => then(PathArrow.fromRun((val) => Path.fromKeyValue ("$fieldName", val.$fieldName)));');
    }
  }

  buffer.writeln('}');

  buffer.writeln("extension ${className}OptionArrowExtension<Whole${generics.isEmpty ? "" : ",${_dropFirstChar(_dropLastChar(generics))}"}> on OptionArrow<Whole, "
      "$className$generics> "
      "{");

  for (final field in element.fields) {
    if (!_isComputedProperty(field)) {
      buffer.writeln("");

      final fieldName = field.displayName;
      final fieldType = field.type;

      buffer.writeln('  OptionArrow<Whole, $fieldType> $fieldName() => then(OptionArrow.fromRun((val) => Option.some(val.$fieldName)));');
    }
  }

  buffer.writeln('}');
}

void _generateForOptic(StringBuffer buffer, ClassElement element) {
  final String className = element.displayName;

  final String generics;

  if (element.typeParameters.isEmpty) {
    generics = "";
  } else {
    final params = _dropLastChar(element.typeParameters.fold("", (acc, element) {
      return "$acc$element,";
    }));
    generics = "<$params>";
  }

  String constructObject(String modified) {
    String result = "$className(";
    if (element.fields.isNotEmpty) {
      for (final field in element.fields) {
        if (!_isComputedProperty(field)) {
          result += "${field.displayName == modified ? "function(${field.displayName})" : field.displayName},";
        }
      }
    }

    result += ");";

    return result;
  }

  buffer.writeln("extension _${className}UtilsExtension$generics on $className$generics {");

  buffer.writeln("");

  for (final field in element.fields) {
    if (!_isComputedProperty(field)) {
      final String fieldName = field.displayName;
      final fieldType = field.type;

      buffer.writeln("    $className$generics copyUpdate${_uppercaseFirstCharacter(fieldName)}($fieldType Function($fieldType $fieldName) function) {");
      buffer.writeln("        return ${constructObject(fieldName)}");
      buffer.writeln("    }");
      buffer.writeln("");

      buffer.writeln("    $className$generics copySet${_uppercaseFirstCharacter(fieldName)}($fieldType $fieldName) {");
      buffer.writeln("        return copyUpdate${_uppercaseFirstCharacter(fieldName)}((_) => $fieldName);");
      buffer.writeln("    }");
      buffer.writeln("");
    }
  }

  buffer.writeln('}');

  buffer.writeln("extension ${className}ObminOpticExtension<Whole${generics.isEmpty ? "" : ",${_dropFirstChar(_dropLastChar(generics))}"}> on Optic<Whole, $className$generics> {");

  for (final field in element.fields) {
    if (!_isComputedProperty(field)) {
      buffer.writeln("");

      final fieldName = field.displayName;
      final fieldType = field.type;

      buffer.writeln("  Optic<Whole, $fieldType> $fieldName() => then(");
      buffer.writeln("    Optic.lens<$className$generics, $fieldType>(");
      buffer.writeln("      (whole) => whole.$fieldName,");
      buffer.writeln("      (whole) => (part) => whole.copySet${_uppercaseFirstCharacter(fieldName)}(part),");
      buffer.writeln("    ),");
      buffer.writeln("  );");
    }
  }

  buffer.writeln('}');
}

bool _isClassFinal(ClassElement element) {
  return element.toString().substring(0, 11).contains("final class");
}

bool _isSubClassOfObject(ClassElement element) {
  final supertype = element.supertype;

  if (supertype == null) {
    return false;
  }

  return supertype.isDartCoreObject;
}

String _dropLastChar(String input) {
  if (input.isEmpty) {
    return input;
  }
  return input.substring(0, input.length - 1);
}

String _dropFirstChar(String input) {
  if (input.isEmpty) {
    return input;
  }
  return input.substring(1, input.length);
}

bool _isClassSealed(ClassElement classElement) {
  return classElement.toString().substring(0, 12).contains("sealed class");
}

List<ClassElement> _findSubclasses(ClassElement sealedClass) {
  bool isDirectSubclassOf(ClassElement subclass, ClassElement superclass) {
    return subclass.supertype?.element == superclass;
  }

  final subclasses = <ClassElement>[];

  // Traverse all elements in the library to find direct subclasses
  final library = sealedClass.library;
  for (final element in library.classes) {
    if (element != sealedClass) {
      if (isDirectSubclassOf(element, sealedClass)) {
        subclasses.add(element);
      }
    }
  }

  return subclasses;
}

bool _isComputedProperty(FieldElement field) {
  return field.getter != null && field.setter == null && !field.isFinal;
}
