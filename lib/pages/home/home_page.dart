import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:vale/component/waveform.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isRecording = false;
  String? recordingFilePath;
  final AudioRecorder audioRecorder = AudioRecorder();

  @override
  void dispose() {
    audioRecorder.dispose();
    super.dispose();
  }

  void handleRecording() async {
    if (isRecording) {
      String? filePath = await audioRecorder.stop();
      if (filePath != null) {
        setState(() {
          isRecording = false;
          recordingFilePath = filePath;
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

      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: 24), // added padding from bottom
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.only(left: 22, right: 22, bottom: 8, top: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.history, size: 44, color: Colors.white),
              Icon(Icons.auto_awesome_outlined, size: 44, color: Colors.white),
            ],
          ),
        ),
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
