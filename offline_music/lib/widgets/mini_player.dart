import 'package:flutter/material.dart';
import 'package:offline_music_player/models/playback_state_model.dart';
import 'package:offline_music_player/providers/audio_provider.dart';
import 'package:offline_music_player/screens/now_playing_screen.dart';
import 'package:offline_music_player/utils/constants.dart';
import 'package:offline_music_player/widgets/album_art.dart';
import 'package:provider/provider.dart';

/// Mini Player – thanh phát nhạc thu gọn (phong cách Spotify)
class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      /// Nhấn vào mini player → mở màn hình Now Playing
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const NowPlayingScreen(),
          ),
        );
      },

      child: Container(
        height: 80,

        /// Nền + bóng đổ giống Spotify
        decoration: BoxDecoration(
          color: AppColors.card,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),

        /// Lắng nghe AudioProvider
        child: Consumer<AudioProvider>(
          builder: (context, provider, _) {
            final song = provider.currentSong;

            /// Không có bài hát → ẩn mini player
            if (song == null) {
              return const SizedBox.shrink();
            }

            return Column(
              children: [
                /// ===== THANH TIẾN TRÌNH PHÁT NHẠC =====
                StreamBuilder<PlaybackState>(
                  stream: provider.playbackStateStream,
                  builder: (context, snapshot) {
                    final progress = snapshot.data?.progress ?? 0.0;

                    return LinearProgressIndicator(
                      value: progress,
                      minHeight: 2,
                      backgroundColor: Colors.grey[800],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary, // Spotify Green
                      ),
                    );
                  },
                ),

                /// ===== NỘI DUNG MINI PLAYER =====
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        /// Ảnh album
                        AlbumArt(
                          song: song,
                          size: 50,
                        ),

                        const SizedBox(width: 12),

                        /// Thông tin bài hát
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// Tên bài hát
                              Text(
                                song.title,
                                style: const TextStyle(
                                  color: AppColors.text,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),

                              /// Nghệ sĩ
                              Text(
                                song.artist,
                                style: const TextStyle(
                                  color: AppColors.subtitle,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        /// ===== NÚT PLAY / PAUSE =====
                        StreamBuilder<bool>(
                          stream: provider.playingStream,
                          builder: (context, snapshot) {
                            final isPlaying = snapshot.data ?? false;

                            return IconButton(
                              icon: Icon(
                                isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                color: AppColors.text,
                                size: 32,
                              ),
                              onPressed: provider.playPause,
                            );
                          },
                        ),

                        /// ===== NÚT NEXT =====
                        IconButton(
                          icon: const Icon(
                            Icons.skip_next,
                            color: AppColors.text,
                          ),
                          onPressed: provider.next,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
