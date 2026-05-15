String formatDuration(Duration time) {
  // Tổng số giây
  final totalSeconds = time.inSeconds;

  // Tính phút và giây
  final minutes = (totalSeconds ~/ 60) % 60;
  final seconds = totalSeconds % 60;

  // Định dạng mm:ss
  return '${minutes.toString().padLeft(2, '0')}:'
         '${seconds.toString().padLeft(2, '0')}';
}
