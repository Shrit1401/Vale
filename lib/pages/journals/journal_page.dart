import 'package:flutter/material.dart';

class JournalsPage extends StatelessWidget {
  const JournalsPage({super.key});

  Map<String, String> _getJournalData(int index) {
    final journals = [
      {'title': 'journal #1', 'date': 'Today', 'duration': '00:05'},
      {'title': 'journal #2', 'date': '22 oct 25', 'duration': '20:05'},
      {'title': 'journal #3', 'date': '21 oct 25', 'duration': '15:30'},
      {'title': 'journal #4', 'date': '20 oct 25', 'duration': '08:45'},
      {'title': 'journal #5', 'date': '19 oct 25', 'duration': '12:20'},
      {'title': 'journal #6', 'date': '18 oct 25', 'duration': '06:15'},
      {'title': 'journal #7', 'date': '17 oct 25', 'duration': '18:40'},
      {'title': 'journal #8', 'date': '16 oct 25', 'duration': '09:25'},
      {'title': 'journal #9', 'date': '15 oct 25', 'duration': '14:10'},
      {'title': 'journal #10', 'date': '14 oct 25', 'duration': '11:35'},
      {'title': 'journal #11', 'date': '13 oct 25', 'duration': '07:50'},
      {'title': 'journal #12', 'date': '12 oct 25', 'duration': '16:30'},
      {'title': 'journal #13', 'date': '11 oct 25', 'duration': '13:45'},
      {'title': 'journal #14', 'date': '10 oct 25', 'duration': '05:20'},
      {'title': 'journal #15', 'date': '09 oct 25', 'duration': '19:15'},
    ];
    return journals[index % journals.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,

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

      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 30.0,
                left: 0.0,
                right: 0.0,
                bottom: 16.0,
              ),
              child: Center(
                child: Text(
                  'journals',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final journalData = _getJournalData(index);
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  onTap: () {
                    // Handle journal tap
                  },
                  title: Text(
                    journalData['title']!,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 21,
                      color: Colors.black,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      journalData['date']!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  trailing: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      journalData['duration']!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            }, childCount: 15),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
