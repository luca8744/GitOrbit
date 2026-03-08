class GitCommit {
  final String id;
  final String shortId;
  final String title;
  final String authorName;
  final DateTime? createdAt;

  GitCommit({
    required this.id,
    required this.shortId,
    required this.title,
    required this.authorName,
    this.createdAt,
  });

  factory GitCommit.fromJson(Map<String, dynamic> json) {
    return GitCommit(
      id: json['id'] ?? '',
      shortId: json['short_id'] ?? '',
      title: json['title'] ?? '',
      authorName: json['author_name'] ?? 'Unknown',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }
}
