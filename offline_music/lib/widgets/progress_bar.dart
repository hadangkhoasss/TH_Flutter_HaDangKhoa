import 'package:flutter/material.dart';
import 'package:offline_music_player/utils/constants.dart';
import 'package:offline_music_player/utils/duration_formatter.dart';

/// Thanh tiến trình phát nhạc (Spotify-style)
class ProgressBar extends StatelessWidget {
  /// Thời gian hiện tại của bài hát
  final Duration position;

  /// Tổng thời lượng bài hát
  final Duration duration;

  /// Callback khi người dùng kéo tua
  final Function(Duration) onSeek;

  const ProgressBar({
    super.key,
    required this.position,
    required this.duration,
    required this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    /// Giá trị tối đa của slider (milliseconds)
    final max = duration.inMilliseconds.toDouble();

    /// Giá trị hiện tại (giới hạn trong khoảng hợp lệ)
    final value = position.inMilliseconds
        .clamp(0, max)
        .toDouble();

    return Column(
      children: [
        /// ===== SLIDER TIẾN TRÌNH =====
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 2.5, // Mỏng giống Spotify
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 5,
            ),
            overlayShape: const RoundSliderOverlayShape(
              overlayRadius: 14,
            ),
            activeTrackColor: AppColors.primary, // Spotify Green
            inactiveTrackColor: AppColors.card,
            thumbColor: Colors.white,
            overlayColor: AppColors.primary.withOpacity(0.2),
          ),
          child: Slider(
            value: max == 0 ? 0 : value,
            min: 0.0,
            max: max == 0 ? 1 : max,

            /// Kéo slider → tua nhạc
            onChanged: (newValue) {
              onSeek(
                Duration(milliseconds: newValue.toInt()),
              );
            },
          ),
        ),

        /// ===== THỜI GIAN HIỆN TẠI / TỔNG =====
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /// Thời gian đã phát
              Text(
                formatDuration(position),
                style: const TextStyle(
                  color: AppColors.subtitle,
                  fontSize: 12,
                ),
              ),

              /// Tổng thời lượng
              Text(
                formatDuration(duration),
                style: const TextStyle(
                  color: AppColors.subtitle,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
