import 'package:flutter/material.dart';
import '../core/network/git_client.dart';
import '../models/user.dart';

class UsersAnalyticsView extends StatefulWidget {
  const UsersAnalyticsView({super.key});

  @override
  State<UsersAnalyticsView> createState() => _UsersAnalyticsViewState();
}

class _UsersAnalyticsViewState extends State<UsersAnalyticsView> {
  final GitClient _client = GitClient();
  bool _isLoading = true;
  String? _error;
  List<GitUser> _users = [];
  Map<int, int> _userWeeklyActivitiesCount = {};

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
      final users = await _client.getUsers();
      final DateTime oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));
      
      final Map<int, int> weeklyCounts = {};
      await Future.wait(users.map((user) async {
        try {
          final activities = await _client.getActivities(userId: user.id, after: oneWeekAgo, perPage: 100);
          // the api returns events created strictly after the date, but we can filter again to ensure exact 7 days match if timestamp is included
          final recentActivities = activities.where((a) => a.createdAt != null && a.createdAt!.isAfter(oneWeekAgo)).toList();
          weeklyCounts[user.id] = recentActivities.length;
        } catch (_) {
          weeklyCounts[user.id] = 0;
        }
      }));

      users.sort((a, b) {
        final countA = weeklyCounts[a.id] ?? 0;
        final countB = weeklyCounts[b.id] ?? 0;
        return countB.compareTo(countA);
      });

      setState(() {
        _users = users;
        _userWeeklyActivitiesCount = weeklyCounts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
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
      appBar: AppBar(title: const Text('Team Analytics')),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _users.length,
          itemBuilder: (context, index) {
            final user = _users[index];
            final activityCount = _userWeeklyActivitiesCount[user.id] ?? 0;
            
            String lastActive = 'Unknown';
            if (user.lastActivityOn != null) {
              final localDate = user.lastActivityOn!.toLocal();
              final date = '${localDate.year}-${localDate.month.toString().padLeft(2, '0')}-${localDate.day.toString().padLeft(2, '0')}';
              // Since last_activity_on is often just a date string (YYYY-MM-DD), time might be 00:00. This is best effort based on API response.
              lastActive = date;
            }

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
                  backgroundColor: const Color(0xFF7AA2F7).withValues(alpha: 0.2),
                  child: user.avatarUrl == null ? Text(user.name[0].toUpperCase(), style: const TextStyle(color: Color(0xFF7AA2F7))) : null,
                ),
                title: Text(user.name),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('@${user.username}'),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 14, color: Color(0xFFA9B1D6)),
                          const SizedBox(width: 4),
                          Text('Last access: $lastActive', style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.show_chart, size: 14, color: Color(0xFF9ECE6A)),
                          const SizedBox(width: 4),
                          Text('Activities (7d): $activityCount', style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                isThreeLine: true,
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: user.state == 'active' 
                            ? const Color(0xFF9ECE6A).withValues(alpha: 0.2) 
                            : const Color(0xFFF7768E).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        user.state,
                        style: TextStyle(
                          color: user.state == 'active' ? const Color(0xFF9ECE6A) : const Color(0xFFF7768E),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
