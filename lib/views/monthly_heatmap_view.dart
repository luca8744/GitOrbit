import 'package:flutter/material.dart';
import '../core/network/git_client.dart';

class MonthlyHeatmapView extends StatefulWidget {
  const MonthlyHeatmapView({super.key});

  @override
  State<MonthlyHeatmapView> createState() => _MonthlyHeatmapViewState();
}

class _MonthlyHeatmapViewState extends State<MonthlyHeatmapView> {
  final GitClient _client = GitClient();
  bool _isLoading = true;
  String? _error;
  Map<DateTime, int> _dailyActivityCounts = {};
  int _maxActivity = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final DateTime now = DateTime.now();
      final DateTime thirtyDaysAgo = now.subtract(const Duration(days: 30));
      
      final Map<DateTime, int> dailyCounts = {};

      final activities = await _client.getActivities(after: thirtyDaysAgo, perPage: 300);
      for (var activity in activities) {
        if (activity.createdAt != null) {
          final localDate = activity.createdAt!.toLocal();
          final date = DateTime(localDate.year, localDate.month, localDate.day);
          dailyCounts[date] = (dailyCounts[date] ?? 0) + 1;
        }
      }

      int maxAct = 1;
      if (dailyCounts.isNotEmpty) {
        maxAct = dailyCounts.values.reduce((a, b) => a > b ? a : b);
      }

      setState(() {
        _dailyActivityCounts = dailyCounts;
        _maxActivity = maxAct;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Widget _buildHeatmapGrid(BuildContext context) {
    if (_dailyActivityCounts.isEmpty && !_isLoading && _error == null) {
      return const Center(child: Text('No activities in the last 30 days.'));
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Total days to display
    const int totalDays = 30;
    final startDate = today.subtract(const Duration(days: totalDays - 1));

    // Generate chronological list of days
    final List<DateTime> days = List.generate(totalDays, (index) {
      return startDate.add(Duration(days: index));
    });

    const double boxSize = 36.0;
    const double spacing = 6.0;

    // To position labels properly across a wrapping horizontal grid is tricky directly above the boxes without 
    // a rigid table. Since we are using Wrap horizontally, the simplest approach for month labels that aligns
    // perfectly is calculating the text directly where the month happens or just printing standard text.
    // Instead of complex absolute positioning, we'll build a custom widget that interleaves month headers 
    // inside the flow, or prints them above distinct sections.
    // However, the cleanest standard approach is to just show a "Month - Month" range at the top.
    // E.g. "February - March"

    final List<String> monthNames = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    final int startMonth = startDate.month;
    final int endMonth = today.month;
    
    String monthDisplay;
    if (startMonth == endMonth) {
      monthDisplay = monthNames[startMonth];
    } else {
      monthDisplay = '${monthNames[startMonth]} - ${monthNames[endMonth]}';
    }

    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Monthly Contributions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFC0CAF5),
                      ),
                ),
                Text(
                  'Max/day: $_maxActivity',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFFA9B1D6),
                      ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Month Label(s)
            Text(
              monthDisplay,
              style: const TextStyle(
                color: Color(0xFF565F89),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            // The Horizontal Wrap Grid
            Center(
              child: Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: days.map((day) {
                  final count = _dailyActivityCounts[day] ?? 0;
                  
                  Color color;
                  if (count == 0) {
                    color = const Color(0xFF1F2335); // Dark background
                  } else {
                    final intensity = (0.2 + (0.8 * (count / _maxActivity))).clamp(0.0, 1.0);
                    color = const Color(0xFF9ECE6A).withValues(alpha: intensity);
                  }
                  
                  String dayStr = day.day.toString();
                  
                  return Tooltip(
                    message: '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}\n$count activities',
                    decoration: BoxDecoration(
                      color: const Color(0xFF24283B),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF414868), width: 1),
                    ),
                    textStyle: const TextStyle(color: Color(0xFFC0CAF5), fontSize: 12),
                    child: Container(
                      width: boxSize,
                      height: boxSize,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.05), width: 1),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        dayStr,
                        style: TextStyle(
                          fontSize: 12, // Increased font size for legibility
                          fontWeight: FontWeight.bold,
                          color: count == 0 
                              ? const Color(0xFF565F89) 
                              : const Color(0xFF1A1B26).withValues(alpha: 0.8), 
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text('Less ', style: TextStyle(fontSize: 12, color: Color(0xFFA9B1D6))),
                Container(width: 14, height: 14, decoration: BoxDecoration(color: const Color(0xFF1F2335), borderRadius: BorderRadius.circular(3))),
                const SizedBox(width: 4),
                Container(width: 14, height: 14, decoration: BoxDecoration(color: const Color(0xFF9ECE6A).withValues(alpha: 0.4), borderRadius: BorderRadius.circular(3))),
                const SizedBox(width: 4),
                Container(width: 14, height: 14, decoration: BoxDecoration(color: const Color(0xFF9ECE6A).withValues(alpha: 0.7), borderRadius: BorderRadius.circular(3))),
                const SizedBox(width: 4),
                Container(width: 14, height: 14, decoration: BoxDecoration(color: const Color(0xFF9ECE6A), borderRadius: BorderRadius.circular(3))),
                const Text(' More', style: TextStyle(fontSize: 12, color: Color(0xFFA9B1D6))),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_error', style: TextStyle(color: Theme.of(context).colorScheme.error)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Activity Heatmap')),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Global team activity trends across all projects over the past 30 days.',
              style: TextStyle(color: Color(0xFFA9B1D6), fontSize: 14),
            ),
            const SizedBox(height: 24),
            _buildHeatmapGrid(context),
          ],
        ),
      ),
    );
  }
}
