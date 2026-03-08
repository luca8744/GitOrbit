import 'package:flutter/material.dart';
import '../core/network/git_client.dart';
import '../models/group.dart';
import '../models/project.dart';
import 'project_branches_view.dart';

class GroupProjectsView extends StatefulWidget {
  final GitGroup group;

  const GroupProjectsView({super.key, required this.group});

  @override
  State<GroupProjectsView> createState() => _GroupProjectsViewState();
}

class _GroupProjectsViewState extends State<GroupProjectsView> {
  final GitClient _client = GitClient();
  bool _isLoading = true;
  String? _error;
  List<GitProject> _projects = [];

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
      final projects = await _client.getProjectsForGroup(widget.group.id);
      setState(() {
        _projects = projects;
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
    return Scaffold(
      appBar: AppBar(title: Text(widget.group.name)),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
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

    if (_projects.isEmpty) {
      return const Center(child: Text('No projects found in this group.'));
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _projects.length,
        itemBuilder: (context, index) {
          final project = _projects[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.book, color: Color(0xFF7AA2F7)),
              title: Text(project.name),
              subtitle: Text(project.description ?? 'No description', maxLines: 1, overflow: TextOverflow.ellipsis),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, size: 16, color: Color(0xFFE0AF68)),
                  const SizedBox(width: 4),
                  Text('${project.starCount}'),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProjectBranchesView(project: project),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
