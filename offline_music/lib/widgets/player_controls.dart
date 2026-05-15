import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:offline_music_player/providers/audio_provider.dart';
import 'package:offline_music_player/utils/constants.dart';

/// Cụm nút điều khiển phát nhạc (phong cách Spotify)
class PlayerControls extends StatelessWidget {
  const PlayerControls({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AudioProvider>();

    return Column(
      children: [
        /// ===== HÀNG NÚT SHUFFLE & REPEAT =====
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            /// Nút trộn bài (Shuffle)
            IconButton(
              icon: Icon(
                Icons.shuffle,
                size: 22,
                color: provider.isShuffleEnabled
                    ? AppColors.primary // Bật → xanh Spotify
                    : AppColors.subtitle,
              ),
              onPressed: provider.toggleShuffle,
            ),

            /// Nút lặp lại (Repeat)
            _buildRepeatButton(provider),
          ],
        ),

        const SizedBox(height: 24),

        /// ===== HÀNG NÚT CHÍNH =====
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// Quay lại bài trước
            IconButton(
              icon: const Icon(
                Icons.skip_previous,
                color: AppColors.text,
                size: 36,
              ),
              onPressed: provider.previous,
            ),

            const SizedBox(width: 20),

            /// ===== PLAY / PAUSE (NÚT TRUNG TÂM) =====
            StreamBuilder<bool>(
              stream: provider.playingStream,
              builder: (context, snapshot) {
                final isPlaying = snapshot.data ?? false;

                return Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary, // Spotify Green
                  ),
                  child: IconButton(
                    icon: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 42,
                    ),
                    onPressed: provider.playPause,
                  ),
                );
              },
            ),

            const SizedBox(width: 20),

            /// Chuyển sang bài tiếp theo
            IconButton(
              icon: const Icon(
                Icons.skip_next,
                color: AppColors.text,
                size: 36,
              ),
              onPressed: provider.next,
            ),
          ],
        ),
      ],
    );
  }

  /// Nút Repeat (Off / All / One)
  Widget _buildRepeatButton(AudioProvider provider) {
    IconData icon;
    Color color;

    switch (provider.loopMode) {
      case LoopMode.off:
        icon = Icons.repeat;
        color = AppColors.subtitle;
        break;

      case LoopMode.all:
        icon = Icons.repeat;
        color = AppColors.primary;
        break;

      case LoopMode.one:
        icon = Icons.repeat_one;
        color = AppColors.primary;
        break;
    }

    return IconButton(
      icon: Icon(icon, size: 22, color: color),
      onPressed: provider.toggleRepeat,
    );
  }
}
