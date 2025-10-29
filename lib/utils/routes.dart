import 'package:flutter/material.dart';
import 'package:vale/pages/home/home_page.dart';
import 'package:vale/pages/journals/journal_page.dart';
import 'package:vale/pages/record/record_page.dart';
import 'package:vale/pages/stats/stats_page.dart';

class ValeRoutes {
  static String homeRoute = "/home";
  static String recordRoute = "/record";
  static String journalRoute = "/journal";
  static String statsRoute = "/stats";
}

final Map<String, Widget Function(BuildContext)> valeRouters = {
  ValeRoutes.homeRoute: (context) => const HomePage(),
  ValeRoutes.recordRoute: (context) => const RecordPage(),
  ValeRoutes.journalRoute: (context) => const JournalsPage(),
  ValeRoutes.statsRoute: (context) => const StatsPage(),
};
