import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:vale/component/waveform.dart';
import 'package:vale/component/black_animated_bottom_nav.dart';
import 'package:vale/utils/hive/hive_local.dart';
import 'package:vale/utils/routes.dart';
import 'package:vale/utils/types/journal.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isRecording = false;
  String? recordingFilePath;
  final AudioRecorder audioRecorder = AudioRecorder();
  DateTime? recordingStartTime;
  int recordingDurationInSeconds = 0;

  @override
  void dispose() {
    audioRecorder.dispose();
    super.dispose();
  }

  Future<String> _generateJournalTitle() async {
    final journals = await HiveLocal.getAllJournals();
    final nextNumber = journals.length + 1;
    return 'journal#${nextNumber.toString().padLeft(2, '0')}';
  }

  Future<void> saveJournal(String path, int durationInSeconds) async {
    final title = await _generateJournalTitle();
    final journal = Journal(
      title: title,
      date: DateTime.now(),
      path: path,
      durationInSeconds: durationInSeconds,
      emotion: JournalEmotion.defaultEmotion,
    );
    await HiveLocal.saveJournal(journal);
  }

  void handleRecording() async {
    if (isRecording) {
      String? filePath = await audioRecorder.stop();
      if (filePath != null) {
        if (recordingStartTime != null) {
          recordingDurationInSeconds = DateTime.now()
              .difference(recordingStartTime!)
              .inSeconds;
          await saveJournal(filePath, recordingDurationInSeconds);
        }

        setState(() {
          isRecording = false;
          recordingFilePath = filePath;
          recordingStartTime = null;
        });
      }
    } else {
      if (await audioRecorder.hasPermission()) {
        final Directory appDocsDir = await getApplicationDocumentsDirectory();
        final String timestamp = DateTime.now().millisecondsSinceEpoch
            .toString();
        final String filePath = p.join(
          appDocsDir.path,
          "recording_$timestamp.wav",
        );

        await audioRecorder.start(const RecordConfig(), path: filePath);

        setState(() {
          isRecording = true;
          recordingFilePath = null;
          recordingStartTime = DateTime.now();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        title: Text('vale.'),
        backgroundColor: Colors.black,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 31,
          fontWeight: FontWeight.w700,
        ),
      ),

      bottomNavigationBar: BlackAnimatedBottomNav(
        currentIndex: 0,
        onTap: (i) {
          if (i == 1) {
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
            padding: const EdgeInsets.only(left: 24.0, top: 32.0),

            child: Text(
              "Nothing Matters",
              style: TextStyle(
                color: Colors.white,
                fontSize: 50,
                overflow: TextOverflow.clip,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          SizedBox(height: 8),
          // image centered
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(child: WaveFormGenerate(isRecording: isRecording)),
          ),
          Spacer(),
          // play/pause button
          Padding(
            padding: const EdgeInsets.only(
              bottom: 16.0,
              left: 16.0,
              right: 16.0,
            ),
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: !isRecording ? Color(0xFF1C1C1C) : Color(0xFF1F5EFF),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: handleRecording,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isRecording ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 32,
                      ),
                      SizedBox(width: 12),
                      Text(
                        isRecording ? "pause recording" : "start recording",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // three dots indicator
        ],
      ),
    );
  }
}
