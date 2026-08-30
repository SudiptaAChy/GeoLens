import 'package:flutter/foundation.dart';
import 'package:geolens_capture/features/dashboard/models/upload_item.dart';

@immutable
class UploadQueueState {
  final List<UploadItem> items;
  final bool isSyncing;

  const UploadQueueState({this.items = const [], this.isSyncing = false});

  UploadQueueState copyWith({List<UploadItem>? items, bool? isSyncing}) {
    return UploadQueueState(
      items: items ?? this.items,
      isSyncing: isSyncing ?? this.isSyncing,
    );
  }
}
