class FolderInfo {
  final String id;
  final String name;
  final String url;

  const FolderInfo({
    required this.id,
    required this.name,
    required this.url,
  });

  factory FolderInfo.fromUrl(String url) {
    final folderId = extractFolderId(url);
    return FolderInfo(
      id: folderId,
      name: '', // Will be fetched later
      url: url,
    );
  }

  static String extractFolderId(String url) {
    // 支持多种Google Drive URL格式
    final patterns = [
      RegExp(r'/folders/([a-zA-Z0-9_-]+)'),
      RegExp(r'id=([a-zA-Z0-9_-]+)'),
      RegExp(r'folder/d/([a-zA-Z0-9_-]+)'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(url);
      if (match != null) {
        return match.group(1)!;
      }
    }

    throw ArgumentError('无效的Google Drive链接格式');
  }

  FolderInfo copyWith({
    String? id,
    String? name,
    String? url,
  }) {
    return FolderInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
    );
  }
}