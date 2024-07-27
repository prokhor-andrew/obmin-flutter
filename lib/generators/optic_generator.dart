// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:obmin/annotations/optic.dart';
import 'package:source_gen/source_gen.dart';


class OpticGenerator extends GeneratorForAnnotation<Optic> {
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
        throw InvalidGenerationSourceError('Annotated final class must have properties.');
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

  _generateSealedMapMethods(buffer, element, cases);

  _generateSealedOptics(buffer, element, cases);

  return buffer;
}

void _generateSealedClassCases(StringBuffer buffer, ClassElement element, List<ClassElement> cases) {
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

  for (final caseE in cases) {
    final caseName = caseE.displayName;

    buffer.writeln("extension Optic${caseName}UtilsExtension$generics on $className$generics {");

    String arguments = "";
    String compares = "";
    String hashes = "";

    for (final field in caseE.fields) {
      final type = field.type;
      final name = field.displayName;

      final bool isAnyIterableSubclass = type.isDartCoreIterable;

      arguments += " $name=\$$name,";
      compares += "&& ${isAnyIterableSubclass ? "const IterableEquality().equals(other.$name, $name)" : "other.$name == $name"}";
      hashes += "${isAnyIterableSubclass ? "const IterableEquality().hash($name)" : name},";
    }


    buffer.writeln("  String _toString() {");
    buffer.writeln("    return \"$caseName${caseE.typeParameters.isEmpty ? "" : "<${_dropLastChar(caseE.typeParameters.fold("", (acc, element) {
        return "$acc\$$element,";
      }))}>"} {${_dropLastChar(arguments)} }\";");
    buffer.writeln("  }");

    buffer.writeln("");
    buffer.writeln("");

    buffer.writeln("  // you need \"collection:\" package if you want to use Iterable in your class");
    buffer.writeln("  bool _equals(Object other) {");
    buffer.writeln("    if (identical(this, other)) return true;");
    buffer.writeln("    return other is $caseName$generics");
    buffer.writeln("    $compares;");
    buffer.writeln("  }");

    buffer.writeln("");
    buffer.writeln("");

    buffer.writeln("  int get _hashCode => Object.hashAll([");
    buffer.writeln("    $hashes");
    buffer.writeln("  ]);");

    buffer.writeln("");
    buffer.writeln("");

    buffer.writeln("}");

    String constructObject(String modified) {
      String result = "$caseName(";
      if (caseE.fields.isNotEmpty) {
        for (final field in caseE.fields) {
          result += "${field.displayName}: ${field.displayName == modified ? "function(${field.displayName})" : field.displayName},";
        }
      }

      result += ");";

      return result;
    }

    buffer.writeln("extension ${caseName}ObminOpticToolMethodsExtension$generics on $caseName$generics {");

    buffer.writeln("");

    for (final field in caseE.fields) {
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

    buffer.writeln("");

    buffer.writeln("    R fold<R>(R Function($caseName$generics) function,) {");
    buffer.writeln("        return function(this);");
    buffer.writeln("    }");

    buffer.writeln("");

    buffer.writeln('}');

    buffer.writeln("extension ${caseName}ObminOpticEqvExtension$generics on Eqv<$caseName$generics> {");

    for (final field in caseE.fields) {
      buffer.writeln("");

      final fieldName = field.displayName;
      final fieldType = field.type;

      buffer.writeln('  Getter<$caseName$generics, $fieldType> get $fieldName => asGetter().$fieldName;');
    }

    buffer.writeln('}');

    buffer.writeln(
        "extension ${caseName}ObminOpticGetterExtension<Whole${generics.isEmpty ? "" : ",${_dropFirstChar(_dropLastChar(generics))}"}> on Getter<Whole, $caseName$generics> {");

    for (final field in caseE.fields) {
      buffer.writeln("");

      final fieldName = field.displayName;
      final fieldType = field.type;

      buffer.writeln('  Getter<Whole, $fieldType> get $fieldName => compose(Getter<$caseName$generics, $fieldType>((whole) => whole.$fieldName));');
    }

    buffer.writeln('}');

    buffer.writeln(
        "extension ${caseName}ObminOpticPreviewExtension<Whole${generics.isEmpty ? "" : ",${_dropFirstChar(_dropLastChar(generics))}"}> on Preview<Whole, $caseName$generics> {");

    for (final field in caseE.fields) {
      buffer.writeln("");

      final fieldName = field.displayName;
      final fieldType = field.type;

      buffer.writeln('  Preview<Whole, $fieldType> get $fieldName => composeWithGetter(Getter<$caseName$generics, $fieldType>((whole) => whole.$fieldName));');
    }

    buffer.writeln('}');

    buffer.writeln(
        "extension ${caseName}ObminOpticFoldExtension<Whole${generics.isEmpty ? "" : ",${_dropFirstChar(_dropLastChar(generics))}"}> on Fold<Whole, $caseName$generics> {");

    for (final field in caseE.fields) {
      buffer.writeln("");

      final fieldName = field.displayName;
      final fieldType = field.type;

      buffer.writeln('  Fold<Whole, $fieldType> get $fieldName => composeWithGetter(Getter<$caseName$generics, $fieldType>((whole) => whole.$fieldName));');
    }

    buffer.writeln('}');

    buffer.writeln(
        "extension ${caseName}ObminOpticMutatorExtension<Whole${generics.isEmpty ? "" : ",${_dropFirstChar(_dropLastChar(generics))}"}> on Mutator<Whole, $caseName$generics> {");

    for (final field in caseE.fields) {
      buffer.writeln("");

      final fieldName = field.displayName;
      final fieldType = field.type;

      buffer.writeln("  Mutator<Whole, $fieldType> get $fieldName => compose(");
      buffer.writeln("    Mutator.lens<$caseName$generics, $fieldType>(");
      buffer.writeln("      Getter<$caseName$generics, $fieldType>((whole) => whole.$fieldName),");
      buffer.writeln("      (whole, part) => whole.copySet${_uppercaseFirstCharacter(fieldName)}(part),");
      buffer.writeln("    ),");
      buffer.writeln("  );");
    }

    buffer.writeln('}');

    buffer.writeln(
        "extension ${caseName}ObminOpticIsoExtension<Whole${generics.isEmpty ? "" : ",${_dropFirstChar(_dropLastChar(generics))}"}> on Iso<Whole, $caseName$generics> {");

    for (final field in caseE.fields) {
      buffer.writeln("");

      final fieldName = field.displayName;
      final fieldType = field.type;

      buffer.writeln("  Mutator<Whole, $fieldType> get $fieldName => asMutator().compose(");
      buffer.writeln("    Mutator.lens<$caseName$generics, $fieldType>(");
      buffer.writeln("      Getter<$caseName$generics, $fieldType>((whole) => whole.$fieldName),");
      buffer.writeln("      (whole, part) => whole.copySet${_uppercaseFirstCharacter(fieldName)}(part),");
      buffer.writeln("    ),");
      buffer.writeln("  );");
    }

    buffer.writeln('}');

    buffer.writeln(
        "extension ${caseName}ObminOpticPrismExtension<Whole${generics.isEmpty ? "" : ",${_dropFirstChar(_dropLastChar(generics))}"}> on Prism<Whole, $caseName$generics> {");

    for (final field in caseE.fields) {
      buffer.writeln("");

      final fieldName = field.displayName;
      final fieldType = field.type;

      buffer.writeln("  Mutator<Whole, $fieldType> get $fieldName => asMutator().compose(");
      buffer.writeln("    Mutator.lens<$caseName$generics, $fieldType>(");
      buffer.writeln("      Getter<$caseName$generics, $fieldType>((whole) => whole.$fieldName),");
      buffer.writeln("      (whole, part) => whole.copySet${_uppercaseFirstCharacter(fieldName)}(part),");
      buffer.writeln("    ),");
      buffer.writeln("  );");
    }

    buffer.writeln('}');

    buffer.writeln(
        "extension ${caseName}ObminOpticReflectorExtension<Whole${generics.isEmpty ? "" : ",${_dropFirstChar(_dropLastChar(generics))}"}> on Reflector<Whole, $caseName$generics> {");

    for (final field in caseE.fields) {
      buffer.writeln("");

      final fieldName = field.displayName;
      final fieldType = field.type;

      buffer.writeln("  Mutator<Whole, $fieldType> get $fieldName => asMutator().compose(");
      buffer.writeln("    Mutator.lens<$caseName$generics, $fieldType>(");
      buffer.writeln("      Getter<$caseName$generics, $fieldType>((whole) => whole.$fieldName),");
      buffer.writeln("      (whole, part) => whole.copySet${_uppercaseFirstCharacter(fieldName)}(part),");
      buffer.writeln("    ),");
      buffer.writeln("  );");
    }

    buffer.writeln('}');

    buffer.writeln(
        "extension ${caseName}ObminOpticBiPreviewExtension<Whole${generics.isEmpty ? "" : ",${_dropFirstChar(_dropLastChar(generics))}"}> on BiPreview<Whole, $caseName$generics> {");

    for (final field in caseE.fields) {
      buffer.writeln("");

      final fieldName = field.displayName;
      final fieldType = field.type;

      buffer.writeln("  Mutator<Whole, $fieldType> get $fieldName => asMutator().compose(");
      buffer.writeln("    Mutator.lens<$caseName$generics, $fieldType>(");
      buffer.writeln("      Getter<$caseName$generics, $fieldType>((whole) => whole.$fieldName),");
      buffer.writeln("      (whole, part) => whole.copySet${_uppercaseFirstCharacter(fieldName)}(part),");
      buffer.writeln("    ),");
      buffer.writeln("  );");
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

  buffer.writeln("extension ${className}ObminOpticEqvExtension$generics on Eqv<$className$generics> {");

  for (final caseE in cases) {
    final caseName = caseE.displayName;

    buffer.writeln("");

    buffer.writeln(
        "Preview<$className$generics, $caseName$generics> get ${_lowercaseFirstCharacter(caseName)} => Preview<$className$generics, $caseName$generics>((whole) => whole.${_lowercaseFirstCharacter(caseName)}OrNone);");
  }

  buffer.writeln('}');

  buffer.writeln("");
  buffer.writeln("");

  buffer.writeln(
      "extension ${className}ObminOpticGetterExtension<Whole${generics.isEmpty ? "" : ",${_dropFirstChar(_dropLastChar(generics))}"}> on Getter<Whole, $className$generics> {");

  for (final caseE in cases) {
    final caseName = caseE.displayName;

    buffer.writeln("");

    buffer.writeln(
        "Preview<Whole, $caseName$generics> get ${_lowercaseFirstCharacter(caseName)} => composeWithPreview(Preview<$className$generics, $caseName$generics>((whole) => whole.${_lowercaseFirstCharacter(caseName)}OrNone));");
  }

  buffer.writeln('}');

  buffer.writeln("");
  buffer.writeln("");

  buffer.writeln(
      "extension ${className}ObminOpticPreviewExtension<Whole${generics.isEmpty ? "" : ",${_dropFirstChar(_dropLastChar(generics))}"}> on Preview<Whole, $className$generics> {");

  for (final caseE in cases) {
    final caseName = caseE.displayName;

    buffer.writeln("");

    buffer.writeln(
        "Preview<Whole, $caseName$generics> get ${_lowercaseFirstCharacter(caseName)} => compose(Preview<$className$generics, $caseName$generics>((whole) => whole.${_lowercaseFirstCharacter(caseName)}OrNone));");
  }

  buffer.writeln('}');

  buffer.writeln("");
  buffer.writeln("");

  buffer.writeln(
      "extension ${className}ObminOpticFoldExtension<Whole${generics.isEmpty ? "" : ",${_dropFirstChar(_dropLastChar(generics))}"}> on Fold<Whole, $className$generics> {");

  for (final caseE in cases) {
    final caseName = caseE.displayName;

    buffer.writeln("");

    buffer.writeln(
        "Fold<Whole, $caseName$generics> get ${_lowercaseFirstCharacter(caseName)} => composeWithPreview(Preview<$className$generics, $caseName$generics>((whole) => whole.${_lowercaseFirstCharacter(caseName)}OrNone));");
  }

  buffer.writeln('}');

  buffer.writeln("");
  buffer.writeln("");

  buffer.writeln(
      "extension ${className}ObminOpticMutatorExtension<Whole${generics.isEmpty ? "" : ",${_dropFirstChar(_dropLastChar(generics))}"}> on Mutator<Whole, $className$generics> {");

  for (final caseE in cases) {
    final caseName = caseE.displayName;

    buffer.writeln("  Mutator<Whole, $caseName$generics> get ${_lowercaseFirstCharacter(caseName)} => composeWithPrism(");
    buffer.writeln("    Prism<$className$generics, $caseName$generics>(");
    buffer.writeln("      Preview<$className$generics, $caseName$generics>((whole) => whole.${_lowercaseFirstCharacter(caseName)}OrNone),");
    buffer.writeln("      Getter<$caseName$generics, $className$generics>((part) => part),");
    buffer.writeln("    ),");
    buffer.writeln("  );");
  }

  buffer.writeln('}');

  buffer.writeln("");
  buffer.writeln("");

  buffer.writeln(
      "extension ${className}ObminOpticIsoExtension<Whole${generics.isEmpty ? "" : ",${_dropFirstChar(_dropLastChar(generics))}"}> on Iso<Whole, $className$generics> {");

  for (final caseE in cases) {
    final caseName = caseE.displayName;

    buffer.writeln("  Prism<Whole, $caseName$generics> get ${_lowercaseFirstCharacter(caseName)} => composeWithPrism(");
    buffer.writeln("    Prism<$className$generics, $caseName$generics>(");
    buffer.writeln("      Preview<$className$generics, $caseName$generics>((whole) => whole.${_lowercaseFirstCharacter(caseName)}OrNone),");
    buffer.writeln("      Getter<$caseName$generics, $className$generics>((part) => part),");
    buffer.writeln("    ),");
    buffer.writeln("  );");
  }

  buffer.writeln('}');

  buffer.writeln("");
  buffer.writeln("");

  buffer.writeln(
      "extension ${className}ObminOpticPrismExtension<Whole${generics.isEmpty ? "" : ",${_dropFirstChar(_dropLastChar(generics))}"}> on Prism<Whole, $className$generics> {");

  for (final caseE in cases) {
    final caseName = caseE.displayName;

    buffer.writeln("  Prism<Whole, $caseName$generics> get ${_lowercaseFirstCharacter(caseName)} => compose(");
    buffer.writeln("    Prism<$className$generics, $caseName$generics>(");
    buffer.writeln("      Preview<$className$generics, $caseName$generics>((whole) => whole.${_lowercaseFirstCharacter(caseName)}OrNone),");
    buffer.writeln("      Getter<$caseName$generics, $className$generics>((part) => part),");
    buffer.writeln("    ),");
    buffer.writeln("  );");
  }

  buffer.writeln('}');

  buffer.writeln("");
  buffer.writeln("");

  buffer.writeln(
      "extension ${className}ObminOpticReflectorExtension<Whole${generics.isEmpty ? "" : ",${_dropFirstChar(_dropLastChar(generics))}"}> on Reflector<Whole, $className$generics> {");

  for (final caseE in cases) {
    final caseName = caseE.displayName;

    buffer.writeln("  BiPreview<Whole, $caseName$generics> get ${_lowercaseFirstCharacter(caseName)} => composeWithPrism(");
    buffer.writeln("    Prism<$className$generics, $caseName$generics>(");
    buffer.writeln("      Preview<$className$generics, $caseName$generics>((whole) => whole.${_lowercaseFirstCharacter(caseName)}OrNone),");
    buffer.writeln("      Getter<$caseName$generics, $className$generics>((part) => part),");
    buffer.writeln("    ),");
    buffer.writeln("  );");
  }

  buffer.writeln('}');

  buffer.writeln("");
  buffer.writeln("");

  buffer.writeln(
      "extension ${className}ObminOpticBiPreviewExtension<Whole${generics.isEmpty ? "" : ",${_dropFirstChar(_dropLastChar(generics))}"}> on BiPreview<Whole, $className$generics> {");

  for (final caseE in cases) {
    final caseName = caseE.displayName;

    buffer.writeln("  BiPreview<Whole, $caseName$generics> get ${_lowercaseFirstCharacter(caseName)} => composeWithPrism(");
    buffer.writeln("    Prism<$className$generics, $caseName$generics>(");
    buffer.writeln("      Preview<$className$generics, $caseName$generics>((whole) => whole.${_lowercaseFirstCharacter(caseName)}OrNone),");
    buffer.writeln("      Getter<$caseName$generics, $className$generics>((part) => part),");
    buffer.writeln("    ),");
    buffer.writeln("  );");
  }

  buffer.writeln('}');
}


void _generateSealedMapMethods(StringBuffer buffer, ClassElement element, List<ClassElement> cases) {
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

  buffer.writeln("extension ${className}ObminOpticToolMethodsExtension$generics on $className$generics {");

  String foldArgs = "";
  String foldCases = "";

  String getMapArgs(String selectedCase) {
    String acc = "";
    for (final caseE in cases) {
      final caseName = caseE.displayName;
      if (caseName == selectedCase) {
        acc += "if$caseName: function,";
      } else {
        acc += "if$caseName: (val) => val,";
      }
    }
    return acc;
  }

  String getCaseOrNoneArgs(String selectedCase) {
    String acc = "";
    for (final caseE in cases) {
      final caseName = caseE.displayName;
      if (caseName == selectedCase) {
        acc += "if$caseName: Some.new,";
      } else {
        acc += "if$caseName: (_) => const None(),";
      }
    }
    return acc;
  }

  String getCaseExecuteArgs(String selectedCase) {
    String acc = "";
    for (final caseE in cases) {
      final caseName = caseE.displayName;
      if (caseName == selectedCase) {
        acc += "if$caseName: (value) => () => function(value),";
      } else {
        acc += "if$caseName: (_) => () {},";
      }
    }
    return acc;
  }

  String getIsCaseBoolArgs(String selectedCase) {
    String acc = "";
    for (final caseE in cases) {
      final caseName = caseE.displayName;
      if (caseName == selectedCase) {
        acc += "if$caseName: (_) => true,";
      } else {
        acc += "if$caseName: (_) => false,";
      }
    }
    return acc;
  }

  for (final caseE in cases) {
    final caseName = caseE.displayName;

    foldArgs += "required R Function($caseName$generics value) if$caseName, ";

    foldCases += "$caseName$generics() => if$caseName(value),";

    buffer.writeln("$className$generics map$caseName($caseName$generics Function($caseName$generics value) function) {");
    buffer.writeln("return fold<$className$generics>(${getMapArgs(caseName)});");
    buffer.writeln("}");

    buffer.writeln("");
    buffer.writeln("");

    buffer.writeln("$className$generics map${caseName}To($caseName$generics value) {");
    buffer.writeln("return map$caseName((_) => value);");
    buffer.writeln("}");

    buffer.writeln("");
    buffer.writeln("");

    buffer.writeln("$className$generics bind$caseName($className$generics Function($caseName$generics value) function) {");
    buffer.writeln("return fold<$className$generics>(${getMapArgs(caseName)});");
    buffer.writeln("}");

    buffer.writeln("");
    buffer.writeln("");

    buffer.writeln(
        "Optional<$caseName$generics> get ${_lowercaseFirstCharacter(caseName)}OrNone => fold<Optional<$caseName$generics>>(${getCaseOrNoneArgs(caseName)});");

    buffer.writeln("");
    buffer.writeln("");

    buffer.writeln("void executeIf$caseName(void Function($caseName$generics value) function) {");
    buffer.writeln("fold<void Function()>(${getCaseExecuteArgs(caseName)})();");
    buffer.writeln("}");

    buffer.writeln("");
    buffer.writeln("");

    buffer.writeln("bool get is$caseName => fold<bool>(${getIsCaseBoolArgs(caseName)});");

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
}

StringBuffer _generateFinalClass(ClassElement element) {
  final StringBuffer buffer = StringBuffer();
  // generate plain old dart object
  _generateFinalPODO(buffer, element);

  // Generate map methods
  _generateFinalMapMethods(buffer, element);

  // Generate read only optics for eqv
  _generateForEqv(buffer, element);

  // Generate read only optics for getter
  _generateForGetter(buffer, element);

  // Generate read only optics for preview
  _generateForPreview(buffer, element);

  // Generate read only optics for fold
  _generateForFold(buffer, element);

  // Generate mutator optics
  _generateForMutator(buffer, element);

  return buffer;
}

String _lowercaseFirstCharacter(String input) {
  if (input.isEmpty) return input;
  return input[0].toLowerCase() + input;
}

String _uppercaseFirstCharacter(String input) {
  if (input.isEmpty) return input;

  return input[0].toUpperCase() + input;
}

void _generateForEqv(StringBuffer buffer, ClassElement element) {
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

  buffer.writeln("extension ${className}ObminOpticEqvExtension$generics on Eqv<$className$generics> {");

  for (final field in element.fields) {
    buffer.writeln("");

    final fieldName = field.displayName;
    final fieldType = field.type;

    buffer.writeln('  Getter<$className$generics, $fieldType> get $fieldName => asGetter().$fieldName;');
  }

  buffer.writeln('}');
}

void _generateForGetter(StringBuffer buffer, ClassElement element) {
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

  buffer.writeln(
      "extension ${className}ObminOpticGetterExtension<Whole${generics.isEmpty ? "" : ",${_dropFirstChar(_dropLastChar(generics))}"}> on Getter<Whole, $className$generics> {");

  for (final field in element.fields) {
    buffer.writeln("");

    final fieldName = field.displayName;
    final fieldType = field.type;

    buffer.writeln('  Getter<Whole, $fieldType> get $fieldName => compose(Getter<$className$generics, $fieldType>((whole) => whole.$fieldName));');
  }

  buffer.writeln('}');
}

void _generateForPreview(StringBuffer buffer, ClassElement element) {
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

  buffer.writeln(
      "extension ${className}ObminOpticPreviewExtension<Whole${generics.isEmpty ? "" : ",${_dropFirstChar(_dropLastChar(generics))}"}> on Preview<Whole, $className$generics> {");

  for (final field in element.fields) {
    buffer.writeln("");

    final fieldName = field.displayName;
    final fieldType = field.type;

    buffer.writeln('  Preview<Whole, $fieldType> get $fieldName => composeWithGetter(Getter<$className$generics, $fieldType>((whole) => whole.$fieldName));');
  }

  buffer.writeln('}');
}

void _generateForFold(StringBuffer buffer, ClassElement element) {
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

  buffer.writeln(
      "extension ${className}ObminOpticFoldExtension<Whole${generics.isEmpty ? "" : ",${_dropFirstChar(_dropLastChar(generics))}"}> on Fold<Whole, $className$generics> {");

  for (final field in element.fields) {
    buffer.writeln("");

    final fieldName = field.displayName;
    final fieldType = field.type;

    buffer.writeln('  Fold<Whole, $fieldType> get $fieldName => composeWithGetter(Getter<$className$generics, $fieldType>((whole) => whole.$fieldName));');
  }

  buffer.writeln('}');
}

void _generateFinalMapMethods(StringBuffer buffer, ClassElement element) {
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
        result += "${field.displayName}: ${field.displayName == modified ? "function(${field.displayName})" : field.displayName},";
      }
    }

    result += ");";

    return result;
  }

  buffer.writeln("extension ${className}ObminOpticToolMethodsExtension$generics on $className$generics {");

  buffer.writeln("");

  for (final field in element.fields) {
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

  buffer.writeln("");

  buffer.writeln("    R fold<R>(R Function($className$generics) function,) {");
  buffer.writeln("        return function(this);");
  buffer.writeln("    }");

  buffer.writeln("");

  buffer.writeln('}');
}

void _generateForMutator(StringBuffer buffer, ClassElement element) {
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

  buffer.writeln(
      "extension ${className}ObminOpticMutatorExtension<Whole${generics.isEmpty ? "" : ",${_dropFirstChar(_dropLastChar(generics))}"}> on Mutator<Whole, $className$generics> {");

  for (final field in element.fields) {
    buffer.writeln("");

    final fieldName = field.displayName;
    final fieldType = field.type;

    buffer.writeln("  Mutator<Whole, $fieldType> get $fieldName => compose(");
    buffer.writeln("    Mutator.lens<$className$generics, $fieldType>(");
    buffer.writeln("      Getter<$className$generics, $fieldType>((whole) => whole.$fieldName),");
    buffer.writeln("      (whole, part) => whole.copySet${_uppercaseFirstCharacter(fieldName)}(part),");
    buffer.writeln("    ),");
    buffer.writeln("  );");
  }

  buffer.writeln('}');

  buffer.writeln(
      "extension ${className}ObminOpticIsoExtension<Whole${generics.isEmpty ? "" : ",${_dropFirstChar(_dropLastChar(generics))}"}> on Iso<Whole, $className$generics> {");

  for (final field in element.fields) {
    buffer.writeln("");

    final fieldName = field.displayName;
    final fieldType = field.type;

    buffer.writeln("  Mutator<Whole, $fieldType> get $fieldName => asMutator().compose(");
    buffer.writeln("    Mutator.lens<$className$generics, $fieldType>(");
    buffer.writeln("      Getter<$className$generics, $fieldType>((whole) => whole.$fieldName),");
    buffer.writeln("      (whole, part) => whole.copySet${_uppercaseFirstCharacter(fieldName)}(part),");
    buffer.writeln("    ),");
    buffer.writeln("  );");
  }

  buffer.writeln('}');

  buffer.writeln(
      "extension ${className}ObminOpticPrismExtension<Whole${generics.isEmpty ? "" : ",${_dropFirstChar(_dropLastChar(generics))}"}> on Prism<Whole, $className$generics> {");

  for (final field in element.fields) {
    buffer.writeln("");

    final fieldName = field.displayName;
    final fieldType = field.type;

    buffer.writeln("  Mutator<Whole, $fieldType> get $fieldName => asMutator().compose(");
    buffer.writeln("    Mutator.lens<$className$generics, $fieldType>(");
    buffer.writeln("      Getter<$className$generics, $fieldType>((whole) => whole.$fieldName),");
    buffer.writeln("      (whole, part) => whole.copySet${_uppercaseFirstCharacter(fieldName)}(part),");
    buffer.writeln("    ),");
    buffer.writeln("  );");
  }

  buffer.writeln('}');

  buffer.writeln(
      "extension ${className}ObminOpticReflectorExtension<Whole${generics.isEmpty ? "" : ",${_dropFirstChar(_dropLastChar(generics))}"}> on Reflector<Whole, $className$generics> {");

  for (final field in element.fields) {
    buffer.writeln("");

    final fieldName = field.displayName;
    final fieldType = field.type;

    buffer.writeln("  Mutator<Whole, $fieldType> get $fieldName => asMutator().compose(");
    buffer.writeln("    Mutator.lens<$className$generics, $fieldType>(");
    buffer.writeln("      Getter<$className$generics, $fieldType>((whole) => whole.$fieldName),");
    buffer.writeln("      (whole, part) => whole.copySet${_uppercaseFirstCharacter(fieldName)}(part),");
    buffer.writeln("    ),");
    buffer.writeln("  );");
  }

  buffer.writeln('}');

  buffer.writeln(
      "extension ${className}ObminOpticBiPreviewExtension<Whole${generics.isEmpty ? "" : ",${_dropFirstChar(_dropLastChar(generics))}"}> on BiPreview<Whole, $className$generics> {");

  for (final field in element.fields) {
    buffer.writeln("");

    final fieldName = field.displayName;
    final fieldType = field.type;

    buffer.writeln("  Mutator<Whole, $fieldType> get $fieldName => asMutator().compose(");
    buffer.writeln("    Mutator.lens<$className$generics, $fieldType>(");
    buffer.writeln("      Getter<$className$generics, $fieldType>((whole) => whole.$fieldName),");
    buffer.writeln("      (whole, part) => whole.copySet${_uppercaseFirstCharacter(fieldName)}(part),");
    buffer.writeln("    ),");
    buffer.writeln("  );");
  }

  buffer.writeln('}');
}

void _generateFinalPODO(StringBuffer buffer, ClassElement element) {
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

  buffer.writeln("extension Optic${className}UtilsExtension${generics} on $className$generics {");

  String properties = "";
  String arguments = "";
  String compares = "";
  String hashes = "";

  for (final field in element.fields) {
    final type = field.type;
    final name = field.displayName;

    final bool isAnyIterableSubclass = type.isDartCoreIterable;

    properties += "  final $type $name;\n";
    arguments += " $name=\$$name,";
    compares += "&& ${isAnyIterableSubclass ? "const IterableEquality().equals(other.$name, $name)" : "other.$name == $name"}";
    hashes += "${isAnyIterableSubclass ? "const IterableEquality().hash($name)" : name},";
  }

  buffer.writeln(properties);
  
  buffer.writeln("");
  buffer.writeln("");

  buffer.writeln("  String _toString() {");
  buffer.writeln("    return \"$className${element.typeParameters.isEmpty ? "" : "<${_dropLastChar(element.typeParameters.fold("", (acc, element) {
      return "$acc\$$element,";
    }))}>"} {${_dropLastChar(arguments)} }\";");
  buffer.writeln("  }");

  buffer.writeln("");
  buffer.writeln("");

  buffer.writeln("  // you need \"collection:\" package if you want to use Iterable in your class");
  buffer.writeln("  bool _equals(Object other) {");
  buffer.writeln("    if (identical(this, other)) return true;");
  buffer.writeln("    return other is $className$generics");
  buffer.writeln("    $compares;");
  buffer.writeln("  }");

  buffer.writeln("");
  buffer.writeln("");

  buffer.writeln("  int get _hashCode => Object.hashAll([");
  buffer.writeln("    $hashes");
  buffer.writeln("  ]);");

  buffer.writeln("");
  buffer.writeln("");
  
  buffer.writeln("}");
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
  for (final element in library.topLevelElements) {
    if (element is ClassElement && element != sealedClass) {
      if (isDirectSubclassOf(element, sealedClass)) {
        subclasses.add(element);
      }
    }
  }

  return subclasses;
}
