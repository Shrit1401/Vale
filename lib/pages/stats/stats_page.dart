import 'package:flutter/material.dart';
import 'package:vale/utils/routes.dart';
import 'package:vale/utils/hive/db_services.dart';
import 'package:vale/utils/types/journal.dart';
import 'dart:math' as math;
import 'package:vale/component/black_animated_bottom_nav.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  Future<List<Journal>>? _futureJournals;

  @override
  void initState() {
    super.initState();
    _futureJournals = DatabaseService.getAllJournals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
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
        currentIndex: 2,
        onTap: (i) {
          if (i == 0) {
            Navigator.pushReplacementNamed(context, ValeRoutes.homeRoute);
          } else if (i == 1) {
            Navigator.pushReplacementNamed(context, ValeRoutes.journalRoute);
          }
        },
      ),
      body: FutureBuilder<List<Journal>>(
        future: _futureJournals,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: Color(0xFF1F5EFF)),
            );
          }
          final journals = (snapshot.data ?? [])
            ..sort((a, b) => a.date.compareTo(b.date));
          if (journals.isEmpty) {
            return _EmptyState();
          }
          final totals = _computeTotals(journals);
          final last30 = _entriesLastNDays(journals, 30);
          final weekly = _durationsByWeek(journals, 8);
          final emotions = _emotionDistribution(journals);
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _HeaderStats(
                  totalEntries: totals.totalEntries,
                  totalMinutes: totals.totalMinutes,
                  avgMinutes: totals.avgMinutes,
                  streakDays: totals.streakDays,
                ),
                SizedBox(height: 16),
                _CardSection(
                  title: 'Entries last 30 days',
                  child: SizedBox(height: 180, child: _LineChart(data: last30)),
                ),
                SizedBox(height: 12),
                _CardSection(
                  title: 'Weekly recording minutes',
                  child: SizedBox(height: 180, child: _BarChart(data: weekly)),
                ),
                SizedBox(height: 12),
                _CardSection(
                  title: 'Emotion distribution',
                  child: SizedBox(
                    height: 220,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: _PieChart(
                            slices: emotions.entries
                                .map(
                                  (e) =>
                                      _PieSlice(label: e.key, value: e.value),
                                )
                                .toList(),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(flex: 4, child: _Legend(emotions: emotions)),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  _Totals _computeTotals(List<Journal> journals) {
    final totalEntries = journals.length;
    final totalMinutes = journals.fold<int>(
      0,
      (s, j) => s + (j.durationInSeconds ~/ 60),
    );
    final avgMinutes = totalEntries == 0
        ? 0
        : (totalMinutes / totalEntries).round();
    final streakDays = _currentStreakDays(journals);
    return _Totals(
      totalEntries: totalEntries,
      totalMinutes: totalMinutes,
      avgMinutes: avgMinutes,
      streakDays: streakDays,
    );
  }

  int _currentStreakDays(List<Journal> journals) {
    if (journals.isEmpty) return 0;
    final byDay = <DateTime, int>{};
    for (final j in journals) {
      final d = DateTime(j.date.year, j.date.month, j.date.day);
      byDay[d] = (byDay[d] ?? 0) + 1;
    }
    var streak = 0;
    var day = DateTime.now();
    while (true) {
      final key = DateTime(day.year, day.month, day.day);
      if ((byDay[key] ?? 0) > 0) {
        streak += 1;
        day = day.subtract(Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  List<double> _entriesLastNDays(List<Journal> journals, int n) {
    final start = DateTime.now().subtract(Duration(days: n - 1));
    final map = <DateTime, int>{};
    for (int i = 0; i < n; i++) {
      final d = DateTime(
        start.year,
        start.month,
        start.day,
      ).add(Duration(days: i));
      map[d] = 0;
    }
    for (final j in journals) {
      final d = DateTime(j.date.year, j.date.month, j.date.day);
      if (!d.isBefore(start)) {
        map[d] = (map[d] ?? 0) + 1;
      }
    }
    return map.values.map((e) => e.toDouble()).toList();
  }

  List<double> _durationsByWeek(List<Journal> journals, int weeks) {
    final now = DateTime.now();
    final endOfThisWeek = now
        .add(Duration(days: 6 - now.weekday + 1))
        .subtract(
          Duration(
            hours: now.hour,
            minutes: now.minute,
            seconds: now.second,
            milliseconds: now.millisecond,
            microseconds: now.microsecond,
          ),
        );
    final data = List<double>.filled(weeks, 0);
    for (final j in journals) {
      final d = DateTime(j.date.year, j.date.month, j.date.day);
      final diffDays = endOfThisWeek.difference(d).inDays;
      final idx = diffDays ~/ 7;
      if (idx >= 0 && idx < weeks) {
        data[weeks - 1 - idx] += j.durationInSeconds / 60.0;
      }
    }
    return data.map((v) => double.parse(v.toStringAsFixed(1))).toList();
  }

  Map<String, double> _emotionDistribution(List<Journal> journals) {
    final map = <JournalEmotion, int>{};
    for (final e in JournalEmotion.values) {
      map[e] = 0;
    }
    for (final j in journals) {
      map[j.emotion] = (map[j.emotion] ?? 0) + 1;
    }
    final total = map.values.fold<int>(0, (s, v) => s + v);
    if (total == 0) return {};
    String label(JournalEmotion e) {
      switch (e) {
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
          return 'Neutral';
      }
    }

    final res = <String, double>{};
    map.forEach((k, v) {
      if (v > 0) {
        res[label(k)] = (v / total) * 100.0;
      }
    });
    return res;
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.bar_chart,
            size: 64,
            color: Color(0xFF1F5EFF).withOpacity(0.6),
          ),
          SizedBox(height: 12),
          Text(
            'No stats yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Record your first journal to see insights',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

class _HeaderStats extends StatelessWidget {
  final int totalEntries;
  final int totalMinutes;
  final int avgMinutes;
  final int streakDays;

  const _HeaderStats({
    required this.totalEntries,
    required this.totalMinutes,
    required this.avgMinutes,
    required this.streakDays,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatTile(label: 'Entries', value: totalEntries.toString()),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _StatTile(label: 'Minutes', value: totalMinutes.toString()),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _StatTile(label: 'Avg min', value: avgMinutes.toString()),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _StatTile(label: 'Streak', value: '${streakDays}d'),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;

  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Color(0xFF1F5EFF).withOpacity(0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Color(0xFF1F5EFF).withOpacity(0.7),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: Colors.black,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _CardSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.0),
        border: Border.all(color: Color(0xFF1F5EFF).withOpacity(0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _LineChart extends StatelessWidget {
  final List<double> data;

  const _LineChart({required this.data});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LineChartPainter(data: data, color: Color(0xFF1F5EFF)),
      child: Container(),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> data;
  final Color color;

  _LineChartPainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final maxV = data.isEmpty
        ? 1.0
        : data.reduce(math.max).clamp(1.0, double.infinity).toDouble();
    final path = Path();
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    final fillPaint = Paint()
      ..color = color.withOpacity(0.12)
      ..style = PaintingStyle.fill;

    final denom = (data.length - 1) <= 0 ? 1.0 : (data.length - 1).toDouble();
    final dx = size.width / denom;
    for (int i = 0; i < data.length; i++) {
      final x = dx * i;
      final y = size.height - (data[i] / maxV) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final gridPaint = Paint()
      ..color = Color(0xFF1F5EFF).withOpacity(0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (int i = 1; i <= 3; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _BarChart extends StatelessWidget {
  final List<double> data;

  const _BarChart({required this.data});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BarChartPainter(data: data, color: Color(0xFF1F5EFF)),
      child: Container(),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<double> data;
  final Color color;

  _BarChartPainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final maxV = data.isEmpty
        ? 1.0
        : data.reduce(math.max).clamp(1.0, double.infinity).toDouble();
    final barWidth = size.width / (data.length * 1.6);
    final gap = barWidth * 0.6;
    final paint = Paint()..color = color;
    final gridPaint = Paint()
      ..color = Color(0xFF1F5EFF).withOpacity(0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (int i = 1; i <= 3; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    for (int i = 0; i < data.length; i++) {
      final h = maxV == 0 ? 0.0 : (data[i] / maxV) * (size.height * 0.92);
      final x = i * (barWidth + gap) + gap;
      final r = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, size.height - h, barWidth, h),
        Radius.circular(6.0),
      );
      canvas.drawRRect(r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _PieSlice {
  final String label;
  final double value;
  _PieSlice({required this.label, required this.value});
}

class _PieChart extends StatelessWidget {
  final List<_PieSlice> slices;
  const _PieChart({required this.slices});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _PiePainter(
        slices: slices,
        palette: [
          Color(0xFF1F5EFF),
          Color(0xFF4A7CFF),
          Color(0xFF7BA3FF),
          Color(0xFFA8C7FF),
          Color(0xFFD1E0FF),
          Color(0xFFE8F0FF),
          Color(0xFFF0F5FF),
        ],
      ),
      child: Container(),
    );
  }
}

class _PiePainter extends CustomPainter {
  final List<_PieSlice> slices;
  final List<Color> palette;

  _PiePainter({required this.slices, required this.palette});

  @override
  void paint(Canvas canvas, Size size) {
    final total = slices.fold<double>(0, (s, e) => s + e.value);
    if (total <= 0) return;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2.2;
    double start = -math.pi / 2;
    for (int i = 0; i < slices.length; i++) {
      final sweep = (slices[i].value / total) * 2 * math.pi;
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = palette[i % palette.length];
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweep,
        true,
        paint,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _Legend extends StatelessWidget {
  final Map<String, double> emotions;
  const _Legend({required this.emotions});

  @override
  Widget build(BuildContext context) {
    final keys = emotions.keys.toList();
    final vals = emotions.values.toList();
    final colors = [
      Color(0xFF1F5EFF),
      Color(0xFF4A7CFF),
      Color(0xFF7BA3FF),
      Color(0xFFA8C7FF),
      Color(0xFFD1E0FF),
      Color(0xFFE8F0FF),
      Color(0xFFF0F5FF),
    ];
    return ListView.separated(
      itemCount: keys.length,
      physics: NeverScrollableScrollPhysics(),
      separatorBuilder: (_, __) => SizedBox(height: 8),
      itemBuilder: (context, index) {
        final c = colors[index % colors.length];
        return Row(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: c,
                borderRadius: BorderRadius.circular(4.0),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                keys[index],
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              '${vals[index].toStringAsFixed(0)}%',
              style: TextStyle(
                color: Color(0xFF1F5EFF).withOpacity(0.7),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Totals {
  final int totalEntries;
  final int totalMinutes;
  final int avgMinutes;
  final int streakDays;
  _Totals({
    required this.totalEntries,
    required this.totalMinutes,
    required this.avgMinutes,
    required this.streakDays,
  });
}
