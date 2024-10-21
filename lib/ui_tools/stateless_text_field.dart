// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final class StatelessTextField extends StatelessWidget {
  final TextMagnifierConfiguration? magnifierConfiguration;
  final InputDecoration? decoration;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign textAlign;
  final TextAlignVertical? textAlignVertical;
  final TextDirection? textDirection;
  final bool autofocus;
  final String obscuringCharacter;
  final bool obscureText;
  final bool autocorrect;
  final bool enableSuggestions;
  final int? maxLines;
  final int? minLines;
  final bool expands;
  final bool readOnly;
  final bool? showCursor;
  final int? maxLength;
  final MaxLengthEnforcement? maxLengthEnforcement;
  final ValueChanged<String> onChanged;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onSubmitted;
  final AppPrivateCommandCallback? onAppPrivateCommand;
  final List<TextInputFormatter>? inputFormatters;
  final bool? enabled;
  final double cursorWidth;
  final double? cursorHeight;
  final Radius? cursorRadius;
  final bool? cursorOpacityAnimates;
  final Color? cursorColor;
  final Brightness? keyboardAppearance;
  final EdgeInsets scrollPadding;
  final TextSelectionControls? selectionControls;
  final DragStartBehavior dragStartBehavior;
  final GestureTapCallback? onTap;
  final TapRegionCallback? onTapOutside;
  final InputCounterWidgetBuilder? buildCounter;
  final ScrollPhysics? scrollPhysics;
  final Iterable<String>? autofillHints;
  final Clip clipBehavior;
  final String? restorationId;
  final bool scribbleEnabled;
  final bool enableIMEPersonalizedLearning;
  final ContentInsertionConfiguration? contentInsertionConfiguration;
  final SpellCheckConfiguration? spellCheckConfiguration;

  final String text;

  const StatelessTextField(
    this.text, {
    super.key,
    required this.onChanged,
    this.keyboardType = TextInputType.text,
    this.decoration = const InputDecoration(),
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.style,
    this.strutStyle,
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
    this.textDirection,
    this.readOnly = false,
    this.showCursor,
    this.autofocus = false,
    this.obscuringCharacter = '•',
    this.obscureText = false,
    this.autocorrect = false,
    this.enableSuggestions = true,
    this.maxLines = 1,
    this.minLines,
    this.expands = false,
    this.maxLength,
    this.maxLengthEnforcement,
    this.onEditingComplete,
    this.onSubmitted,
    this.onAppPrivateCommand,
    this.inputFormatters,
    this.enabled,
    this.cursorWidth = 2.0,
    this.cursorHeight,
    this.cursorRadius,
    this.cursorOpacityAnimates,
    this.cursorColor,
    this.keyboardAppearance,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.dragStartBehavior = DragStartBehavior.start,
    this.selectionControls,
    this.onTap,
    this.onTapOutside,
    this.buildCounter,
    this.scrollPhysics,
    this.autofillHints = const <String>[],
    this.contentInsertionConfiguration,
    this.clipBehavior = Clip.hardEdge,
    this.restorationId,
    this.scribbleEnabled = true,
    this.enableIMEPersonalizedLearning = true,
    this.spellCheckConfiguration,
    this.magnifierConfiguration,
  });

  @override
  Widget build(BuildContext context) {
    return _WrapperTextField(
      text,
      onChanged: onChanged,
      keyboardType: keyboardType,
      decoration: decoration,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      style: style,
      strutStyle: strutStyle,
      textAlign: textAlign,
      textAlignVertical: textAlignVertical,
      textDirection: textDirection,
      readOnly: readOnly,
      showCursor: showCursor,
      autofocus: autofocus,
      obscuringCharacter: obscuringCharacter,
      obscureText: obscureText,
      autocorrect: autocorrect,
      enableSuggestions: enableSuggestions,
      maxLines: maxLines,
      minLines: minLines,
      expands: expands,
      maxLength: maxLength,
      maxLengthEnforcement: maxLengthEnforcement,
      onEditingComplete: onEditingComplete,
      onSubmitted: onSubmitted,
      onAppPrivateCommand: onAppPrivateCommand,
      inputFormatters: inputFormatters,
      enabled: enabled,
      cursorWidth: cursorWidth,
      cursorHeight: cursorHeight,
      cursorRadius: cursorRadius,
      cursorOpacityAnimates: cursorOpacityAnimates,
      cursorColor: cursorColor,
      keyboardAppearance: keyboardAppearance,
      scrollPadding: scrollPadding,
      dragStartBehavior: dragStartBehavior,
      selectionControls: selectionControls,
      onTap: onTap,
      onTapOutside: onTapOutside,
      buildCounter: buildCounter,
      scrollPhysics: scrollPhysics,
      autofillHints: autofillHints,
      contentInsertionConfiguration: contentInsertionConfiguration,
      clipBehavior: clipBehavior,
      restorationId: restorationId,
      scribbleEnabled: scribbleEnabled,
      enableIMEPersonalizedLearning: enableIMEPersonalizedLearning,
      spellCheckConfiguration: spellCheckConfiguration,
      magnifierConfiguration: magnifierConfiguration,
    );
  }
}

