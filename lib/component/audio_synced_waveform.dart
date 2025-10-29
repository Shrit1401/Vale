import 'dart:math';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioSyncedWaveform extends StatefulWidget {
  final AudioPlayer? audioPlayer;
  final Color? color;
  final double? height;
  final int barCount;

  const AudioSyncedWaveform({
    super.key,
    this.audioPlayer,
    this.color,
    this.height,
    this.barCount = 60,
  });

  @override
  State<AudioSyncedWaveform> createState() => _AudioSyncedWaveformState();
}

class _AudioSyncedWaveformState extends State<AudioSyncedWaveform>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  Duration? _duration;
  Duration _position = Duration.zero;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 100),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _setupAudioListener();
  }

  void _setupAudioListener() {
    widget.audioPlayer?.durationStream.listen((duration) {
      setState(() {
        _duration = duration;
      });
    });

    widget.audioPlayer?.positionStream.listen((position) {
      setState(() {
        _position = position;
      });
    });

    widget.audioPlayer?.playerStateStream.listen((state) {
      if (state.playing) {
        _animationController.repeat();
      } else {
        _animationController.stop();
      }
    });
  }

  @override
  void didUpdateWidget(AudioSyncedWaveform oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.audioPlayer != widget.audioPlayer) {
      _setupAudioListener();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<double> _generateWaveformData() {
    List<double> bars = [];
    bool isPlaying = widget.audioPlayer?.playing ?? false;

    for (int i = 0; i < widget.barCount; i++) {
      double progress = _duration != null && _duration!.inMilliseconds > 0
          ? _position.inMilliseconds / _duration!.inMilliseconds
          : 0.0;

      double barPosition = i / widget.barCount;

      double baseHeight;
      if (isPlaying) {
        double distanceFromCurrent = (barPosition - progress).abs();
        if (distanceFromCurrent < 0.1) {
          baseHeight = _random.nextDouble() * 0.8 + 0.2;
        } else if (distanceFromCurrent < 0.2) {
          baseHeight = _random.nextDouble() * 0.6 + 0.1;
        } else {
          baseHeight = _random.nextDouble() * 0.3 + 0.05;
        }

        if (barPosition <= progress) {
          baseHeight *= (0.7 + 0.3 * sin(_animation.value * 2 * pi));
        }
      } else {
        if (barPosition <= progress) {
          baseHeight = _random.nextDouble() * 0.4 + 0.1;
        } else {
          baseHeight = _random.nextDouble() * 0.2 + 0.05;
        }
      }

      bars.add(baseHeight.clamp(0.05, 1.0));
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
              children: bars.asMap().entries.map((entry) {
                int index = entry.key;
                double height = entry.value;
                double progress =
                    _duration != null && _duration!.inMilliseconds > 0
                    ? _position.inMilliseconds / _duration!.inMilliseconds
                    : 0.0;
                double barPosition = index / widget.barCount;

                Color barColor = widget.color ?? Color(0xFF1F5EFF);
                if (barPosition <= progress) {
                  barColor = barColor.withOpacity(1.0);
                } else {
                  barColor = barColor.withOpacity(0.3);
                }

                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 2),
                  width: 5,
                  height: height * (widget.height ?? 120),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [barColor.withOpacity(0.9), barColor],
                    ),
                    borderRadius: BorderRadius.circular(2.5),
                    boxShadow: [
                      BoxShadow(
                        color: barColor.withOpacity(0.3),
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
