import 'package:flutter/material.dart';
import 'package:offline_music_player/models/playlist_model.dart';
import 'package:offline_music_player/utils/constants.dart';

/// Thẻ playlist – hiển thị danh sách phát (phong cách Spotify)
class PlaylistCard extends StatelessWidget {
  /// Dữ liệu playlist
  final PlaylistModel playlist;

  /// Sự kiện khi nhấn vào playlist
  final VoidCallback onTap;

  const PlaylistCard({
    super.key,
    required this.playlist,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      /// Hiệu ứng ripple khi bấm (Spotify-style)
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),

      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(12),

        /// Nền + bo góc
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
        ),

        child: Row(
          children: [
            /// Ảnh playlist (placeholder)
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.queue_music,
                color: AppColors.subtitle,
                size: 28,
              ),
            ),

            const SizedBox(width: 12),

            /// Thông tin playlist
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Tên playlist
                  Text(
                    playlist.name,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  /// Số lượng bài hát
                  Text(
                    '${playlist.songIds.length} bài hát',
                    style: const TextStyle(
                      color: AppColors.subtitle,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            /// Icon điều hướng
            const Icon(
              Icons.chevron_right,
              color: AppColors.subtitle,
            ),
          ],
        ),
      ),
    );
  }
}
