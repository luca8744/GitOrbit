class GitActivity {
  final int id;
  final int projectId;
  final String actionName;
  final int? targetId;
  final String? targetType;
  final int authorId;
  final String authorUsername;
  final DateTime? createdAt;
  final String? targetTitle;

  GitActivity({
    required this.id,
    required this.projectId,
    required this.actionName,
    this.targetId,
    this.targetType,
    required this.authorId,
    required this.authorUsername,
    this.createdAt,
    this.targetTitle,
  });

  factory GitActivity.fromJson(Map<String, dynamic> json) {
    return GitActivity(
      id: json['id'] ?? 0,
      projectId: json['project_id'] ?? 0,
      actionName: json['action_name'] ?? 'unknown',
      targetId: json['target_id'],
      targetType: json['target_type'],
      authorId: json['author_id'] ?? 0,
      authorUsername: json['author_username'] ?? 'Unknown',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      targetTitle: json['target_title'],
    );
  }
}
