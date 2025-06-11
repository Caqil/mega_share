// lib/shared/widgets/animations/fade_in_animation.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

/// Fade in animation widget
class FadeInAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final double beginOpacity;
  final double endOpacity;
  final bool autoStart;
  
  const FadeInAnimation({
    super.key,
    required this.child,
    this.duration = AppConstants.mediumAnimation,
    this.delay = Duration.zero,
    this.curve = Curves.easeInOut,
    this.beginOpacity = 0.0,
    this.endOpacity = 1.0,
    this.autoStart = true,
  });
  
  @override
  State<FadeInAnimation> createState() => _FadeInAnimationState();
}

class _FadeInAnimationState extends State<FadeInAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: widget.beginOpacity,
      end: widget.endOpacity,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
    
    if (widget.autoStart) {
      _startAnimation();
    }
  }
  
  void _startAnimation() {
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
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
      builder: (context, child) => Opacity(
        opacity: _animation.value,
        child: widget.child,
      ),
    );
  }
  
  /// Start the animation manually
  void start() => _startAnimation();
  
  /// Reset the animation
  void reset() => _controller.reset();
  
  /// Reverse the animation
  void reverse() => _controller.reverse();
}
