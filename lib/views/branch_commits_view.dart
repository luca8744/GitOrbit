import 'package:flutter/material.dart';
import '../core/network/git_client.dart';
import '../models/project.dart';
import '../models/branch.dart';
import '../models/commit.dart';

class BranchCommitsView extends StatefulWidget {
  final GitProject project;
  final GitBranch branch;

  const BranchCommitsView({super.key, required this.project, required this.branch});

  @override
  State<BranchCommitsView> createState() => _BranchCommitsViewState();
}

class _BranchCommitsViewState extends State<BranchCommitsView> {
  final GitClient _client = GitClient();
  bool _isLoading = true;
  String? _error;
  List<GitCommit> _commits = [];

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
      final commits = await _client.getCommits(widget.project.id, widget.branch.name);
      setState(() {
        _commits = commits;
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
      appBar: AppBar(title: Text('${widget.project.name} - ${widget.branch.name}')),
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

    if (_commits.isEmpty) {
      return const Center(child: Text('No commits found on this branch.'));
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _commits.length,
        itemBuilder: (context, index) {
          final commit = _commits[index];
          
          String timeStr = 'Unknown time';
          if (commit.createdAt != null) {
            final local = commit.createdAt!.toLocal();
            timeStr = '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')} ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
          }

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF1E2030), // Darker background
                child: Icon(Icons.commit, color: Color(0xFFE0AF68)),
              ),
              title: Text(commit.title, maxLines: 2, overflow: TextOverflow.ellipsis),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.person, size: 14, color: Color(0xFFA9B1D6)),
                          const SizedBox(width: 4),
                          Expanded(child: Text(commit.authorName, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12))),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 14, color: Color(0xFFA9B1D6)),
                        const SizedBox(width: 4),
                        Text(timeStr, style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              trailing: Text(
                commit.shortId,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  color: Color(0xFF7AA2F7),
                  fontWeight: FontWeight.bold,
                ),
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }
}
