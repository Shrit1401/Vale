import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:waveform_flutter/waveform_flutter.dart';

class WaveFormGenerate extends StatefulWidget {
  final bool isRecording;
  const WaveFormGenerate({super.key, required this.isRecording});

  @override
  State<WaveFormGenerate> createState() => _WaveFormGenerateState();
}

class _WaveFormGenerateState extends State<WaveFormGenerate> {
  late StreamController<Amplitude> _amplitudeController;
  Timer? _timer;
  final Random _random = Random();
  double _baseAmplitude = 0.0;

  @override
  void initState() {
    super.initState();
    _amplitudeController = StreamController<Amplitude>.broadcast();
    _startAmplitudeGeneration();
  }

  @override
  void didUpdateWidget(WaveFormGenerate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isRecording != widget.isRecording) {
      _startAmplitudeGeneration();
    }
  }

  void _startAmplitudeGeneration() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(milliseconds: 50), (timer) {
      if (widget.isRecording) {
        _baseAmplitude = _random.nextDouble() * 80 + 20;
      } else {
        _baseAmplitude *= 0.9;
        if (_baseAmplitude < 5) _baseAmplitude = 0;
      }

      if (!_amplitudeController.isClosed) {
        _amplitudeController.add(Amplitude(current: _baseAmplitude, max: 100));
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _amplitudeController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      width: double.infinity,
      child: AnimatedWaveList(
        stream: _amplitudeController.stream,
        barBuilder: (animation, amplitude) => WaveFormBar(
          animation: animation,
          amplitude: amplitude,
          color: widget.isRecording ? Colors.white : Colors.white.withAlpha(77),
        ),
      ),
    );
  }
}
