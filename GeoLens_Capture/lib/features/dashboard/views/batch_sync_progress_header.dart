import 'package:flutter/material.dart';
import 'package:geolens_capture/core/utils/size_parser.dart';
import 'package:geolens_capture/features/dashboard/models/upload_item.dart';
import 'package:geolens_capture/features/dashboard/models/upload_status.dart';

class BatchSyncProgressHeader extends StatelessWidget {
  final List<UploadItem> items;

  const BatchSyncProgressHeader({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    double totalBytes = 0;
    double completedBytes = 0;

    for (final item in items) {
      final itemBytes = parseSizeToBytes(item.size);
      totalBytes += itemBytes;

      switch (item.status) {
        case UploadStatus.success:
          completedBytes += itemBytes;
          break;
        case UploadStatus.uploading:
          completedBytes += itemBytes * item.progress;
          break;
        case UploadStatus.waiting:
        case UploadStatus.failed:
          break;
      }
    }

    final overallProgress = totalBytes == 0 ? 0.0 : completedBytes / totalBytes;
    final percentLabel = (overallProgress * 100).toStringAsFixed(0);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Batch Sync Progress',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              Text(
                '$percentLabel%',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: overallProgress,
              minHeight: 6,
              backgroundColor: Colors.black12,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.lightBlue),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${formatBytes(completedBytes)} / ${formatBytes(totalBytes)}',
            style: const TextStyle(fontSize: 11, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
