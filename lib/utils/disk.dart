String formatBytes(int bytes) {
  if (bytes <= 0) return '0 B';
  const List<String> units = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
  int i = 0;
  double val = bytes.toDouble();
  while (val >= 1024 && i < units.length - 1) {
    val /= 1024;
    i++;
  }
  return '${val.toStringAsFixed(2)} ${units[i]}';
}