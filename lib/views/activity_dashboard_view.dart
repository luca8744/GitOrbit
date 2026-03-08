import 'package:flutter/material.dart';
import '../core/network/git_client.dart';
import '../models/activity.dart';
import '../models/project.dart';

class ActivityDashboardView extends StatefulWidget {
  const ActivityDashboardView({super.key});

  @override
  State<ActivityDashboardView> createState() => _ActivityDashboardViewState();
}

class _ActivityDashboardViewState extends State<ActivityDashboardView> {
  final GitClient _client = GitClient();
  bool _isLoading = true;
  String? _error;
  List<GitActivity> _activities = [];
  Map<int, GitProject> _projectsMap = {};

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
      final List<List<GitActivity>> userActivitiesFutures = await Future.wait(
        users.map((user) => _client.getActivities(perPage: 20, userId: user.id)),
      );

      final List<GitActivity> allActivities = userActivitiesFutures.expand((i) => i).toList();
      allActivities.sort((a, b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));
      final List<GitActivity> topActivities = allActivities.take(50).toList();

      final Set<int> uniqueProjectIds = topActivities.map((a) => a.projectId).where((id) => id != 0).toSet();
      
      final Map<int, GitProject> fetchedProjects = {};
      await Future.wait(uniqueProjectIds.map((id) async {
        try {
          final project = await _client.getProject(id);
          fetchedProjects[id] = project;
        } catch (_) {
          // ignore failed project fetches
        }
      }));

      setState(() {
        _activities = topActivities;
        _projectsMap = fetchedProjects;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  IconData _getIconForAction(String actionName) {
    if (actionName.contains('pushed')) return Icons.publish;
    if (actionName.contains('created')) return Icons.add_circle_outline;
    if (actionName.contains('opened')) return Icons.open_in_new;
    if (actionName.contains('closed')) return Icons.check_circle_outline;
    if (actionName.contains('merged')) return Icons.merge_type;
    return Icons.notifications_none;
  }

  Color _getColorForAction(String actionName) {
    if (actionName.contains('pushed') || actionName.contains('merged')) return const Color(0xFF9ECE6A);
    if (actionName.contains('created') || actionName.contains('opened')) return const Color(0xFF7AA2F7);
    if (actionName.contains('closed') || actionName.contains('deleted')) return const Color(0xFFF7768E);
    return const Color(0xFFA9B1D6);
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
      appBar: AppBar(title: const Text('Global Activity Feed')),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _activities.length,
          itemBuilder: (context, index) {
            final activity = _activities[index];
            final project = _projectsMap[activity.projectId];
            final repoName = project?.name ?? 'repository';
            
            String target = activity.targetTitle ?? activity.targetType ?? '';
            if (target.isNotEmpty) {
               target = ' - $target';
            }

            final timeStr = activity.createdAt?.toLocal().toString().split('.')[0] ?? 'Unknown time';
            
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: _getColorForAction(activity.actionName).withValues(alpha: 0.2),
                      child: Icon(
                        _getIconForAction(activity.actionName),
                        color: _getColorForAction(activity.actionName),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: Theme.of(context).textTheme.bodyMedium,
                              children: [
                                TextSpan(
                                  text: '${activity.authorUsername} ',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(text: '${activity.actionName} '),
                                TextSpan(
                                  text: repoName,
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7AA2F7)),
                                ),
                                TextSpan(
                                  text: target,
                                  style: const TextStyle(fontStyle: FontStyle.italic),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            timeStr,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
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
