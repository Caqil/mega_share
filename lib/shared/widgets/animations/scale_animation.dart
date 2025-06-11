import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

/// Scale animation widget
class ScaleAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final double beginScale;
  final double endScale;
  final bool autoStart;
  final Alignment alignment;

  const ScaleAnimation({
    super.key,
    required this.child,
    this.duration = AppConstants.mediumAnimation,
    this.delay = Duration.zero,
    this.curve = Curves.easeInOut,
    this.beginScale = 0.0,
    this.endScale = 1.0,
    this.autoStart = true,
    this.alignment = Alignment.center,
  });

  @override
  State<ScaleAnimation> createState() => _ScaleAnimationState();
}

class _ScaleAnimationState extends State<ScaleAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _animation = Tween<double>(
      begin: widget.beginScale,
      end: widget.endScale,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

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
      builder: (context, child) => Transform.scale(
        scale: _animation.value,
        alignment: widget.alignment,
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
