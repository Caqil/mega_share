// lib/shared/widgets/common/loading_widget.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/extensions/context_extensions.dart';

/// Loading widget variants
enum LoadingVariant {
  circular,
  linear,
  adaptive,
  dots,
  pulse,
}

/// Custom loading widget with various styles
class LoadingWidget extends StatelessWidget {
  final LoadingVariant variant;
  final String? message;
  final Color? color;
  final double? size;
  final double? strokeWidth;
  final bool overlay;
  final Color? overlayColor;
  
  const LoadingWidget({
    super.key,
    this.variant = LoadingVariant.circular,
    this.message,
    this.color,
    this.size,
    this.strokeWidth,
    this.overlay = false,
    this.overlayColor,
  });
  
  @override
  Widget build(BuildContext context) {
    Widget loadingWidget = _buildLoadingIndicator(context);
    
    if (message != null) {
      loadingWidget = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          loadingWidget,
          const SizedBox(height: 16),
          Text(
            message!,
            style: context.textTheme.bodyMedium?.copyWith(
              color: color ?? context.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }
    
    if (overlay) {
      return Material(
        color: overlayColor ?? Colors.black.withOpacity(0.5),
        child: Center(child: loadingWidget),
      );
    }
    
    return Center(child: loadingWidget);
  }
  
  Widget _buildLoadingIndicator(BuildContext context) {
    final indicatorColor = color ?? context.colorScheme.primary;
    final indicatorSize = size ?? 40.0;
    
    switch (variant) {
      case LoadingVariant.circular:
        return SizedBox(
          width: indicatorSize,
          height: indicatorSize,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
            strokeWidth: strokeWidth ?? 4.0,
          ),
        );
      
      case LoadingVariant.linear:
        return SizedBox(
          width: indicatorSize * 3,
          child: LinearProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
            minHeight: strokeWidth ?? 4.0,
          ),
        );
      
      case LoadingVariant.adaptive:
        return SizedBox(
          width: indicatorSize,
          height: indicatorSize,
          child: CircularProgressIndicator.adaptive(
            valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
            strokeWidth: strokeWidth ?? 4.0,
          ),
        );
      
      case LoadingVariant.dots:
        return _DotsLoadingIndicator(
          color: indicatorColor,
          size: indicatorSize / 8,
        );
      
      case LoadingVariant.pulse:
        return _PulseLoadingIndicator(
          color: indicatorColor,
          size: indicatorSize,
        );
    }
  }
}

/// Dots loading indicator
class _DotsLoadingIndicator extends StatefulWidget {
  final Color color;
  final double size;
  
  const _DotsLoadingIndicator({
    required this.color,
    required this.size,
  });
  
  @override
  State<_DotsLoadingIndicator> createState() => _DotsLoadingIndicatorState();
}

class _DotsLoadingIndicatorState extends State<_DotsLoadingIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  
  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (index) => 
        AnimationController(
          duration: const Duration(milliseconds: 600),
          vsync: this,
        ));
    
    _animations = _controllers.map((controller) =>
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: controller, curve: Curves.easeInOut),
        )).toList();
    
    _startAnimations();
  }
  
  void _startAnimations() {
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }
  
  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) =>
          AnimatedBuilder(
            animation: _animations[index],
            builder: (context, child) => Container(
              margin: EdgeInsets.symmetric(horizontal: widget.size / 2),
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withOpacity(0.3 + (_animations[index].value * 0.7)),
              ),
            ),
          )),
    );
  }
}

/// Pulse loading indicator
class _PulseLoadingIndicator extends StatefulWidget {
  final Color color;
  final double size;
  
  const _PulseLoadingIndicator({
    required this.color,
    required this.size,
  });
  
  @override
  State<_PulseLoadingIndicator> createState() => _PulseLoadingIndicatorState();
}

class _PulseLoadingIndicatorState extends State<_PulseLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.color.withOpacity(0.3 + (_animation.value * 0.7)),
        ),
      ),
    );
  }
}

/// Skeleton loading widget
class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final Color? baseColor;
  final Color? highlightColor;
  
  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
    this.baseColor,
    this.highlightColor,
  });
  
  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final baseColor = widget.baseColor ?? 
        context.colorScheme.surfaceContainerHighest;
    final highlightColor = widget.highlightColor ?? 
        context.colorScheme.surface;
    
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius,
          gradient: LinearGradient(
            begin: Alignment(_animation.value - 1, 0),
            end: Alignment(_animation.value, 0),
            colors: [
              baseColor,
              highlightColor,
              baseColor,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
      ),
    );
  }
}
