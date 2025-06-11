
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/extensions/context_extensions.dart';

/// Custom app bar with consistent styling and behavior
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final bool centerTitle;
  final PreferredSizeWidget? bottom;
  final SystemUiOverlayStyle? systemOverlayStyle;
  final VoidCallback? onBackPressed;
  final bool showBackButton;
  final double toolbarHeight;
  
  const CustomAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.centerTitle = true,
    this.bottom,
    this.systemOverlayStyle,
    this.onBackPressed,
    this.showBackButton = true,
    this.toolbarHeight = kToolbarHeight,
  }) : assert(title == null || titleWidget == null, 
              'Cannot provide both title and titleWidget');
  
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = context.colorScheme;
    
    return AppBar(
      title: titleWidget ?? (title != null ? Text(
        title!,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: foregroundColor ?? colorScheme.onSurface,
        ),
      ) : null),
      actions: actions,
      leading: _buildLeading(context),
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: backgroundColor ?? colorScheme.surface,
      foregroundColor: foregroundColor ?? colorScheme.onSurface,
      elevation: elevation ?? 0,
      centerTitle: centerTitle,
      bottom: bottom,
      systemOverlayStyle: systemOverlayStyle ?? _getSystemOverlayStyle(context),
      toolbarHeight: toolbarHeight,
      surfaceTintColor: colorScheme.surfaceTint,
      scrolledUnderElevation: 1,
    );
  }
  
  Widget? _buildLeading(BuildContext context) {
    if (leading != null) return leading;
    
    if (!showBackButton) return null;
    
    if (automaticallyImplyLeading && Navigator.canPop(context)) {
      return IconButton(
        icon: Icon(
          context.isRTL ? Icons.arrow_forward : Icons.arrow_back,
          color: foregroundColor ?? context.colorScheme.onSurface,
        ),
        onPressed: onBackPressed ?? () => Navigator.pop(context),
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      );
    }
    
    return null;
  }
  
  SystemUiOverlayStyle _getSystemOverlayStyle(BuildContext context) {
    final brightness = context.brightness;
    return brightness == Brightness.light
        ? SystemUiOverlayStyle.dark
        : SystemUiOverlayStyle.light;
  }
  
  @override
  Size get preferredSize => Size.fromHeight(
    toolbarHeight + (bottom?.preferredSize.height ?? 0.0),
  );
}

/// App bar with search functionality
class SearchAppBar extends StatefulWidget {
  final String? title;
  final String? hintText;
  final Function(String)? onSearchChanged;
  final VoidCallback? onSearchClear;
  final List<Widget>? actions;
  final bool autoFocus;
  final TextEditingController? controller;
  
  const SearchAppBar({
    super.key,
    this.title,
    this.hintText,
    this.onSearchChanged,
    this.onSearchClear,
    this.actions,
    this.autoFocus = false,
    this.controller,
  });
  
  @override
  State<SearchAppBar> createState() => _SearchAppBarState();
}

class _SearchAppBarState extends State<SearchAppBar> {
  late TextEditingController _controller;
  bool _isSearching = false;
  
  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }
  
  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return CustomAppBar(
      title: _isSearching ? null : widget.title,
      titleWidget: _isSearching ? _buildSearchField() : null,
      actions: _buildActions(),
      showBackButton: !_isSearching,
    );
  }
  
  Widget _buildSearchField() {
    return TextField(
      controller: _controller,
      autofocus: widget.autoFocus,
      style: context.textTheme.titleMedium,
      decoration: InputDecoration(
        hintText: widget.hintText ?? 'Search...',
        border: InputBorder.none,
        hintStyle: context.textTheme.titleMedium?.copyWith(
          color: context.colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
      onChanged: widget.onSearchChanged,
    );
  }
  
  List<Widget> _buildActions() {
    final actions = <Widget>[];
    
    if (_isSearching) {
      if (_controller.text.isNotEmpty) {
        actions.add(
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _controller.clear();
              widget.onSearchClear?.call();
              widget.onSearchChanged?.call('');
            },
          ),
        );
      }
      actions.add(
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            setState(() {
              _isSearching = false;
              _controller.clear();
            });
            widget.onSearchClear?.call();
            widget.onSearchChanged?.call('');
          },
        ),
      );
    } else {
      actions.add(
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            setState(() {
              _isSearching = true;
            });
          },
        ),
      );
      if (widget.actions != null) {
        actions.addAll(widget.actions!);
      }
    }
    
    return actions;
  }
}
