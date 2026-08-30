import 'package:geolens_capture/features/dashboard/models/upload_item.dart';
import 'package:geolens_capture/features/dashboard/services/mock_api_service.dart';
import 'package:geolens_capture/features/dashboard/services/shared_pref_service.dart';

class UploadRepository {
  UploadRepository({
    MockApiService? apiService,
    SharedPrefService? storageService,
  }) : _apiService = apiService ?? MockApiService(),
       _storageService = storageService ?? SharedPrefService();

  final MockApiService _apiService;
  final SharedPrefService _storageService;

  Future<List<UploadItem>> loadQueue() => _storageService.getUploadQueue();

  Future<void> saveQueue(List<UploadItem> items) =>
      _storageService.setUploadQueue(items);

  Future<String> uploadFile(
    UploadItem item, {
    void Function(double progress)? onProgress,
  }) {
    final forceFail = item.retryCount == 0 && _hardcodedShouldFail(item.id);

    return _apiService.uploadImage(
      item.localPath,
      onProgress: onProgress,
      forceFail: forceFail,
    );
  }

  bool _hardcodedShouldFail(String id) => id.hashCode.abs() % 10 < 3;
}
