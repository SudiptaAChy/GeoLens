import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

enum CameraStatus { initial, loading, ready, error }

@immutable
class CameraPageState {
  final CameraStatus status;
  final String? errorMessage;

  final CameraController? controller;
  final List<CameraDescription> cameras;

  final double minZoom;
  final double maxZoom;
  final double currentZoom;

  final Offset? focusPoint;
  final bool showFocusCircle;

  final List<XFile> capturedImages;
  final bool isCapturing;

  const CameraPageState({
    this.status = CameraStatus.initial,
    this.errorMessage,
    this.controller,
    this.cameras = const [],
    this.minZoom = 1.0,
    this.maxZoom = 1.0,
    this.currentZoom = 1.0,
    this.focusPoint,
    this.showFocusCircle = false,
    this.capturedImages = const [],
    this.isCapturing = false,
  });

  XFile? get lastCapturedImage =>
      capturedImages.isEmpty ? null : capturedImages.last;

  bool get hasCaptures => capturedImages.isNotEmpty;

  CameraPageState copyWith({
    CameraStatus? status,
    String? errorMessage,
    CameraController? controller,
    List<CameraDescription>? cameras,
    double? minZoom,
    double? maxZoom,
    double? currentZoom,
    Offset? focusPoint,
    bool clearFocusPoint = false,
    bool? showFocusCircle,
    List<XFile>? capturedImages,
    bool? isCapturing,
    bool? isUploading,
  }) {
    return CameraPageState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      controller: controller ?? this.controller,
      cameras: cameras ?? this.cameras,
      minZoom: minZoom ?? this.minZoom,
      maxZoom: maxZoom ?? this.maxZoom,
      currentZoom: currentZoom ?? this.currentZoom,
      focusPoint: clearFocusPoint ? null : (focusPoint ?? this.focusPoint),
      showFocusCircle: showFocusCircle ?? this.showFocusCircle,
      capturedImages: capturedImages ?? this.capturedImages,
      isCapturing: isCapturing ?? this.isCapturing,
    );
  }
}
