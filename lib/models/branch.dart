class GitBranch {
  final String name;
  final bool merged;
  final bool protected;
  final String? commitId;

  GitBranch({
    required this.name,
    required this.merged,
    required this.protected,
    this.commitId,
  });

  factory GitBranch.fromJson(Map<String, dynamic> json) {
    return GitBranch(
      name: json['name'] ?? '',
      merged: json['merged'] ?? false,
      protected: json['protected'] ?? false,
      commitId: json['commit']?['id'],
    );
  }
}
