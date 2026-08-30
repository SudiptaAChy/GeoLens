import 'dart:io';
import 'dart:math';

class MockApiService {
  final Random _random = Random();

  Future<String> uploadImage(
    String localPath, {
    void Function(double progress)? onProgress,
    required bool forceFail,
  }) async {
    final file = File(localPath);
    if (!await file.exists()) {
      throw Exception('Local file missing: $localPath');
    }

    final totalDelayMs = 3000 + _random.nextInt(2000); // 3000–5000 ms
    const steps = 10;
    final stepDelay = totalDelayMs ~/ steps;

    for (var i = 1; i <= steps; i++) {
      await Future.delayed(Duration(milliseconds: stepDelay));
      onProgress?.call(i / steps);
    }

    if (forceFail) {
      throw Exception('Mock upload failed (simulated network error)');
    }

    final fakeId = DateTime.now().millisecondsSinceEpoch;
    return 'https://mock-api.geolens.dev/uploads/$fakeId';
  }
}
