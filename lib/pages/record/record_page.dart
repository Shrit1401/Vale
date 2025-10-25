import 'package:flutter/material.dart';

class RecordPage extends StatelessWidget {
  const RecordPage({super.key});

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
                  'journal #01',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                Center(
                  child: Text(
                    '24 oct 25',
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
                  '00:00:00',
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
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Color(0xFF1F5EFF), width: 8),
              ),
              child: Center(
                child: Container(
                  width: 33,
                  height: 33,
                  decoration: BoxDecoration(
                    color: Color(0xFF1F5EFF),
                    borderRadius: BorderRadius.circular(8),
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
