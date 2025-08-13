class DownloadProgress {
  final int totalFiles;
  final int downloadedFiles;
  final String currentFile;
  final double percentage;
  final bool isComplete;
  final String status;
  final String? error;

  const DownloadProgress({
    required this.totalFiles,
    required this.downloadedFiles,
    required this.currentFile,
    required this.percentage,
    required this.isComplete,
    required this.status,
    this.error,
  });

  DownloadProgress copyWith({
    int? totalFiles,
    int? downloadedFiles,
    String? currentFile,
    double? percentage,
    bool? isComplete,
    String? status,
    String? error,
  }) {
    return DownloadProgress(
      totalFiles: totalFiles ?? this.totalFiles,
      downloadedFiles: downloadedFiles ?? this.downloadedFiles,
      currentFile: currentFile ?? this.currentFile,
      percentage: percentage ?? this.percentage,
      isComplete: isComplete ?? this.isComplete,
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }

  static const DownloadProgress initial = DownloadProgress(
    totalFiles: 0,
    downloadedFiles: 0,
    currentFile: '',
    percentage: 0.0,
    isComplete: false,
    status: '等待开始...',
  );
}