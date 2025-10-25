import 'package:flutter/material.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'dart:math';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final List<String> quotes = [
    'One life, Play Hard',
    'Dream big, Start small',
    'Be bold, Be brave',
    'Live free, Love hard',
    'Stay hungry, Stay foolish',
    'Work smart, Play harder',
    'Think big, Act small',
    'Stay curious, Stay humble',
    'Be kind, Be fierce',
    'Rise up, Shine bright',
    'Stay strong, Stay true',
    'Be fearless, Be free',
    'Chase dreams, Catch stars',
    'Stay wild, Stay free',
    'Be brave, Be bold',
    'Live loud, Love deep',
    'Stay hungry, Stay humble',
    'Be fierce, Be free',
    'Dream wild, Live free',
    'Stay bold, Stay true',
  ];

  String getRandomQuote() {
    final random = Random();
    return quotes[random.nextInt(quotes.length)];
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

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 24.0, top: 32.0),

            child: Text(
              getRandomQuote(),
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
            child: Center(child: Image.asset('images/soundwaveblack.png')),
          ),
          Spacer(),
          // slide to start text
          Padding(
            padding: const EdgeInsets.only(
              bottom: 16.0,
              left: 16.0,
              right: 16.0,
            ),
            child: SlideAction(
              elevation: 0,
              innerColor: Colors.white,

              outerColor: const Color(0xFF1C1C1C),
              borderRadius: 18,

              text: "slide to record",
              textStyle: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
              onSubmit: () {
                print('submit');
                return null;
              },
            ),
          ),
          SizedBox(height: 12),
          // three dots indicator
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 12),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Color(0xFF1F5EFF),

                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 12),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 32),
        ],
      ),
    );
  }
}
