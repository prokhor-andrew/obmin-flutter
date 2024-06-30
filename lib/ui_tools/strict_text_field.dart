// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:flutter/material.dart';
import 'package:obmin/ui_tools/stateless_text_field.dart';

class StrictTextField extends StatefulWidget {
  final String text;
  final String? error;
  final bool autocorrect;
  final TextInputType keyboardType;
  final bool enabled;
  final bool isSecure;
  final String hint;

  final bool autofocus;
  final void Function(String text) onChanged;

  final IconButton? action;

  const StrictTextField(
    this.text, {
    super.key,
    required this.onChanged,
    required this.hint,
    required this.keyboardType,
    this.autocorrect = false,
    this.autofocus = false,
    this.error,
    this.enabled = true,
    this.isSecure = false,
    this.action,
  });

  @override
  State<StrictTextField> createState() => _StrictTextFieldState();
}

class _StrictTextFieldState extends State<StrictTextField> {
  late bool isHidden;

  @override
  void initState() {
    isHidden = widget.isSecure;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StatelessTextField(
      widget.text,
      obscureText: isHidden,
      cursorColor: Theme.of(context).colorScheme.primary,
      autofocus: widget.autofocus,
      keyboardType: widget.keyboardType,
      autocorrect: widget.autocorrect,
      onChanged: widget.onChanged,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: widget.hint,
        labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        errorText: widget.error,
        floatingLabelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
        focusedBorder: focusedBorder(),
        errorBorder: errorBorder(),
        disabledBorder: border(),
        enabledBorder: border(),
        border: border(),
        enabled: widget.enabled,
        suffixIconColor: WidgetStateColor.resolveWith((states) =>
            states.contains(WidgetState.focused) ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primary.withOpacity(0.5)),
        suffixIcon: widget.action ??
            (widget.isSecure
                ? IconButton(
                    icon: isHidden ? const Icon(Icons.visibility) : const Icon(Icons.visibility_off),
                    onPressed: () => setState(() => isHidden = !isHidden),
                  )
                : const SizedBox(height: 0, width: 0)),
      ),
    );
  }

  OutlineInputBorder errorBorder() {
    return OutlineInputBorder(
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.error,
        width: 2,
      ),
      borderRadius: const BorderRadius.all(Radius.circular(4)),
    );
  }

  OutlineInputBorder focusedBorder() {
    return OutlineInputBorder(
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.primary,
        width: 2,
      ),
      borderRadius: const BorderRadius.all(Radius.circular(4)),
    );
  }

  OutlineInputBorder border() {
    return OutlineInputBorder(
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
        width: 2,
      ),
      borderRadius: const BorderRadius.all(Radius.circular(4)),
    );
  }
}
