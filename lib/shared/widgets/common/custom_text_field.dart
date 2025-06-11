import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/extensions/context_extensions.dart';

/// Text field variants
enum TextFieldVariant { outlined, filled, underlined }

/// Custom text field with consistent styling and validation
class CustomTextField extends StatefulWidget {
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final TextFieldVariant variant;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final EdgeInsetsGeometry? contentPadding;
  final bool showCharacterCount;
  final FocusNode? focusNode;

  const CustomTextField({
    super.key,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.controller,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.variant = TextFieldVariant.outlined,
    this.prefixIcon,
    this.suffixIcon,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.inputFormatters,
    this.contentPadding,
    this.showCharacterCount = false,
    this.focusNode,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_onFocusChange);
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          obscureText: _obscureText,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          autofocus: widget.autofocus,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          onTap: widget.onTap,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          validator: widget.validator,
          inputFormatters: widget.inputFormatters,
          style: textTheme.bodyLarge?.copyWith(
            color: widget.enabled
                ? colorScheme.onSurface
                : colorScheme.onSurface.withOpacity(0.38),
          ),
          decoration: _buildInputDecoration(context, colorScheme),
        ),
        if (widget.showCharacterCount && widget.maxLength != null)
          _buildCharacterCount(),
      ],
    );
  }

  InputDecoration _buildInputDecoration(
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    final borderRadius = BorderRadius.circular(AppConstants.borderRadius);

    InputBorder getBorder({Color? borderColor, double width = 1.0}) {
      switch (widget.variant) {
        case TextFieldVariant.outlined:
          return OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: BorderSide(
              color: borderColor ?? colorScheme.outline,
              width: width,
            ),
          );
        case TextFieldVariant.filled:
          return OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: BorderSide.none,
          );
        case TextFieldVariant.underlined:
          return UnderlineInputBorder(
            borderSide: BorderSide(
              color: borderColor ?? colorScheme.outline,
              width: width,
            ),
          );
      }
    }

    return InputDecoration(
      labelText: widget.labelText,
      hintText: widget.hintText,
      helperText: widget.helperText,
      errorText: widget.errorText,
      prefixIcon: widget.prefixIcon != null
          ? Icon(
              widget.prefixIcon,
              color: _isFocused
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            )
          : null,
      suffixIcon: _buildSuffixIcon(colorScheme),
      filled: widget.variant == TextFieldVariant.filled,
      fillColor: widget.variant == TextFieldVariant.filled
          ? colorScheme.surfaceContainerHighest
          : null,
      border: getBorder(),
      enabledBorder: getBorder(),
      focusedBorder: getBorder(borderColor: colorScheme.primary, width: 2.0),
      errorBorder: getBorder(borderColor: colorScheme.error),
      focusedErrorBorder: getBorder(borderColor: colorScheme.error, width: 2.0),
      disabledBorder: getBorder(
        borderColor: colorScheme.onSurface.withOpacity(0.12),
      ),
      contentPadding:
          widget.contentPadding ??
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      counter: const SizedBox.shrink(), // Hide default counter
    );
  }

  Widget? _buildSuffixIcon(ColorScheme colorScheme) {
    if (widget.obscureText) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility : Icons.visibility_off,
          color: colorScheme.onSurfaceVariant,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }

    return widget.suffixIcon;
  }

  Widget _buildCharacterCount() {
    final currentLength = widget.controller?.text.length ?? 0;
    final maxLength = widget.maxLength ?? 0;

    return Padding(
      padding: const EdgeInsets.only(top: 4, right: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            '$currentLength/$maxLength',
            style: context.textTheme.bodySmall?.copyWith(
              color: currentLength > maxLength
                  ? context.colorScheme.error
                  : context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Search text field with built-in search functionality
class SearchTextField extends StatefulWidget {
  final String? hintText;
  final Function(String)? onSearchChanged;
  final VoidCallback? onSearchClear;
  final TextEditingController? controller;
  final bool autofocus;
  final EdgeInsetsGeometry? margin;

  const SearchTextField({
    super.key,
    this.hintText,
    this.onSearchChanged,
    this.onSearchClear,
    this.controller,
    this.autofocus = false,
    this.margin,
  });

  @override
  State<SearchTextField> createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<SearchTextField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_onTextChanged);
    }
    super.dispose();
  }

  void _onTextChanged() {
    widget.onSearchChanged?.call(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin ?? const EdgeInsets.all(16),
      child: CustomTextField(
        controller: _controller,
        hintText: widget.hintText ?? 'Search...',
        prefixIcon: Icons.search,
        autofocus: widget.autofocus,
        variant: TextFieldVariant.filled,
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _controller.clear();
                  widget.onSearchClear?.call();
                },
              )
            : null,
        textInputAction: TextInputAction.search,
      ),
    );
  }
}
