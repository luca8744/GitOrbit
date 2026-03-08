class GitProject {
  final int id;
  final String name;
  final String nameWithNamespace;
  final String? description;
  final String? avatarUrl;
  final int starCount;
  final String webUrl;
  final DateTime? lastActivityAt;

  GitProject({
    required this.id,
    required this.name,
    required this.nameWithNamespace,
    this.description,
    this.avatarUrl,
    required this.starCount,
    required this.webUrl,
    this.lastActivityAt,
  });

  factory GitProject.fromJson(Map<String, dynamic> json) {
    return GitProject(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      nameWithNamespace: json['name_with_namespace'] ?? '',
      description: json['description'],
      avatarUrl: json['avatar_url'],
      starCount: json['star_count'] ?? 0,
      webUrl: json['web_url'] ?? '',
      lastActivityAt: json['last_activity_at'] != null
          ? DateTime.tryParse(json['last_activity_at'])
          : null,
    );
  }
}
