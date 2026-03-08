class GitGroup {
  final int id;
  final String name;
  final String path;
  final String? description;
  final String? avatarUrl;

  GitGroup({
    required this.id,
    required this.name,
    required this.path,
    this.description,
    this.avatarUrl,
  });

  factory GitGroup.fromJson(Map<String, dynamic> json) {
    return GitGroup(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      path: json['path'] ?? '',
      description: json['description'],
      avatarUrl: json['avatar_url'],
    );
  }
}
