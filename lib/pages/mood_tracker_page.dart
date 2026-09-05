import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

enum MoodPeriod {
  sevenDays,
  thirtyDays,
  allTime,
}

class MoodTrackPage extends StatefulWidget {
  const MoodTrackPage({super.key});

  @override
  State<MoodTrackPage> createState() => _MoodTrackPageState();
}

class _MoodTrackPageState extends State<MoodTrackPage> {
  final List<_MoodDefinition> _moods = const [
    _MoodDefinition(
      category: 'Excited',
      score: 5,
      color: Colors.orangeAccent,
      emoji: '🤩',
    ),
    _MoodDefinition(
      category: 'Happy',
      score: 4,
      color: Colors.blueAccent,
      emoji: '😊',
    ),
    _MoodDefinition(
      category: 'Neutral',
      score: 3,
      color: Colors.green,
      emoji: '😐',
    ),
    _MoodDefinition(
      category: 'Sad',
      score: 2,
      color: Colors.grey,
      emoji: '😢',
    ),
    _MoodDefinition(
      category: 'Angry',
      score: 1,
      color: Colors.redAccent,
      emoji: '😡',
    ),
  ];

  MoodPeriod _selectedPeriod = MoodPeriod.sevenDays;
  bool _isSavingMood = false;

  User? get _currentUser => FirebaseAuth.instance.currentUser;

