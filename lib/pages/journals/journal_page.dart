import 'package:flutter/material.dart';
import 'package:vale/pages/record/record_page.dart';
import 'package:vale/utils/hive/hive_local.dart';
import 'package:vale/utils/routes.dart';
import 'package:vale/utils/types/journal.dart';

class JournalsPage extends StatefulWidget {
  const JournalsPage({super.key});

  @override
  State<JournalsPage> createState() => _JournalsPageState();
}

class _JournalsPageState extends State<JournalsPage> {
  bool _isLoading = true;
  List<Journal> _journals = [];

  String _formatDuration(int durationInSeconds) {
    final hours = durationInSeconds ~/ 3600;
    final minutes = (durationInSeconds % 3600) ~/ 60;
    final seconds = durationInSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final journalDate = DateTime(date.year, date.month, date.day);

    if (journalDate == today) {
      return 'Today';
    } else if (journalDate == today.subtract(Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${date.day} ${_getMonthName(date.month)} ${date.year}';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'jan',
      'feb',
      'mar',
      'apr',
      'may',
      'jun',
      'jul',
      'aug',
      'sep',
      'oct',
      'nov',
      'dec',
    ];
    return months[month - 1];
  }

  Future<void> _getJournals() async {
    if (!mounted) return;

    try {
      final journals = await HiveLocal.getAllJournals();
      journals.sort((a, b) => b.date.compareTo(a.date));

      if (mounted) {
        setState(() {
          _journals = journals;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _getJournals();
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
              IconButton(
                icon: Icon(Icons.mic, size: 44, color: Colors.black),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, ValeRoutes.homeRoute);
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.auto_awesome_outlined,
                  size: 44,
                  color: Colors.black,
                ),
                onPressed: () {
                  Navigator.pushReplacementNamed(
                    context,
                    ValeRoutes.journalRoute,
                  );
                },
              ),
            ],
          ),
        ),
      ),

      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.black))
          : _journals.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.mic_none, size: 64, color: Colors.grey[400]),
                  SizedBox(height: 16),
                  Text(
                    'No journals yet',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Start recording to create your first journal',
                    style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                  ),
                ],
              ),
            )
          : CustomScrollView(
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
                    final journal = _journals[index];
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  RecordPage(journal: journal),
                            ),
                          );
                        },
                        title: Text(
                          journal.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 21,
                            color: Colors.black,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            _formatDate(journal.date),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        trailing: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _formatDuration(journal.durationInSeconds),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  }, childCount: _journals.length),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
    );
  }
}
