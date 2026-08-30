import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolens_capture/features/camera/cubit/camera_cubit.dart';
import 'package:geolens_capture/features/dashboard/cubit/upload_queue_cubit.dart';
import 'package:geolens_capture/features/dashboard/models/upload_item.dart';
import 'package:geolens_capture/features/camera/cubit/camera_state.dart';
import 'package:geolens_capture/features/camera/views/capture_button.dart';
import 'package:geolens_capture/features/camera/views/captured_image_thumbnail.dart';
import 'package:geolens_capture/features/camera/views/zoom_button_row.dart';
import 'package:uuid/uuid.dart';

class CameraPreviewScreen extends StatelessWidget {
  const CameraPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CameraCubit()..initCamera(),
      child: const _CameraPreviewView(),
    );
  }
}

class _CameraPreviewView extends StatelessWidget {
  const _CameraPreviewView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocBuilder<CameraCubit, CameraPageState>(
        builder: (context, state) {
          if (state.status == CameraStatus.error) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  state.errorMessage ?? 'Something went wrong',
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (state.status != CameraStatus.ready ||
              state.controller == null ||
              !state.controller!.value.isInitialized) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          final cubit = context.read<CameraCubit>();
          final controller = state.controller!;

          return LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  // Camera preview with pinch-to-zoom + tap-to-focus
                  GestureDetector(
                    onScaleStart: (_) => cubit.onScaleStart(),
                    onScaleUpdate: (details) =>
                        cubit.onScaleUpdate(details.scale),
                    onTapUp: (details) {
                      final dx =
                          details.localPosition.dx / constraints.maxWidth;
                      final dy =
                          details.localPosition.dy / constraints.maxHeight;
                      final normalized = Offset(
                        dx.clamp(0.0, 1.0),
                        dy.clamp(0.0, 1.0),
                      );
                      cubit.focusAt(normalized, details.localPosition);
                    },
                    child: CameraPreview(controller),
                  ),

                  // Focus indicator circle
                  if (state.showFocusCircle && state.focusPoint != null)
                    Positioned(
                      left: state.focusPoint!.dx - 35,
                      top: state.focusPoint!.dy - 35,
                      child: AnimatedOpacity(
                        opacity: state.showFocusCircle ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.yellow,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),

                  // Zoom slider (vertical, right side)
                  Positioned(
                    right: 8,
                    top: 100,
                    bottom: state.hasCaptures ? 280 : 220,
                    child: RotatedBox(
                      quarterTurns: 3,
                      child: Slider(
                        value: state.currentZoom,
                        min: state.minZoom,
                        max: state.maxZoom,
                        activeColor: Colors.white,
                        inactiveColor: Colors.white38,
                        onChanged: cubit.setZoom,
                      ),
                    ),
                  ),

                  // Zoom preset buttons (0.5x / 1x / 2x etc.)
                  Positioned(
                    bottom: state.hasCaptures ? 210 : 150,
                    left: 0,
                    right: 0,
                    child: ZoomButtonRow(
                      minZoom: state.minZoom,
                      maxZoom: state.maxZoom,
                      currentZoom: state.currentZoom,
                      onZoomSelected: cubit.setZoom,
                    ),
                  ),

                  // Bottom section: thumbnail (far left) + capture button (true center)
                  Positioned(
                    bottom: 24,
                    left: 0,
                    right: 0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 72,
                          child: Row(
                            children: [
                              // Thumbnail pinned to the far left
                              SizedBox(
                                width: 78,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 16),
                                  child: CapturedImageThumbnail(
                                    imageFile: state.lastCapturedImage,
                                    batchCount: state.capturedImages.length,
                                  ),
                                ),
                              ),

                              // Capture button, always centered on screen —
                              // the equal-width spacer on the right balances
                              // the thumbnail's width on the left.
                              Expanded(
                                child: Center(
                                  child: CaptureButton(
                                    isCapturing: state.isCapturing,
                                    onTap: cubit.capturePhoto,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 78),
                            ],
                          ),
                        ),

                        // Full-width upload batch button — only visible after a capture
                        if (state.hasCaptures) ...[
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  final uuid = const Uuid();
                                  final batchId = uuid.v4();

                                  final queueItems = state.capturedImages.map((
                                    xfile,
                                  ) {
                                    final file = File(xfile.path);
                                    final sizeKb = file.lengthSync() / 1024;
                                    return UploadItem(
                                      id: uuid.v4(),
                                      batchId: batchId,
                                      localPath: xfile.path,
                                      title: xfile.name,
                                      size: sizeKb > 1024
                                          ? '${(sizeKb / 1024).toStringAsFixed(1)} MB'
                                          : '${sizeKb.toStringAsFixed(0)} KB',
                                    );
                                  }).toList();

                                  await context
                                      .read<UploadQueueCubit>()
                                      .addBatch(queueItems);

                                  if (context.mounted) {
                                    Navigator.of(context).pop(); // back to Dashboard, batch now shows as queued
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                icon: const Icon(Icons.cloud_upload_outlined),
                                label: Text(
                                  'Upload Batch (${state.capturedImages.length})',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Close button — top left
                  Positioned(
                    top: 40,
                    left: 16,
                    child: IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),

                  // Lens switch button (front/back or other CameraDescriptions)
                  if (state.cameras.length > 1)
                    Positioned(
                      top: 40,
                      right: 16,
                      child: IconButton(
                        icon: const Icon(
                          Icons.cameraswitch,
                          color: Colors.white,
                          size: 30,
                        ),
                        onPressed: cubit.switchCamera,
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
