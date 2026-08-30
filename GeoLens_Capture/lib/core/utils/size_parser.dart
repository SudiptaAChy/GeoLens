double parseSizeToBytes(String sizeText) {
  final match = RegExp(
    r'([\d.]+)\s*(KB|MB|GB|B)',
    caseSensitive: false,
  ).firstMatch(sizeText.trim());

  if (match == null) return 0;

  final value = double.tryParse(match.group(1) ?? '') ?? 0;
  final unit = (match.group(2) ?? 'B').toUpperCase();

  switch (unit) {
    case 'GB':
      return value * 1024 * 1024 * 1024;
    case 'MB':
      return value * 1024 * 1024;
    case 'KB':
      return value * 1024;
    default:
      return value;
  }
}

String formatBytes(double bytes) {
  if (bytes >= 1024 * 1024 * 1024) {
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
  if (bytes >= 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  if (bytes >= 1024) {
    return '${(bytes / 1024).toStringAsFixed(1)} KB';
  }
  return '${bytes.toStringAsFixed(0)} B';
}
