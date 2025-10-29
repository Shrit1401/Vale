import 'package:flutter/material.dart';
import 'package:vale/utils/hive/hive_local.dart';
import 'package:vale/utils/routes.dart';
import 'package:vale/utils/types/journal.dart';
import 'package:just_audio/just_audio.dart';
import 'package:vale/component/minimal_audio_waveform.dart';
import 'package:vale/component/black_animated_bottom_nav.dart';
// duplicate removed

class RecordPage extends StatefulWidget {
  final Journal? journal;
  const RecordPage({super.key, this.journal});

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _EmotionChip extends StatelessWidget {
  final JournalEmotion emotion;
  final String label;
  final String emoji;
  final bool selected;
  final VoidCallback onTap;

  const _EmotionChip({
    required this.emotion,
    required this.label,
    required this.emoji,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected ? Color(0xFFE8F0FF) : Colors.white;
    final border = selected ? Color(0xFF1F5EFF) : Colors.grey[300]!;
    final text = selected ? Color(0xFF1F5EFF) : Colors.black;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: TextStyle(fontSize: 16)),
              SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(color: text, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecordPageState extends State<RecordPage> {
  AudioPlayer? _audioPlayer;
  bool _isPlaying = false;
  bool _isLoading = false;
  JournalEmotion _selectedEmotion = JournalEmotion.defaultEmotion;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _selectedEmotion = _safeJournalEmotion(widget.journal);
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

  JournalEmotion _safeJournalEmotion(Journal? journal) {
    try {
      if (journal == null) return JournalEmotion.defaultEmotion;
      final value = journal.emotion; // may throw if legacy null
      return value;
    } catch (_) {
      return JournalEmotion.defaultEmotion;
    }
  }

  Future<void> _updateEmotion(JournalEmotion emotion) async {
    if (widget.journal == null) {
      return;
    }
    final updated = Journal(
      title: widget.journal!.title,
      date: widget.journal!.date,
      durationInSeconds: widget.journal!.durationInSeconds,
      path: widget.journal!.path,
      emotion: emotion,
    );
    await HiveLocal.saveJournal(updated);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Emotion updated')));
    }
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
        if (_audioPlayer!.audioSource == null ||
            _audioPlayer!.playerState.processingState ==
                ProcessingState.completed) {
          await _audioPlayer!.setFilePath(widget.journal!.path);
        }
        await _audioPlayer!.play();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error playing audio: $e')));
      }
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

  String _emotionLabel(JournalEmotion emotion) {
    switch (emotion) {
      case JournalEmotion.happy:
        return 'Happy';
      case JournalEmotion.sad:
        return 'Sad';
      case JournalEmotion.angry:
        return 'Angry';
      case JournalEmotion.anxious:
        return 'Anxious';
      case JournalEmotion.excited:
        return 'Excited';
      case JournalEmotion.peaceful:
        return 'Peaceful';
      case JournalEmotion.defaultEmotion:
        return 'Emotion';
    }
  }

  String _emotionEmoji(JournalEmotion emotion) {
    switch (emotion) {
      case JournalEmotion.happy:
        return '😊';
      case JournalEmotion.sad:
        return '😢';
      case JournalEmotion.angry:
        return '😠';
      case JournalEmotion.anxious:
        return '😰';
      case JournalEmotion.excited:
        return '🤩';
      case JournalEmotion.peaceful:
        return '🧘';
      case JournalEmotion.defaultEmotion:
        return '🙂';
    }
  }

  // removed unused helpers

  void _deleteJournal() {
    HiveLocal.deleteJournal(widget.journal!.path);
    if (mounted) {
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(ValeRoutes.journalRoute, (route) => false);
    }
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Journal deleted')));
    }
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
            onPressed: () async {
              final result = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Delete Journal?'),
                  content: Text(
                    'Are you sure you want to delete this journal entry? This action cannot be undone.',
                  ),
                  actions: [
                    TextButton(
                      child: Text('Cancel'),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                    TextButton(
                      child: Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                      onPressed: () => {_deleteJournal()},
                    ),
                  ],
                ),
              );

              if (result == true) {
                _deleteJournal();
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              }
            },
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

      bottomNavigationBar: BlackAnimatedBottomNav(
        currentIndex: 1,
        onTap: (i) {
          if (i == 0) {
            Navigator.pushReplacementNamed(context, ValeRoutes.homeRoute);
          } else if (i == 1) {
            Navigator.pushReplacementNamed(context, ValeRoutes.journalRoute);
          } else if (i == 2) {
            Navigator.pushReplacementNamed(context, ValeRoutes.statsRoute);
          }
        },
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
                SizedBox(height: 18),
                Align(
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Text(
                        'what was your emotion in this moment?',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: [
                            for (final e in const [
                              JournalEmotion.happy,
                              JournalEmotion.excited,
                              JournalEmotion.peaceful,
                              JournalEmotion.anxious,
                              JournalEmotion.sad,
                              JournalEmotion.angry,
                            ])
                              _EmotionChip(
                                emotion: e,
                                selected: _selectedEmotion == e,
                                label: _emotionLabel(e),
                                emoji: _emotionEmoji(e),
                                onTap: () async {
                                  setState(() {
                                    _selectedEmotion = e;
                                  });
                                  await _updateEmotion(e);
                                },
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 100),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: MinimalAudioWaveform(
                audioPlayer: _audioPlayer,
                color: Colors.black,
                height: 56,
                itemCount: 110,
              ),
            ),
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
                          size: 70,
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
