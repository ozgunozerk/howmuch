import 'package:flutter/material.dart';

import 'package:how_much/presentation/ui/colours.dart';

class BlinkingStatus extends StatelessWidget {
  const BlinkingStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      height: 40,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        color: lightPrimary, // Set your desired color
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BlinkingWidget(
              child: Container(
                  height: 12,
                  width: 12,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: green,
                  ))),
          const Padding(padding: EdgeInsets.all(8)),
          const Text(
            "Next update in: ",
            style: TextStyle(color: howBlack),
          ),
          const Text("3.55 hours", style: TextStyle(color: howBlack))
        ],
      ),
    );
  }
}

class BlinkingWidget extends StatefulWidget {
  final Widget child;
  final Duration? duration;

  const BlinkingWidget({
    super.key,
    required this.child,
    this.duration,
  });

  @override
  State<BlinkingWidget> createState() => _BlinkingWidgetState();
}

class _BlinkingWidgetState extends State<BlinkingWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.duration ?? const Duration(milliseconds: 1000),
      vsync: this,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _controller.forward();
      }
    });

    _controller.forward();
  }

  @override
  dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Opacity(
          opacity: _controller.value,
          child: widget.child,
        ),
        child: widget.child,
      );
}
