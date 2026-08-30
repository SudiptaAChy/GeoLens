import 'package:geolens_capture/features/dashboard/models/upload_status.dart';
import 'package:geolens_capture/features/dashboard/repositories/upload_repository.dart';
import 'package:workmanager/workmanager.dart';

import 'connectivity_service.dart';

const uploadSyncTaskName = 'uploadSyncTask';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task != uploadSyncTaskName) return Future.value(true);

    final repository = UploadRepository();
    final connectivity = ConnectivityService();

    if (!await connectivity.isConnected()) {
      return Future.value(true);
    }

    var queue = await repository.loadQueue();
    final pending = queue.where(
      (i) =>
          i.status == UploadStatus.waiting || i.status == UploadStatus.failed,
    );

    for (final item in pending) {
      if (!await connectivity.isConnected()) break;

      queue = queue
          .map(
            (i) => i.id == item.id
                ? i.copyWith(status: UploadStatus.uploading, progress: 0)
                : i,
          )
          .toList();
      await repository.saveQueue(queue);

      try {
        final url = await repository.uploadFile(item);
        queue = queue
            .map(
              (i) => i.id == item.id
                  ? i.copyWith(
                      status: UploadStatus.success,
                      progress: 1.0,
                      remoteUrl: url,
                    )
                  : i,
            )
            .toList();
      } catch (_) {
        queue = queue
            .map(
              (i) => i.id == item.id
                  ? i.copyWith(
                      status: UploadStatus.failed,
                      retryCount: i.retryCount + 1,
                    )
                  : i,
            )
            .toList();
      }
      await repository.saveQueue(queue);
    }

    return Future.value(true);
  });
}
