import 'package:flutter/material.dart';
import 'package:vale/utils/types/journal.dart';
import 'package:just_audio/just_audio.dart';

class RecordPage extends StatefulWidget {
  final Journal? journal;
  const RecordPage({super.key, this.journal});

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  AudioPlayer? _audioPlayer;
  bool _isPlaying = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer!.playerStateStream.listen((state) {
      setState(() {
        _isPlaying = state.playing;
        _isLoading = state.processingState == ProcessingState.loading;

        if (state.processingState == ProcessingState.completed) {
          _isPlaying = false;
        }
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer?.dispose();
    super.dispose();
  }

  Future<void> _togglePlayback() async {
    if (widget.journal == null || _audioPlayer == null) return;

    try {
      if (_isPlaying) {
        await _audioPlayer!.pause();
      } else {
        if (_audioPlayer!.audioSource == null) {
          await _audioPlayer!.setFilePath(widget.journal!.path);
        }
        await _audioPlayer!.play();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error playing audio: $e')));
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red, size: 32),
            onPressed: () {},
            splashRadius: 24,
          ),
        ],
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 32),
          onPressed: () {
            Navigator.of(context).maybePop();
          },
          splashRadius: 24,
        ),

        title: Text(
          'vale.',
          style: TextStyle(
            color: Colors.black,
            fontSize: 31,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: 24), // added padding from bottom
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.only(left: 22, right: 22, bottom: 8, top: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.history, size: 44, color: Colors.black),
              Icon(Icons.auto_awesome_outlined, size: 44, color: Colors.black),
            ],
          ),
        ),
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 40.0, left: 18.0, right: 18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  widget.journal?.title ?? 'Untitled',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                Center(
                  child: Text(
                    widget.journal != null
                        ? '${widget.journal!.date.day} '
                              '${_getMonthName(widget.journal!.date.month)} '
                              "${widget.journal!.date.year.toString().substring(2)}"
                        : 'Untitled',
                    style: TextStyle(
                      fontSize: 21,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 100),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(child: Image.asset('images/soundwavewhite.png')),
          ),

          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Color(0xFF1F5EFF),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 6),
                Text(
                  widget.journal != null
                      ? '${(widget.journal!.durationInSeconds ~/ 60).toString().padLeft(2, '0')}:${(widget.journal!.durationInSeconds % 60).toString().padLeft(2, '0')}'
                      : '00:00',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),

          Spacer(),

          Center(
            child: GestureDetector(
              onTap: _togglePlayback,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Color(0xFF1F5EFF), width: 8),
                ),
                child: Center(
                  child: _isLoading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF1F5EFF),
                            ),
                          ),
                        )
                      : Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Color(0xFF1F5EFF),
                          size: 33,
                        ),
                ),
              ),
            ),
          ),
          SizedBox(height: 40),
        ],
      ),
    );
  }
}