final class _WrapperTextField extends InheritedWidget {
  final TextMagnifierConfiguration? magnifierConfiguration;
  final InputDecoration? decoration;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign textAlign;
  final TextAlignVertical? textAlignVertical;
  final TextDirection? textDirection;
  final bool autofocus;
  final String obscuringCharacter;
  final bool obscureText;
  final bool autocorrect;
  final bool enableSuggestions;
  final int? maxLines;
  final int? minLines;
  final bool expands;
  final bool readOnly;
  final bool? showCursor;
  final int? maxLength;
  final MaxLengthEnforcement? maxLengthEnforcement;
  final ValueChanged<String> onChanged;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onSubmitted;
  final AppPrivateCommandCallback? onAppPrivateCommand;
  final List<TextInputFormatter>? inputFormatters;
  final bool? enabled;
  final double cursorWidth;
  final double? cursorHeight;
  final Radius? cursorRadius;
  final bool? cursorOpacityAnimates;
  final Color? cursorColor;
  final Brightness? keyboardAppearance;
  final EdgeInsets scrollPadding;
  final TextSelectionControls? selectionControls;
  final DragStartBehavior dragStartBehavior;
  final GestureTapCallback? onTap;
  final TapRegionCallback? onTapOutside;
  final InputCounterWidgetBuilder? buildCounter;
  final ScrollPhysics? scrollPhysics;
  final Iterable<String>? autofillHints;
  final Clip clipBehavior;
  final String? restorationId;
  final bool scribbleEnabled;
  final bool enableIMEPersonalizedLearning;
  final ContentInsertionConfiguration? contentInsertionConfiguration;
  final SpellCheckConfiguration? spellCheckConfiguration;

  final String text;

