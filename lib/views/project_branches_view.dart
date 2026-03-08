import 'package:flutter/material.dart';
import '../core/network/git_client.dart';
import '../models/project.dart';
import '../models/branch.dart';
import 'branch_commits_view.dart';

class ProjectBranchesView extends StatefulWidget {
  final GitProject project;

  const ProjectBranchesView({super.key, required this.project});

  @override
  State<ProjectBranchesView> createState() => _ProjectBranchesViewState();
}

class _ProjectBranchesViewState extends State<ProjectBranchesView> {
  final GitClient _client = GitClient();
  bool _isLoading = true;
  String? _error;
  List<GitBranch> _branches = [];

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
      final branches = await _client.getBranches(widget.project.id);
      setState(() {
        _branches = branches;
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
      appBar: AppBar(title: Text('${widget.project.name} - Branches')),
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

    if (_branches.isEmpty) {
      return const Center(child: Text('No branches found.'));
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _branches.length,
        itemBuilder: (context, index) {
          final branch = _branches[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.call_split, color: Color(0xFF7AA2F7)),
              title: Text(branch.name),
              subtitle: Row(
                children: [
                  if (branch.merged)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF9ECE6A).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('Merged', style: TextStyle(fontSize: 10, color: Color(0xFF9ECE6A))),
                    ),
                  if (branch.protected)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7768E).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('Protected', style: TextStyle(fontSize: 10, color: Color(0xFFF7768E))),
                    ),
                  if (branch.commitId != null)
                    Text('Commit: ${branch.commitId!.substring(0, 8)}', style: const TextStyle(fontSize: 12)),
                ],
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BranchCommitsView(project: widget.project, branch: branch),
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
