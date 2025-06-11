import 'package:flutter/material.dart';

/// Transfer animation for file sharing
class TransferAnimation extends StatefulWidget {
  final Widget fromChild;
  final Widget toChild;
  final Duration duration;
  final Color? particleColor;
  final int particleCount;
  final bool autoStart;
  final VoidCallback? onComplete;

  const TransferAnimation({
    super.key,
    required this.fromChild,
    required this.toChild,
    this.duration = const Duration(seconds: 2),
    this.particleColor,
    this.particleCount = 5,
    this.autoStart = true,
    this.onComplete,
  });

  @override
  State<TransferAnimation> createState() => _TransferAnimationState();
}

class _TransferAnimationState extends State<TransferAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<AnimationController> _particleControllers;
  late List<Animation<double>> _particleAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _particleControllers = List.generate(
      widget.particleCount,
      (index) => AnimationController(duration: widget.duration, vsync: this),
    );

    _particleAnimations = _particleControllers
        .map(
          (controller) => Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: controller, curve: Curves.easeInOut),
          ),
        )
        .toList();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });

    if (widget.autoStart) {
      _startAnimation();
    }
  }

  void _startAnimation() {
    _controller.forward();

    // Start particle animations with staggered delays
    for (int i = 0; i < _particleControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          _particleControllers[i].forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    for (final controller in _particleControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(left: 50, top: 50, child: widget.fromChild),
        Positioned(right: 50, top: 50, child: widget.toChild),
        ..._buildParticles(),
      ],
    );
  }

  List<Widget> _buildParticles() {
    return _particleAnimations.asMap().entries.map((entry) {
      final index = entry.key;
      final animation = entry.value;

      return AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final progress = animation.value;
          final startX = 100.0;
          final endX = MediaQuery.of(context).size.width - 100.0;
          final currentX = startX + (endX - startX) * progress;

          // Add some vertical variation
          final verticalOffset =
              10 * (index % 2 == 0 ? 1 : -1) * (4 * progress * (1 - progress));

          return Positioned(
            left: currentX,
            top: 50 + verticalOffset,
            child: Opacity(
              opacity: 1 - progress,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      widget.particleColor ??
                      Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          );
        },
      );
    }).toList();
  }

  /// Start the animation manually
  void start() => _startAnimation();

  /// Reset the animation
  void reset() {
    _controller.reset();
    for (final controller in _particleControllers) {
      controller.reset();
    }
  }
}

/// Pulse animation for active transfers
class PulseAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double minScale;
  final double maxScale;
  final bool autoStart;

  const PulseAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1000),
    this.minScale = 0.8,
    this.maxScale = 1.2,
    this.autoStart = true,
  });

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _animation = Tween<double>(
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.autoStart) {
      _controller.repeat(reverse: true);
    }
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
          Transform.scale(scale: _animation.value, child: widget.child),
    );
  }

  /// Start the animation manually
  void start() => _controller.repeat(reverse: true);

  /// Stop the animation
  void stop() => _controller.stop();

  /// Reset the animation
  void reset() => _controller.reset();
}
