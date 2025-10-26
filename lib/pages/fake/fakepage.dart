import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class RecordingItem {
  final String id;
  final String filePath;
  final String name;
  final DateTime createdAt;
  final Duration? duration;

  RecordingItem({
    required this.id,
    required this.filePath,
    required this.name,
    required this.createdAt,
    this.duration,
  });
}

class FakeRecorderPage extends StatefulWidget {
  const FakeRecorderPage({super.key});

  @override
  State<FakeRecorderPage> createState() => _FakeRecorderPageState();
}

class _FakeRecorderPageState extends State<FakeRecorderPage> {
  final AudioRecorder audioRecorder = AudioRecorder();
  final AudioPlayer audioPlayer = AudioPlayer();

  List<RecordingItem> recordings = [];
  String? currentRecordingPath;
  bool isRecording = false;
  String? currentlyPlayingId;
  @override
  Widget build(BuildContext context) {
    return Scaffold(floatingActionButton: _recordingButton(), body: _buildUI());
  }

  Widget _buildUI() {
    return Container(
      width: MediaQuery.sizeOf(context).width,
      height: MediaQuery.sizeOf(context).height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.secondary.withOpacity(0.05),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              _buildHeader(),
              const SizedBox(height: 40),
              _buildRecordingStatus(),
              const SizedBox(height: 30),
              if (recordings.isNotEmpty) _buildRecordingsList(),
              const Spacer(),
              _buildInstructions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Icon(
            Icons.mic,
            size: 60,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Voice Recorder',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tap the mic to start recording',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildRecordingStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: isRecording
            ? Colors.red.withOpacity(0.1)
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRecording
              ? Colors.red.withOpacity(0.3)
              : Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: isRecording ? Colors.red : Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            isRecording ? 'Recording...' : 'Ready to record',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: isRecording
                  ? Colors.red
                  : Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingsList() {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Recordings',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: recordings.length,
              itemBuilder: (context, index) {
                final recording = recordings[index];
                final isPlaying = currentlyPlayingId == recording.id;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.shadow.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: isPlaying
                            ? Colors.red.withOpacity(0.1)
                            : Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Icon(
                        isPlaying ? Icons.stop : Icons.play_arrow,
                        color: isPlaying
                            ? Colors.red
                            : Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                    ),
                    title: Text(
                      recording.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Created: ${_formatDateTime(recording.createdAt)}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.6),
                              ),
                        ),
                        if (recording.duration != null)
                          Text(
                            'Duration: ${_formatDuration(recording.duration!)}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.6),
                                ),
                          ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => _playRecording(recording),
                          icon: Icon(
                            isPlaying ? Icons.stop : Icons.play_arrow,
                            color: isPlaying
                                ? Colors.red
                                : Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        IconButton(
                          onPressed: () => _deleteRecording(recording),
                          icon: Icon(
                            Icons.delete,
                            color: Colors.red.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.info_outline,
            size: 20,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          const SizedBox(width: 8),
          Text(
            'Use the floating mic button to record',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _recordingButton() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: isRecording
                ? Colors.red.withOpacity(0.4)
                : Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () async {
          if (isRecording) {
            String? filePath = await audioRecorder.stop();

            if (filePath != null) {
              final recording = RecordingItem(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                filePath: filePath,
                name: 'Recording ${recordings.length + 1}',
                createdAt: DateTime.now(),
              );

              setState(() {
                isRecording = false;
                currentRecordingPath = null;
                recordings.add(recording);
              });
            }
          } else {
            if (await audioRecorder.hasPermission()) {
              final Directory appDocsDir =
                  await getApplicationDocumentsDirectory();
              final String timestamp = DateTime.now().millisecondsSinceEpoch
                  .toString();
              final String filePath = p.join(
                appDocsDir.path,
                "recording_$timestamp.wav",
              );

              await audioRecorder.start(const RecordConfig(), path: filePath);
              setState(() {
                isRecording = true;
                currentRecordingPath = filePath;
              });
            }
          }
        },
        backgroundColor: isRecording
            ? Colors.red
            : Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            isRecording ? Icons.stop : Icons.mic,
            key: ValueKey(isRecording),
            size: 28,
          ),
        ),
      ),
    );
  }

  void _playRecording(RecordingItem recording) async {
    if (currentlyPlayingId == recording.id) {
      await audioPlayer.stop();
      setState(() {
        currentlyPlayingId = null;
      });
    } else {
      await audioPlayer.stop();
      await audioPlayer.setFilePath(recording.filePath);
      await audioPlayer.play();
      setState(() {
        currentlyPlayingId = recording.id;
      });
    }
  }

  void _deleteRecording(RecordingItem recording) async {
    try {
      final file = File(recording.filePath);
      if (await file.exists()) {
        await file.delete();
      }

      if (currentlyPlayingId == recording.id) {
        await audioPlayer.stop();
        currentlyPlayingId = null;
      }

      setState(() {
        recordings.removeWhere((r) => r.id == recording.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Recording deleted'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete recording'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
