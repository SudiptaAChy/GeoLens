import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolens_capture/features/dashboard/cubit/upload_queue_cubit.dart';
import 'package:geolens_capture/features/dashboard/models/upload_item.dart';
import 'package:geolens_capture/features/dashboard/models/upload_status.dart';
import 'package:geolens_capture/features/dashboard/cubit/upload_queue_state.dart';
import 'package:geolens_capture/features/camera/views/camera_preview_screen.dart';

import 'dart:io';

File _asFile(String path) => File(path);

final class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Manager')),
      body: BlocBuilder<UploadQueueCubit, UploadQueueState>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Text(
                      'Pending Uploads',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (state.isSyncing) ...[
                      const SizedBox(width: 8),
                      const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ],
                  ],
                ),
              ),
              Expanded(
                child: state.items.isEmpty
                    ? const Center(child: Text('No uploads yet'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        itemCount: state.items.length,
                        itemBuilder: (context, index) {
                          final item = state.items[index];
                          return UploadListItem(
                            item: item,
                            onRetry: item.status == UploadStatus.failed
                                ? () => context
                                    .read<UploadQueueCubit>()
                                    .retryItem(item.id)
                                : null,
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CameraPreviewScreen(),
                ),
              );
            },
            label: const Text('START NEW UPLOAD BATCH'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}

class UploadListItem extends StatelessWidget {
  final UploadItem item;
  final VoidCallback? onRetry;

  const UploadListItem({super.key, required this.item, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            // local file preview — falls back gracefully if missing
            errorBuilder: (context, error, stackTrace) => Container(
              width: 48,
              height: 48,
              color: Colors.grey[300],
              child: const Icon(Icons.broken_image, color: Colors.grey),
            ),
            _asFile(item.localPath),
            width: 48,
            height: 48,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(
          item.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.size,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 6),
              _buildStatusRow(),
            ],
          ),
        ),
        trailing: item.status == UploadStatus.failed && onRetry != null
            ? IconButton(
                icon: const Icon(Icons.refresh, color: Colors.red),
                onPressed: onRetry,
                tooltip: 'Retry upload',
              )
            : null,
        isThreeLine: true,
      ),
    );
  }

  Widget _buildStatusRow() {
    switch (item.status) {
      case UploadStatus.uploading:
        return Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: item.progress,
                  minHeight: 5,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${(item.progress * 100).toStringAsFixed(0)}%',
              style: const TextStyle(fontSize: 12, color: Colors.blue),
            ),
          ],
        );

      case UploadStatus.success:
        return const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 16),
            SizedBox(width: 4),
            Text('Completed', style: TextStyle(fontSize: 12, color: Colors.green)),
          ],
        );

      case UploadStatus.failed:
        return const Row(
          children: [
            Icon(Icons.error, color: Colors.red, size: 16),
            SizedBox(width: 4),
            Text(
              'Failed — will retry automatically',
              style: TextStyle(fontSize: 12, color: Colors.red),
            ),
          ],
        );

      case UploadStatus.waiting:
        return Row(
          children: [
            Icon(Icons.schedule, color: Colors.grey[500], size: 16),
            const SizedBox(width: 4),
            Text('Waiting...', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
          ],
        );
    }
  }
}
