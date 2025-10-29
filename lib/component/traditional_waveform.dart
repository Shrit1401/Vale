import 'dart:math';
import 'package:flutter/material.dart';

class TraditionalWaveform extends StatefulWidget {
  final bool isPlaying;
  final Color? color;
  final double? height;
  final int barCount;

  const TraditionalWaveform({
    super.key,
    required this.isPlaying,
    this.color,
    this.height,
    this.barCount = 50,
  });

  @override
  State<TraditionalWaveform> createState() => _TraditionalWaveformState();
}

class _TraditionalWaveformState extends State<TraditionalWaveform>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (widget.isPlaying) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(TraditionalWaveform oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPlaying != widget.isPlaying) {
      if (widget.isPlaying) {
        _animationController.repeat(reverse: true);
      } else {
        _animationController.stop();
        _animationController.reset();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<double> _generateWaveformData() {
    List<double> bars = [];
    for (int i = 0; i < widget.barCount; i++) {
      double baseHeight = _random.nextDouble() * 0.6 + 0.2;
      if (widget.isPlaying) {
        baseHeight *= (0.5 + 0.5 * sin(i * 0.3 + _animation.value * 2 * pi));
      }
      bars.add(baseHeight);
    }
    return bars;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height ?? 120,
      width: double.infinity,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final bars = _generateWaveformData();
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: bars.map((height) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 2),
                  width: 5,
                  height: height * (widget.height ?? 120),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        (widget.color ?? Color(0xFF1F5EFF)).withOpacity(0.9),
                        widget.color ?? Color(0xFF1F5EFF),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(2.5),
                    boxShadow: [
                      BoxShadow(
                        color: (widget.color ?? Color(0xFF1F5EFF)).withOpacity(
                          0.3,
                        ),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