  _WrapperTextField(
    this.text, {
    required this.onChanged,
    required this.keyboardType,
    required this.decoration,
    required this.textInputAction,
    required this.textCapitalization,
    required this.style,
    required this.strutStyle,
    required this.textAlign,
    required this.textAlignVertical,
    required this.textDirection,
    required this.readOnly,
    required this.showCursor,
    required this.autofocus,
    required this.obscuringCharacter,
    required this.obscureText,
    required this.autocorrect,
    required this.enableSuggestions,
    required this.maxLines,
    required this.minLines,
    required this.expands,
    required this.maxLength,
    required this.maxLengthEnforcement,
    required this.onEditingComplete,
    required this.onSubmitted,
    required this.onAppPrivateCommand,
    required this.inputFormatters,
    required this.enabled,
    required this.cursorWidth,
    required this.cursorHeight,
    required this.cursorRadius,
    required this.cursorOpacityAnimates,
    required this.cursorColor,
    required this.keyboardAppearance,
    required this.scrollPadding,
    required this.dragStartBehavior,
    required this.selectionControls,
    required this.onTap,
    required this.onTapOutside,
    required this.buildCounter,
    required this.scrollPhysics,
    required this.autofillHints,
    required this.contentInsertionConfiguration,
    required this.clipBehavior,
    required this.restorationId,
    required this.scribbleEnabled,
    required this.enableIMEPersonalizedLearning,
    required this.spellCheckConfiguration,
    required this.magnifierConfiguration,
  }) : super(
          child: _CustomTextField(
            onChanged: onChanged,
            keyboardType: keyboardType,
            decoration: decoration,
            textInputAction: textInputAction,
            textCapitalization: textCapitalization,
            style: style,
            strutStyle: strutStyle,
            textAlign: textAlign,
            textAlignVertical: textAlignVertical,
            textDirection: textDirection,
            readOnly: readOnly,
            showCursor: showCursor,
            autofocus: autofocus,
            obscuringCharacter: obscuringCharacter,
            obscureText: obscureText,
            autocorrect: autocorrect,
            enableSuggestions: enableSuggestions,
            maxLines: maxLines,
            minLines: minLines,
            expands: expands,
            maxLength: maxLength,
            maxLengthEnforcement: maxLengthEnforcement,
            onEditingComplete: onEditingComplete,
            onSubmitted: onSubmitted,
            onAppPrivateCommand: onAppPrivateCommand,
            inputFormatters: inputFormatters,
            enabled: enabled,
            cursorWidth: cursorWidth,
            cursorHeight: cursorHeight,
            cursorRadius: cursorRadius,
            cursorOpacityAnimates: cursorOpacityAnimates,
            cursorColor: cursorColor,
            keyboardAppearance: keyboardAppearance,
            scrollPadding: scrollPadding,
            dragStartBehavior: dragStartBehavior,
            selectionControls: selectionControls,
            onTap: onTap,
            onTapOutside: onTapOutside,
            buildCounter: buildCounter,
            scrollPhysics: scrollPhysics,
            autofillHints: autofillHints,
            contentInsertionConfiguration: contentInsertionConfiguration,
            clipBehavior: clipBehavior,
            restorationId: restorationId,
            scribbleEnabled: scribbleEnabled,
            enableIMEPersonalizedLearning: enableIMEPersonalizedLearning,
            spellCheckConfiguration: spellCheckConfiguration,
            magnifierConfiguration: magnifierConfiguration,
          ),
        );

  static _WrapperTextField of(BuildContext context) {
    final _WrapperTextField? result = context.dependOnInheritedWidgetOfExactType<_WrapperTextField>();
    assert(result != null, 'No WrapperTextField found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(_WrapperTextField oldWidget) {
    return oldWidget.text != text;
  }
}

final class _CustomTextField extends StatefulWidget {
  final TextMagnifierConfiguration? magnifierConfiguration;
  final InputDecoration? decoration;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign textAlign;
  final TextAlignVertical? textAlignVertical;
  final TextDirection? textDirection;
  final bool autofocus;
  final String obscuringCharacter;
  final bool obscureText;
  final bool autocorrect;
  final bool enableSuggestions;
  final int? maxLines;
  final int? minLines;
  final bool expands;
  final bool readOnly;
  final bool? showCursor;
  final int? maxLength;
  final MaxLengthEnforcement? maxLengthEnforcement;
  final ValueChanged<String> onChanged;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onSubmitted;
  final AppPrivateCommandCallback? onAppPrivateCommand;
  final List<TextInputFormatter>? inputFormatters;
  final bool? enabled;
  final double cursorWidth;
  final double? cursorHeight;
  final Radius? cursorRadius;
  final bool? cursorOpacityAnimates;
  final Color? cursorColor;
  final Brightness? keyboardAppearance;
  final EdgeInsets scrollPadding;
  final TextSelectionControls? selectionControls;
  final DragStartBehavior dragStartBehavior;
  final GestureTapCallback? onTap;
  final TapRegionCallback? onTapOutside;
  final InputCounterWidgetBuilder? buildCounter;
  final ScrollPhysics? scrollPhysics;
  final Iterable<String>? autofillHints;
  final Clip clipBehavior;
  final String? restorationId;
  final bool scribbleEnabled;
  final bool enableIMEPersonalizedLearning;
  final ContentInsertionConfiguration? contentInsertionConfiguration;
  final SpellCheckConfiguration? spellCheckConfiguration;