  CollectionReference<Map<String, dynamic>>? get _moodCollection {
    final user = _currentUser;

    if (user == null) {
      return null;
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('moodEntries');
  }

  Query<Map<String, dynamic>>? get _moodQuery {
    final collection = _moodCollection;

    if (collection == null) {
      return null;
    }

    switch (_selectedPeriod) {
      case MoodPeriod.sevenDays:
        final startDate = DateTime.now().subtract(
          const Duration(days: 7),
        );

        return collection
            .where(
              'createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
            )
            .orderBy('createdAt', descending: true);

      case MoodPeriod.thirtyDays:
        final startDate = DateTime.now().subtract(
          const Duration(days: 30),
        );

        return collection
            .where(
              'createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
            )
            .orderBy('createdAt', descending: true);

      case MoodPeriod.allTime:
        return collection.orderBy(
          'createdAt',
          descending: true,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = _moodQuery;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 102, 140, 84),
        title: const Text(
          'Mood Tracker',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: query == null
          ? const Center(
              child: Text(
                'Please sign in to track your mood.',
                style: TextStyle(fontSize: 17),
              ),
            )
          : Column(
              children: [
                const SizedBox(height: 16),

                // Analysis-period selector
                _buildPeriodSelector(),

                const SizedBox(height: 8),

                // Chart
                Expanded(
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: query.snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return _buildErrorMessage(
                          snapshot.error,
                        );
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      final documents = snapshot.data?.docs ?? [];

                      final chartData = _createChartData(
                        documents,
                      );

                      final totalEntries = chartData.fold<double>(
                        0,
                        (total, data) => total + data.value,
                      );

                      if (totalEntries == 0) {
                        return _buildEmptyAnalysis();
                      }

                      return SfCircularChart(
                        title: ChartTitle(
                          text: _chartTitle,
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                        legend: const Legend(
                          isVisible: true,
                          overflowMode: LegendItemOverflowMode.wrap,
                        ),
                        series: <CircularSeries<_ChartData, String>>[
                          PieSeries<_ChartData, String>(
                            dataSource: chartData
                                .where((data) => data.value > 0)
                                .toList(),
                            xValueMapper: (
                              _ChartData data,
                              _,
                            ) =>
                                data.category,
                            yValueMapper: (
                              _ChartData data,
                              _,
                            ) =>
                                data.value,
                            pointColorMapper: (
                              _ChartData data,
                              _,
                            ) =>
                                data.color,
                            dataLabelMapper: (
                              _ChartData data,
                              _,
                            ) =>
                                '${data.category}: '
                                '${data.value.toInt()}',
                            dataLabelSettings: const DataLabelSettings(
                              isVisible: true,
                            ),

                            // Prevents the disposed RenderObject error
                            // when leaving the page.
                            animationDuration: 0,
                          ),
                        ],
                      );
                    },
                  ),
                ),

                const Divider(),

                const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text(
                    'How are you feeling?',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Mood buttons
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 14,
                  ),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 6,
                    runSpacing: 8,
                    children: _moods.map((mood) {
                      return TextButton(
                        style: TextButton.styleFrom(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(12),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                        ),
                        onPressed:
                            _isSavingMood ? null : () => _recordMood(mood),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              mood.emoji,
                              style: const TextStyle(
                                fontSize: 32,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              mood.category,
                              style: const TextStyle(
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
    );
  }

  String get _chartTitle {
    switch (_selectedPeriod) {
      case MoodPeriod.sevenDays:
        return 'Mood Analysis — Last 7 Days';

      case MoodPeriod.thirtyDays:
        return 'Mood Analysis — Last 30 Days';

      case MoodPeriod.allTime:
        return 'Mood Analysis — All Time';
    }
  }

  Widget _buildPeriodSelector() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      children: [
        ChoiceChip(
          label: const Text('7 Days'),
          selected: _selectedPeriod == MoodPeriod.sevenDays,
          onSelected: (_) {
            setState(() {
              _selectedPeriod = MoodPeriod.sevenDays;
            });
          },
        ),
        ChoiceChip(
          label: const Text('30 Days'),
          selected: _selectedPeriod == MoodPeriod.thirtyDays,
          onSelected: (_) {
            setState(() {
              _selectedPeriod = MoodPeriod.thirtyDays;
            });
          },
        ),
        ChoiceChip(
          label: const Text('All Time'),
          selected: _selectedPeriod == MoodPeriod.allTime,
          onSelected: (_) {
            setState(() {
              _selectedPeriod = MoodPeriod.allTime;
            });
          },
        ),
      ],
    );
  }

  List<_ChartData> _createChartData(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> documents,
  ) {
    final moodCounts = <String, double>{
      for (final mood in _moods) mood.category: 0,
    };

    for (final document in documents) {
      final moodName = (document.data()['mood'] as String? ?? '').trim();

      if (moodCounts.containsKey(moodName)) {
        moodCounts[moodName] = moodCounts[moodName]! + 1;
      }
    }

    return _moods.map((mood) {
      return _ChartData(
        category: mood.category,
        value: moodCounts[mood.category] ?? 0,
        color: mood.color,
      );
    }).toList();
  }

  Widget _buildEmptyAnalysis() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '📊',
              style: TextStyle(fontSize: 65),
            ),
            const SizedBox(height: 12),
            Text(
              'No mood entries for $_periodDescription.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Select your current mood below.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String get _periodDescription {
    switch (_selectedPeriod) {
      case MoodPeriod.sevenDays:
        return 'the last 7 days';

      case MoodPeriod.thirtyDays:
        return 'the last 30 days';

      case MoodPeriod.allTime:
        return 'all time';
    }
  }

  Widget _buildErrorMessage(Object? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red,
            ),
            const SizedBox(height: 12),
            const Text(
              'Could not load mood analysis.',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error?.toString() ?? 'Please try again.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _recordMood(
    _MoodDefinition selectedMood,
  ) async {
    final collection = _moodCollection;

    if (collection == null) {
      _showMessage('Please sign in again.');
      return;
    }

    setState(() {
      _isSavingMood = true;
    });

    try {
      await collection.add({
        'mood': selectedMood.category,
        'score': selectedMood.score,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      _showMessage(
        '${selectedMood.emoji} '
        '${selectedMood.category} recorded',
      );
    } on FirebaseException catch (error) {
      if (!mounted) return;

      _showMessage(
        error.message ?? 'Could not record your mood.',
      );
    } catch (_) {
      if (!mounted) return;

      _showMessage('Could not record your mood.');
    } finally {
      if (mounted) {
        setState(() {
          _isSavingMood = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}

class _MoodDefinition {
  final String category;
  final int score;
  final Color color;
  final String emoji;

  const _MoodDefinition({
    required this.category,
    required this.score,
    required this.color,
    required this.emoji,
  });
}

class _ChartData {
  final String category;
  final double value;
  final Color color;

  const _ChartData({
    required this.category,
    required this.value,
    required this.color,
  });
}
