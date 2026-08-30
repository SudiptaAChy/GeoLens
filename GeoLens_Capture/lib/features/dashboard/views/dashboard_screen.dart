import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolens_capture/features/dashboard/cubit/upload_queue_cubit.dart';
import 'package:geolens_capture/features/dashboard/models/upload_status.dart';
import 'package:geolens_capture/features/dashboard/cubit/upload_queue_state.dart';
import 'package:geolens_capture/features/camera/views/camera_preview_screen.dart';
import 'package:geolens_capture/features/dashboard/views/upload_list_item.dart';

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
            label: const Text(
              'START NEW UPLOAD BATCH',
              style: TextStyle(color: Colors.white),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: Colors.lightBlue,
            elevation: 0,
          ),
        ),
      ),
    );
  }
}
