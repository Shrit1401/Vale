import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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

      body: Padding(
        padding: const EdgeInsets.only(left: 24.0, top: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'One life, Play Hard',
              style: TextStyle(
                color: Colors.white,
                fontSize: 50,
                overflow: TextOverflow.clip,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
