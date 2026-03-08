import 'package:flutter/material.dart';
import '../core/network/git_client.dart';
import '../models/group.dart';
import 'group_projects_view.dart';

class ProjectsGroupedView extends StatefulWidget {
  const ProjectsGroupedView({super.key});

  @override
  State<ProjectsGroupedView> createState() => _ProjectsGroupedViewState();
}

class _ProjectsGroupedViewState extends State<ProjectsGroupedView> {
  final GitClient _client = GitClient();
  bool _isLoading = true;
  String? _error;
  List<GitGroup> _groups = [];

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
      final groups = await _client.getGroups();
      setState(() {
        _groups = groups;
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

    if (_groups.isEmpty) {
      return const Center(child: Text('No groups found.'));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Groups')),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: _groups.length,
          itemBuilder: (context, index) {
            final group = _groups[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.folder, color: Color(0xFFE0AF68)),
                title: Text(group.name),
                subtitle: Text(group.description ?? 'No description', maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GroupProjectsView(group: group),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
