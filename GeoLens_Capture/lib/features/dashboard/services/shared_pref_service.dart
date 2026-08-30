import 'package:geolens_capture/features/dashboard/models/upload_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefService {
  static const _uploadQueueKey = 'pending_uploads_queue';

  Future<List<UploadItem>> getUploadQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_uploadQueueKey);
    if (raw == null || raw.isEmpty) return [];

    try {
      return UploadItem.decodeList(raw);
    } catch (_) {
      return [];
    }
  }

  Future<void> setUploadQueue(List<UploadItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_uploadQueueKey, UploadItem.encodeList(items));
  }

  Future<void> clearUploadQueue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_uploadQueueKey);
  }
}
