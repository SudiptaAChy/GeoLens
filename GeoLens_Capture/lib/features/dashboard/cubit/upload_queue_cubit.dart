import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolens_capture/features/dashboard/models/upload_item.dart';
import 'package:geolens_capture/features/dashboard/models/upload_status.dart';
import 'package:geolens_capture/features/dashboard/repositories/upload_repository.dart';
import 'package:geolens_capture/core/services/connectivity_service.dart';
import 'package:geolens_capture/features/dashboard/cubit/upload_queue_state.dart';

class UploadQueueCubit extends Cubit<UploadQueueState> {
  UploadQueueCubit(this._repository, this._connectivity)
    : super(const UploadQueueState());

  final UploadRepository _repository;
  final ConnectivityService _connectivity;

  StreamSubscription<bool>? _connectivitySub;
  bool _isProcessing = false;

  Future<void> init() async {
    final saved = await _repository.loadQueue();
    emit(state.copyWith(items: saved));

    unawaited(_processPendingUploads());

    _connectivitySub = _connectivity.onConnectivityChanged.listen((isOnline) {
      if (isOnline) {
        unawaited(_processPendingUploads());
      }
    });
  }

  Future<void> addBatch(List<UploadItem> newItems) async {
    final updated = [...state.items, ...newItems];
    emit(state.copyWith(items: updated));
    await _repository.saveQueue(updated);
    unawaited(_processPendingUploads());
  }

  Future<void> retryItem(String id) async {
    _updateItem(id, (item) => item.copyWith(status: UploadStatus.waiting));
    await _persist();
    unawaited(_processPendingUploads());
  }

  Future<void> retryAllFailed() async {
    final updated = state.items
        .map(
          (item) => item.status == UploadStatus.failed
              ? item.copyWith(status: UploadStatus.waiting)
              : item,
        )
        .toList();
    emit(state.copyWith(items: updated));
    await _persist();
    unawaited(_processPendingUploads());
  }

  Future<void> _processPendingUploads() async {
    if (_isProcessing) return;
    _isProcessing = true;
    emit(state.copyWith(isSyncing: true));

    try {
      final online = await _connectivity.isConnected();
      if (!online) return;
      
      final pendingIds = state.items
          .where(
            (i) =>
                i.status == UploadStatus.waiting ||
                i.status == UploadStatus.failed,
          )
          .map((i) => i.id)
          .toList();

      for (final id in pendingIds) {
        if (!await _connectivity.isConnected()) break;
        await _uploadSingle(id);
      }
    } finally {
      _isProcessing = false;
      if (!isClosed) emit(state.copyWith(isSyncing: false));
    }
  }

  Future<void> _uploadSingle(String id) async {
    final item = state.items.firstWhere((i) => i.id == id);

    _updateItem(
      id,
      (i) => i.copyWith(status: UploadStatus.uploading, progress: 0),
    );
    await _persist();

    try {
      final remoteUrl = await _repository.uploadFile(
        item,
        onProgress: (p) {
          _updateItem(id, (i) => i.copyWith(progress: p));
        },
      );

      _updateItem(
        id,
        (i) => i.copyWith(
          status: UploadStatus.success,
          progress: 1.0,
          remoteUrl: remoteUrl,
        ),
      );
    } catch (_) {
      _updateItem(
        id,
        (i) => i.copyWith(
          status: UploadStatus.failed,
          retryCount: i.retryCount + 1,
        ),
      );
    }

    await _persist();
  }

  void _updateItem(String id, UploadItem Function(UploadItem) update) {
    final updated = state.items.map((i) => i.id == id ? update(i) : i).toList();
    emit(state.copyWith(items: updated));
  }

  Future<void> _persist() => _repository.saveQueue(state.items);

  @override
  Future<void> close() {
    _connectivitySub?.cancel();
    return super.close();
  }
}
