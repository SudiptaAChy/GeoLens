import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'camera_state.dart';

class CameraCubit extends Cubit<CameraPageState> {
  CameraCubit() : super(const CameraPageState());

  double _baseZoom = 1.0;

  Future<void> initCamera({int cameraIndex = 0}) async {
    emit(state.copyWith(status: CameraStatus.loading));

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        emit(
          state.copyWith(
            status: CameraStatus.error,
            errorMessage: 'No cameras found on this device',
          ),
        );
        return;
      }

      final controller = CameraController(
        cameras[cameraIndex],
        ResolutionPreset.high,
        enableAudio: false,
      );

      await controller.initialize();

      final minZoom = await controller.getMinZoomLevel();
      final maxZoom = await controller.getMaxZoomLevel();

      if (isClosed) return;

      emit(
        state.copyWith(
          status: CameraStatus.ready,
          controller: controller,
          cameras: cameras,
          minZoom: minZoom,
          maxZoom: maxZoom,
          currentZoom: minZoom,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CameraStatus.error,
          errorMessage: 'Camera init failed: $e',
        ),
      );
    }
  }

  Future<void> switchCamera() async {
    if (state.cameras.length < 2 || state.controller == null) return;

    final currentIndex = state.cameras.indexOf(state.controller!.description);
    final nextIndex = (currentIndex + 1) % state.cameras.length;

    await state.controller!.dispose();
    await initCamera(cameraIndex: nextIndex);
  }

  void onScaleStart() {
    _baseZoom = state.currentZoom;
  }

  Future<void> onScaleUpdate(double scale) async {
    await setZoom(_baseZoom * scale);
  }

  Future<void> setZoom(double zoom) async {
    final controller = state.controller;
    if (controller == null) return;

    final clamped = zoom.clamp(state.minZoom, state.maxZoom);
    await controller.setZoomLevel(clamped);
    emit(state.copyWith(currentZoom: clamped));
  }

  Future<void> focusAt(Offset normalizedPoint, Offset rawPoint) async {
    final controller = state.controller;
    if (controller == null) return;

    try {
      await controller.setFocusPoint(normalizedPoint);
      await controller.setExposurePoint(normalizedPoint);
      await controller.setFocusMode(FocusMode.auto);
    } catch (_) {
      // focus not supported on this device/lens — safe to ignore
    }

    emit(state.copyWith(focusPoint: rawPoint, showFocusCircle: true));

    await Future.delayed(const Duration(seconds: 1));
    if (!isClosed) {
      emit(state.copyWith(showFocusCircle: false));
    }
  }

  Future<void> capturePhoto() async {
    final controller = state.controller;
    if (controller == null ||
        !controller.value.isInitialized ||
        controller.value.isTakingPicture ||
        state.isCapturing) {
      return;
    }

    emit(state.copyWith(isCapturing: true));

    try {
      final image = await controller.takePicture();
      if (isClosed) return;
      emit(
        state.copyWith(
          capturedImages: [...state.capturedImages, image],
          isCapturing: false,
        ),
      );
    } catch (_) {
      if (!isClosed) emit(state.copyWith(isCapturing: false));
    }
  }

  @override
  Future<void> close() {
    state.controller?.dispose();
    return super.close();
  }
}
