import 'dart:convert';

import 'upload_status.dart';

class UploadItem {
  final String id;
  final String batchId;
  final String localPath;
  final String title;
  final String size;
  final UploadStatus status;
  final double progress;
  final int retryCount;
  final String? remoteUrl;

  const UploadItem({
    required this.id,
    required this.batchId,
    required this.localPath,
    required this.title,
    required this.size,
    this.status = UploadStatus.waiting,
    this.progress = 0.0,
    this.retryCount = 0,
    this.remoteUrl,
  });

  UploadItem copyWith({
    UploadStatus? status,
    double? progress,
    int? retryCount,
    String? remoteUrl,
  }) {
    return UploadItem(
      id: id,
      batchId: batchId,
      localPath: localPath,
      title: title,
      size: size,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      retryCount: retryCount ?? this.retryCount,
      remoteUrl: remoteUrl ?? this.remoteUrl,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'batchId': batchId,
    'localPath': localPath,
    'title': title,
    'size': size,
    'status': status.name,
    'progress': progress,
    'retryCount': retryCount,
    'remoteUrl': remoteUrl,
  };

  factory UploadItem.fromJson(Map<String, dynamic> json) => UploadItem(
    id: json['id'] as String,
    batchId: json['batchId'] as String,
    localPath: json['localPath'] as String,
    title: json['title'] as String,
    size: json['size'] as String,
    status: UploadStatus.values.byName(json['status'] as String),
    progress: (json['progress'] as num).toDouble(),
    retryCount: json['retryCount'] as int? ?? 0,
    remoteUrl: json['remoteUrl'] as String?,
  );

  static String encodeList(List<UploadItem> items) =>
      jsonEncode(items.map((e) => e.toJson()).toList());

  static List<UploadItem> decodeList(String raw) {
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => UploadItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
