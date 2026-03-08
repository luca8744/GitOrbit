import 'package:flutter/material.dart';
import '../core/network/git_client.dart';
import '../models/project.dart';

class HeatView extends StatefulWidget {
  const HeatView({super.key});

  @override
  State<HeatView> createState() => _HeatViewState();
}

class _HeatViewState extends State<HeatView> {
  final GitClient _client = GitClient();
  bool _isLoading = true;
  String? _error;
  List<GitProject> _hottest = [];
  List<GitProject> _coldest = [];

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
      // Hottest projects are those with the most recent activity
      final hottest = await _client.getProjects(orderBy: 'last_activity_at', sort: 'desc', perPage: 10);
      
      // Coldest projects are those with the oldest activity
      final coldest = await _client.getProjects(orderBy: 'last_activity_at', sort: 'asc', perPage: 10);

      setState(() {
        _hottest = hottest;
        _coldest = coldest;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Widget _buildProjectCard(GitProject project, bool isHot) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: Icon(
          isHot ? Icons.local_fire_department : Icons.ac_unit,
          color: isHot ? const Color(0xFFF7768E) : const Color(0xFF7AA2F7),
        ),
        title: Text(project.nameWithNamespace),
        subtitle: Text('Last active: ${project.lastActivityAt?.toLocal().toString().split('.')[0] ?? 'Never'}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, size: 16, color: Color(0xFFE0AF68)),
            const SizedBox(width: 4),
            Text('${project.starCount}'),
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
      appBar: AppBar(title: const Text('Activity Thermometer')),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Text(
                '🔥 Hottest Projects',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(0xFFF7768E),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildProjectCard(_hottest[index], true),
              childCount: _hottest.length,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16).copyWith(top: 24),
            sliver: SliverToBoxAdapter(
              child: Text(
                '🧊 Coldest Projects',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF7AA2F7),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildProjectCard(_coldest[index], false),
              childCount: _coldest.length,
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
        ],
      ),
    );
  }
}
