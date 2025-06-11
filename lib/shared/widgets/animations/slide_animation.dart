import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

/// Slide animation directions
enum SlideDirection {
  left,
  right,
  up,
  down,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

/// Slide animation widget
class SlideAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final SlideDirection direction;
  final double distance;
  final bool autoStart;

  const SlideAnimation({
    super.key,
    required this.child,
    this.duration = AppConstants.mediumAnimation,
    this.delay = Duration.zero,
    this.curve = Curves.easeInOut,
    this.direction = SlideDirection.left,
    this.distance = 50.0,
    this.autoStart = true,
  });

  @override
  State<SlideAnimation> createState() => _SlideAnimationState();
}

class _SlideAnimationState extends State<SlideAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _animation = Tween<Offset>(
      begin: _getBeginOffset(),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    if (widget.autoStart) {
      _startAnimation();
    }
  }

  Offset _getBeginOffset() {
    switch (widget.direction) {
      case SlideDirection.left:
        return Offset(-widget.distance / 100, 0);
      case SlideDirection.right:
        return Offset(widget.distance / 100, 0);
      case SlideDirection.up:
        return Offset(0, -widget.distance / 100);
      case SlideDirection.down:
        return Offset(0, widget.distance / 100);
      case SlideDirection.topLeft:
        return Offset(-widget.distance / 100, -widget.distance / 100);
      case SlideDirection.topRight:
        return Offset(widget.distance / 100, -widget.distance / 100);
      case SlideDirection.bottomLeft:
        return Offset(-widget.distance / 100, widget.distance / 100);
      case SlideDirection.bottomRight:
        return Offset(widget.distance / 100, widget.distance / 100);
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
      builder: (context, child) =>
          SlideTransition(position: _animation, child: widget.child),
    );
  }

  /// Start the animation manually
  void start() => _startAnimation();

  /// Reset the animation
  void reset() => _controller.reset();

  /// Reverse the animation
  void reverse() => _controller.reverse();
}
