class GitUser {
  final int id;
  final String username;
  final String name;
  final String state;
  final String? avatarUrl;
  final String? webUrl;
  final DateTime? lastActivityOn;

  GitUser({
    required this.id,
    required this.username,
    required this.name,
    required this.state,
    this.avatarUrl,
    this.webUrl,
    this.lastActivityOn,
  });

  factory GitUser.fromJson(Map<String, dynamic> json) {
    return GitUser(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      name: json['name'] ?? '',
      state: json['state'] ?? 'active',
      avatarUrl: json['avatar_url'],
      webUrl: json['web_url'],
      lastActivityOn: json['last_activity_on'] != null
          ? DateTime.tryParse(json['last_activity_on'])
          : null,
    );
  }
}
