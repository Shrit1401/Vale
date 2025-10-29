import 'dart:math';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class MinimalAudioWaveform extends StatefulWidget {
  final AudioPlayer? audioPlayer;
  final Color color;
  final double height;
  final int itemCount;

  const MinimalAudioWaveform({
    super.key,
    required this.audioPlayer,
    this.color = Colors.black,
    this.height = 56,
    this.itemCount = 96,
  });

  @override
  State<MinimalAudioWaveform> createState() => _MinimalAudioWaveformState();
}

enum _WaveItemType { dot, short, medium, tall }

class _MinimalAudioWaveformState extends State<MinimalAudioWaveform>
    with TickerProviderStateMixin {
  late AnimationController _tick;
  late Animation<double> _anim;
  Duration? _duration;
  Duration _position = Duration.zero;
  late List<_WaveItemType> _pattern;
  final ScrollController _scrollController = ScrollController();
  double _viewportWidth = 0;

  @override
  void initState() {
    super.initState();
    _tick = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 120),
    );
    _anim = CurvedAnimation(parent: _tick, curve: Curves.easeInOut);
    _setupAudioListeners();
    _pattern = _buildPattern(widget.itemCount);
    _tick.addListener(() {
      _autoScroll();
    });
  }

  List<_WaveItemType> _buildPattern(int count) {
    final rnd = Random(42);
    final list = <_WaveItemType>[];
    for (int i = 0; i < count; i++) {
      if (i % 7 == 0) {
        list.add(_WaveItemType.tall);
      } else if (i % 7 == 3) {
        list.add(_WaveItemType.medium);
      } else if (i % 7 == 5) {
        list.add(_WaveItemType.short);
      } else {
        list.add(rnd.nextBool() ? _WaveItemType.dot : _WaveItemType.short);
      }
    }
    return list;
  }

  void _setupAudioListeners() {
    widget.audioPlayer?.durationStream.listen((d) {
      setState(() {
        _duration = d;
      });
    });

    widget.audioPlayer?.positionStream.listen((p) {
      setState(() {
        _position = p;
      });
      _autoScroll();
    });

    widget.audioPlayer?.playerStateStream.listen((state) {
      if (state.playing) {
        _tick.repeat();
      } else {
        _tick.stop();
      }
    });
  }

  @override
  void didUpdateWidget(MinimalAudioWaveform oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.audioPlayer != widget.audioPlayer) {
      _setupAudioListeners();
    }
  }

  @override
  void dispose() {
    _tick.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _autoScroll({double? contentWidth}) {
    final totalMs = _duration?.inMilliseconds ?? 0;
    if (totalMs <= 0) return;
    final progress = _position.inMilliseconds / totalMs;
    final cw = contentWidth ?? _computedContentWidth();
    if (cw <= 0 || _viewportWidth <= 0) return;
    final maxScroll = (cw - _viewportWidth).clamp(0.0, double.infinity);
    double target = progress * cw - _viewportWidth / 2;
    target = target.clamp(0.0, maxScroll);
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        target,
        duration: Duration(milliseconds: 120),
        curve: Curves.linear,
      );
    }
  }

  double _computedContentWidth() {
    const double maxPillWidth = 6.0;
    const double spacing = 10.0;
    return _pattern.length * (spacing + maxPillWidth);
  }

  @override
  Widget build(BuildContext context) {
    final h = widget.height;
    final double maxPillWidth = 6.0;
    final double spacing = 10.0;
    final double contentWidth = _pattern.length * (spacing + maxPillWidth);

    return LayoutBuilder(
      builder: (context, constraints) {
        _viewportWidth = constraints.maxWidth;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _autoScroll(contentWidth: contentWidth);
        });

        return SizedBox(
          height: h,
          width: double.infinity,
          child: AnimatedBuilder(
            animation: _anim,
            builder: (context, _) {
              final totalMs = _duration?.inMilliseconds ?? 0;
              final posMs = _position.inMilliseconds;
              final progress = totalMs > 0 ? posMs / totalMs : 0.0;

              return SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: contentWidth,
                  height: h,
                  child: CustomPaint(
                    size: Size(contentWidth, h),
                    painter: _MinimalWavePainter(
                      pattern: _pattern,
                      progress: progress,
                      color: widget.color,
                      animValue: _anim.value,
                      maxHeight: h,
                      spacing: spacing,
                      maxPillWidth: maxPillWidth,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _MinimalWavePainter extends CustomPainter {
  final List<_WaveItemType> pattern;
  final double progress;
  final Color color;
  final double animValue;
  final double maxHeight;
  final double spacing;
  final double maxPillWidth;

  _MinimalWavePainter({
    required this.pattern,
    required this.progress,
    required this.color,
    required this.animValue,
    required this.maxHeight,
    required this.spacing,
    required this.maxPillWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;
    double x = 0;
    final Paint paint = Paint()..isAntiAlias = true;

    for (int i = 0; i < pattern.length; i++) {
      final item = pattern[i];
      final itemPos = i / pattern.length;
      final isPast = itemPos <= progress;
      final proximity = (itemPos - progress).abs();
      final double opacity = isPast ? 1.0 : 0.45;
      paint.color = color.withOpacity(opacity);

      if (item == _WaveItemType.dot) {
        final double sizeDot = 3.5 + max(0.0, 2.0 * (0.15 - proximity));
        canvas.drawCircle(
          Offset(x + maxPillWidth / 2, centerY),
          sizeDot / 2,
          paint,
        );
        x += spacing + maxPillWidth;
        continue;
      }

      double baseFactor;
      double pillWidth;
      switch (item) {
        case _WaveItemType.short:
          baseFactor = 0.28;
          pillWidth = 4.0;
          break;
        case _WaveItemType.medium:
          baseFactor = 0.48;
          pillWidth = 5.0;
          break;
        case _WaveItemType.tall:
          baseFactor = 0.88;
          pillWidth = 6.0;
          break;
        case _WaveItemType.dot:
          baseFactor = 0.0;
          pillWidth = 0.0;
          break;
      }

      final pulse = 1.0;
      final proximityBoost = 1.0 + max(0.0, 0.5 * (0.18 - proximity));
      final pillHeight = (maxHeight * baseFactor * pulse * proximityBoost)
          .clamp(4.0, maxHeight - 4.0);

      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(x + maxPillWidth / 2, centerY),
          width: pillWidth,
          height: pillHeight,
        ),
        Radius.circular(pillWidth / 2),
      );
      canvas.drawRRect(rect, paint);

      x += spacing + maxPillWidth;
    }
  }

  @override
  bool shouldRepaint(covariant _MinimalWavePainter oldDelegate) {
    return oldDelegate.pattern != pattern ||
        oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.animValue != animValue ||
        oldDelegate.maxHeight != maxHeight;
  }
}
