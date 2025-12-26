import 'package:flutter/material.dart';

class FeatureCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final int delay;
  final VoidCallback? onTap;
  final bool isDisabled;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.delay = 0,
    this.onTap,
    this.isDisabled = false,
  });

  @override
  State<FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<FeatureCard> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 800 + widget.delay),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: MouseRegion(
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            child: GestureDetector(
              onTap: widget.isDisabled ? null : widget.onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                transform: Matrix4.identity()
                  ..scale(_isHovered && !widget.isDisabled ? 1.02 : 1.0),
                child: Card(
                  elevation: _isHovered && !widget.isDisabled ? 8 : 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: _isHovered && !widget.isDisabled
                          ? const Color(0xFF6366F1)
                          : Colors.grey.shade200,
                      width: 2,
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.icon,
                          size: 32,
                          color: widget.isDisabled
                              ? Colors.grey.shade400
                              : _isHovered
                                  ? const Color(0xFF6366F1)
                                  : const Color(0xFF6366F1),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.title,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: widget.isDisabled
                                ? Colors.grey.shade500
                                : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.subtitle,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