  const _CustomTextField({
    required this.onChanged,
    required this.magnifierConfiguration,
    required this.decoration,
    required this.keyboardType,
    required this.textInputAction,
    required this.textCapitalization,
    required this.style,
    required this.strutStyle,
    required this.textAlign,
    required this.textAlignVertical,
    required this.textDirection,
    required this.autofocus,
    required this.obscuringCharacter,
    required this.obscureText,
    required this.autocorrect,
    required this.enableSuggestions,
    required this.maxLines,
    required this.minLines,
    required this.expands,
    required this.readOnly,
    required this.showCursor,
    required this.maxLength,
    required this.maxLengthEnforcement,
    required this.onEditingComplete,
    required this.onSubmitted,
    required this.onAppPrivateCommand,
    required this.inputFormatters,
    required this.enabled,
    required this.cursorWidth,
    required this.cursorHeight,
    required this.cursorRadius,
    required this.cursorOpacityAnimates,
    required this.cursorColor,
    required this.keyboardAppearance,
    required this.scrollPadding,
    required this.selectionControls,
    required this.dragStartBehavior,
    required this.onTap,
    required this.onTapOutside,
    required this.buildCounter,
    required this.scrollPhysics,
    required this.autofillHints,
    required this.clipBehavior,
    required this.restorationId,
    required this.scribbleEnabled,
    required this.enableIMEPersonalizedLearning,
    required this.contentInsertionConfiguration,
    required this.spellCheckConfiguration,
  });

  @override
  State<_CustomTextField> createState() => _CustomTextFieldState();
}

final class _CustomTextFieldState extends State<_CustomTextField> {
  final TextEditingController _controller = TextEditingController();

  bool isFirstTime = true;

  void handleTextRendering() {
    final int oldCursorPosition = _controller.selection.end;
    _controller.text = _WrapperTextField.of(context).text;
    final int newCursorPosition = _controller.selection.end;
    if (newCursorPosition > oldCursorPosition) {
      _controller.selection = TextSelection.fromPosition(TextPosition(offset: oldCursorPosition));
    }
  }

  @override
  void didChangeDependencies() {
    if (isFirstTime) {
      isFirstTime = false;
      handleTextRendering();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          handleTextRendering();
        }
      });
    }

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: (newText) {
        widget.onChanged(newText);
      },
      keyboardType: widget.keyboardType,
      decoration: widget.decoration,
      textInputAction: widget.textInputAction,
      textCapitalization: widget.textCapitalization,
      style: widget.style,
      strutStyle: widget.strutStyle,
      textAlign: widget.textAlign,
      textAlignVertical: widget.textAlignVertical,
      textDirection: widget.textDirection,
      readOnly: widget.readOnly,
      showCursor: widget.showCursor,
      autofocus: widget.autofocus,
      obscuringCharacter: widget.obscuringCharacter,
      obscureText: widget.obscureText,
      autocorrect: widget.autocorrect,
      enableSuggestions: widget.enableSuggestions,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      expands: widget.expands,
      maxLength: widget.maxLength,
      maxLengthEnforcement: widget.maxLengthEnforcement,
      onEditingComplete: widget.onEditingComplete,
      onSubmitted: widget.onSubmitted,
      onAppPrivateCommand: widget.onAppPrivateCommand,
      inputFormatters: widget.inputFormatters,
      enabled: widget.enabled,
      cursorWidth: widget.cursorWidth,
      cursorHeight: widget.cursorHeight,
      cursorRadius: widget.cursorRadius,
      cursorOpacityAnimates: widget.cursorOpacityAnimates,
      cursorColor: widget.cursorColor,
      keyboardAppearance: widget.keyboardAppearance,
      scrollPadding: widget.scrollPadding,
      dragStartBehavior: widget.dragStartBehavior,
      selectionControls: widget.selectionControls,
      onTap: widget.onTap,
      onTapOutside: widget.onTapOutside,
      buildCounter: widget.buildCounter,
      scrollPhysics: widget.scrollPhysics,
      autofillHints: widget.autofillHints,
      contentInsertionConfiguration: widget.contentInsertionConfiguration,
      clipBehavior: widget.clipBehavior,
      restorationId: widget.restorationId,
      scribbleEnabled: widget.scribbleEnabled,
      enableIMEPersonalizedLearning: widget.enableIMEPersonalizedLearning,
      spellCheckConfiguration: widget.spellCheckConfiguration,
      magnifierConfiguration: widget.magnifierConfiguration,
    );
  }
}
