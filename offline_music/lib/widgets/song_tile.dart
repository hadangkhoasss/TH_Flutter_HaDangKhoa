import 'package:flutter/material.dart';
import 'package:offline_music_player/models/song_model.dart';
import 'package:offline_music_player/providers/playlist_provider.dart';
import 'package:offline_music_player/utils/constants.dart';
import 'package:offline_music_player/utils/duration_formatter.dart';
import 'package:provider/provider.dart';

/// Item hiển thị 1 bài hát – phong cách Spotify
class SongTile extends StatelessWidget {
  final SongModel song;
  final VoidCallback onTap;
  final bool showOptions;
  final VoidCallback? onRemove;

  const SongTile({
    super.key,
    required this.song,
    required this.onTap,
    this.showOptions = true,
    this.onRemove, required bool dense,
  });

  @override
  Widget build(BuildContext context) {
    // Nghệ sĩ • Album
    final subtitleText =
        song.album != null && song.album!.trim().isNotEmpty
            ? '${song.artist} • ${song.album}'
            : song.artist;

    // Thời lượng (mm:ss)
    final durationText = song.duration != null
        ? formatDuration(song.duration!)
        : '';

    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 6),

      /// Ảnh album (Spotify style)
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.asset(
          'assets/images/default_album_art.jpg',
          width: 52,
          height: 52,
          fit: BoxFit.cover,
        ),
      ),

      /// Tên bài hát
      title: Text(
        song.title,
        style: const TextStyle(
          color: AppColors.text,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),

      /// Nghệ sĩ • Album
      subtitle: Text(
        subtitleText,
        style: const TextStyle(color: AppColors.subtitle),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),

      /// Cột phải
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Thời lượng
          if (durationText.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                durationText,
                style: const TextStyle(
                  color: AppColors.subtitle,
                  fontSize: 12,
                ),
              ),
            ),

          // Xoá khỏi playlist
          if (onRemove != null)
            IconButton(
              icon: const Icon(
                Icons.remove_circle_outline,
                color: AppColors.subtitle,
              ),
              onPressed: onRemove,
            )
          // Menu 3 chấm
          else if (showOptions)
            IconButton(
              icon: const Icon(
                Icons.more_vert,
                color: AppColors.subtitle,
              ),
              onPressed: () => _showOptionsMenu(context),
            ),
        ],
      ),

      onTap: onTap,
    );
  }

  // ================= MENU TUỲ CHỌN =================
  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading:
                    const Icon(Icons.playlist_add, color: AppColors.text),
                title: const Text(
                  'Thêm vào playlist',
                  style: TextStyle(color: AppColors.text),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showAddToPlaylistSheet(context);
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.info_outline, color: AppColors.text),
                title: const Text(
                  'Thông tin bài hát',
                  style: TextStyle(color: AppColors.text),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showSongInfo(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ================= THÔNG TIN BÀI HÁT =================
  void _showSongInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(song.title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nghệ sĩ: ${song.artist}'),
              Text('Album: ${song.album ?? 'Không rõ'}'),
              Text('Đường dẫn: ${song.filePath}'),
              Text(
                'Thời lượng: ${song.duration != null ? formatDuration(song.duration!) : 'Không rõ'}',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }

  // ================= THÊM VÀO PLAYLIST =================
  void _showAddToPlaylistSheet(BuildContext context) {
    final playlistProvider = context.read<PlaylistProvider>();
    final playlists = playlistProvider.playlists;

    if (playlists.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chưa có playlist nào.'),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      builder: (_) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: playlists.map((p) {
              return ListTile(
                title: Text(
                  p.name,
                  style: const TextStyle(color: AppColors.text),
                ),
                subtitle: Text(
                  '${p.songIds.length} bài hát',
                  style:
                      const TextStyle(color: AppColors.subtitle),
                ),
                onTap: () async {
                  await playlistProvider.addSongToPlaylist(
                    p.id,
                    song.id,
                  );
                  if (context.mounted) Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đã thêm vào "${p.name}"'),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
