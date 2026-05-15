String formatDuration(Duration d) {
  // Tổng số giây
  final total = d.inSeconds;

  // Tính phút và giây
  final m = (total ~/ 60) % 60;
  final s = total % 60;

  // Trả về dạng mm:ss
  return '${m.toString().padLeft(2, '0')}:'
         '${s.toString().padLeft(2, '0')}';
}
