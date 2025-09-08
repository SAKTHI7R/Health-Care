import 'package:flutter/material.dart';

class AnimatedIconWidget extends StatefulWidget {
  final IconData icon;
  final Color color;

  const AnimatedIconWidget({Key? key, required this.icon, required this.color})
      : super(key: key);

  @override
  _AnimatedIconWidgetState createState() => _AnimatedIconWidgetState();
}

class _AnimatedIconWidgetState extends State<AnimatedIconWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true); // Repeat the animation indefinitely.

    if (widget.icon == Icons.favorite) {
      // Heartbeat pulse animation
      _scaleAnimation = Tween(begin: 0.9, end: 1.1).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      );
    } else if (widget.icon == Icons.directions_walk) {
      // Walking bounce animation
      _offsetAnimation = Tween<Offset>(begin: Offset(0, 0), end: Offset(0, -4))
          .animate(
              CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    } else {
      // Static icon with subtle pulse/tilt effect for others (like water, sleep)
      _scaleAnimation = Tween(begin: 0.95, end: 1.05).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.icon == Icons.favorite) {
      // Pulse animation
      return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: Icon(widget.icon, size: 28, color: widget.color),
        ),
      );
    } else if (widget.icon == Icons.directions_walk) {
      // Walking bounce animation
      return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.translate(
          offset: _offsetAnimation.value,
          child: Icon(widget.icon, size: 28, color: widget.color),
        ),
      );
    } else {
      // Static icons with subtle pulse/tilt effect (water, sleep)
      return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: Icon(widget.icon, size: 28, color: widget.color),
        ),
      );
    }
  }
}
