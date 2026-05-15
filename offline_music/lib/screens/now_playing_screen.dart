import 'package:flutter/material.dart';
import 'package:offline_music_player/models/playback_state_model.dart';
import 'package:offline_music_player/models/song_model.dart';
import 'package:offline_music_player/providers/audio_provider.dart';
import 'package:offline_music_player/utils/constants.dart';
import 'package:offline_music_player/widgets/player_controls.dart';
import 'package:offline_music_player/widgets/progress_bar.dart';
import 'package:provider/provider.dart';

class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<AudioProvider>(
          builder: (context, provider, _) {
            // Lấy bài hát hiện tại
            final song = provider.currentSong;

            // Không có bài nào đang phát
            if (song == null) {
              return const Center(
                child: Text(
                  'No song playing',
                  style: TextStyle(color: AppColors.text),
                ),
              );
            }

            return Column(
              children: [
                _buildTopBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),

                        // Ảnh album (trung tâm giao diện)
                        _buildAlbumArt(song),

                        const SizedBox(height: 32),

                        // Tên bài hát – ca sĩ – album
                        _buildSongInfo(song),

                        const SizedBox(height: 24),

                        // Thanh tiến trình phát nhạc
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: StreamBuilder<PlaybackState>(
                            stream: provider.playbackStateStream,
                            builder: (context, snapshot) {
                              final state = snapshot.data;
                              return ProgressBar(
                                position:
                                    state?.position ?? Duration.zero,
                                duration:
                                    state?.duration ?? Duration.zero,
                                onSeek: provider.seek,
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Nút điều khiển: play / pause / next / previous
                        const PlayerControls(),

                        const SizedBox(height: 24),

                        // Thanh chỉnh âm lượng
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: _buildVolume(provider),
                        ),

                        const SizedBox(height: 12),

                        // Điều chỉnh tốc độ phát
                        _buildSpeed(provider),

                        const SizedBox(height: 32),
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

  // ===== THANH TRÊN CÙNG (NÚT ĐÓNG + TIÊU ĐỀ) =====
  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Row(
        children: [
          // Nút quay lại (đóng màn hình Now Playing)
          IconButton(
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.text,
              size: 32,
            ),
            onPressed: () => Navigator.pop(context),
          ),

          // Tiêu đề ở giữa (phong cách Spotify)
          const Expanded(
            child: Center(
              child: Text(
                'NOW PLAYING',
                style: TextStyle(
                  color: AppColors.subtitle,
                  fontSize: 13,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // Giữ layout cân đối
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  // ===== ẢNH ALBUM =====
  Widget _buildAlbumArt(SongModel song) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: AspectRatio(
        aspectRatio: 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            color: AppColors.card,
            child: song.artwork != null
                ? Image.memory(
                    song.artwork!,
                    fit: BoxFit.cover,
                  )
                : const Icon(
                    Icons.music_note_rounded,
                    size: 100,
                    color: AppColors.subtitle,
                  ),
          ),
        ),
      ),
    );
  }

  // ===== THÔNG TIN BÀI HÁT =====
  Widget _buildSongInfo(SongModel song) {
    final album =
        (song.album == null || song.album!.isEmpty)
            ? 'Unknown Album'
            : song.album!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          // Tên bài hát
          Text(
            song.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          // Tên ca sĩ
          Text(
            song.artist,
            style: const TextStyle(
              color: AppColors.subtitle,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 2),

          // Tên album
          Text(
            album,
            style: const TextStyle(
              color: AppColors.subtitle,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ===== ĐIỀU CHỈNH ÂM LƯỢNG =====
  Widget _buildVolume(AudioProvider provider) {
    return Row(
      children: [
        const Icon(Icons.volume_down_rounded,
            color: AppColors.subtitle),
        Expanded(
          child: Slider(
            value: provider.volume,
            min: 0,
            max: 1,
            activeColor: AppColors.primary,
            inactiveColor: AppColors.card,
            onChanged: provider.setVolume,
          ),
        ),
        const Icon(Icons.volume_up_rounded,
            color: AppColors.subtitle),
      ],
    );
  }

  // ===== TỐC ĐỘ PHÁT NHẠC =====
  Widget _buildSpeed(AudioProvider provider) {
    const speeds = [0.75, 1.0, 1.25, 1.5, 2.0];

    return PopupMenuButton<double>(
      color: AppColors.card,
      onSelected: provider.setSpeed,
      itemBuilder: (context) => speeds
          .map(
            (s) => PopupMenuItem(
              value: s,
              child: Text(
                '${s}x',
                style: const TextStyle(color: AppColors.text),
              ),
            ),
          )
          .toList(),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '${provider.speed}x',
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
