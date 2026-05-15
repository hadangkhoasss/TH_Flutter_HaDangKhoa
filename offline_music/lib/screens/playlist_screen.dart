import 'package:flutter/material.dart';
import 'package:offline_music_player/providers/playlist_provider.dart';
import 'package:offline_music_player/screens/playlist_detail_screen.dart';
import 'package:offline_music_player/utils/constants.dart';
import 'package:provider/provider.dart';

class PlaylistScreen extends StatelessWidget {
  const PlaylistScreen({super.key});

  // ===== HỘP THOẠI TẠO PLAYLIST MỚI =====
  Future<void> _showCreateDialog(BuildContext context) async {
    final controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          title: const Text(
            'New playlist',
            style: TextStyle(color: AppColors.text),
          ),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: AppColors.text),
            decoration: const InputDecoration(
              hintText: 'Playlist name',
              hintStyle: TextStyle(color: AppColors.subtitle),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  await context
                      .read<PlaylistProvider>()
                      .addPlaylist(name);
                }
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  // ===== HỘP THOẠI ĐỔI TÊN PLAYLIST =====
  Future<void> _showRenameDialog(
    BuildContext context, {
    required String playlistId,
    required String currentName,
  }) async {
    final controller = TextEditingController(text: currentName);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          title: const Text(
            'Rename playlist',
            style: TextStyle(color: AppColors.text),
          ),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: AppColors.text),
            decoration: const InputDecoration(
              hintText: 'New name',
              hintStyle: TextStyle(color: AppColors.subtitle),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  await context
                      .read<PlaylistProvider>()
                      .renamePlaylist(playlistId, name);
                }
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // ===== XÁC NHẬN XOÁ PLAYLIST =====
  Future<void> _confirmDelete(
    BuildContext context, {
    required String playlistId,
    required String playlistName,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          title: const Text(
            'Delete playlist',
            style: TextStyle(color: AppColors.text),
          ),
          content: Text(
            'Delete "$playlistName"?',
            style: const TextStyle(color: AppColors.subtitle),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (result == true && context.mounted) {
      await context
          .read<PlaylistProvider>()
          .deletePlaylist(playlistId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final playlists =
        context.watch<PlaylistProvider>().playlists;

    return Scaffold(
      backgroundColor: AppColors.background,

      // ===== APP BAR PHONG CÁCH SPOTIFY =====
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Your Playlists',
          style: TextStyle(
            color: AppColors.text,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.text),
            onPressed: () => _showCreateDialog(context),
          ),
        ],
      ),

      // ===== NỘI DUNG =====
      body: playlists.isEmpty
          // Không có playlist
          ? const Center(
              child: Text(
                'No playlists yet',
                style: TextStyle(
                  color: AppColors.subtitle,
                  fontSize: 16,
                ),
              ),
            )

          // Danh sách playlist
          : ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              itemCount: playlists.length,

              // Khoảng cách giữa các playlist
              separatorBuilder: (_, __) =>
                  const SizedBox(height: 6),

              itemBuilder: (context, index) {
                final p = playlists[index];

                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),

                    // Tên playlist
                    title: Text(
                      p.name,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    // Số lượng bài hát
                    subtitle: Text(
                      '${p.songIds.length} songs',
                      style: const TextStyle(
                        color: AppColors.subtitle,
                        fontSize: 13,
                      ),
                    ),

                    // Mở chi tiết playlist
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PlaylistDetailScreen(
                            playlistId: p.id,
                          ),
                        ),
                      );
                    },

                    // Menu 3 chấm (Rename / Delete)
                    trailing: PopupMenuButton<String>(
                      color: AppColors.card,
                      icon: const Icon(
                        Icons.more_vert,
                        color: AppColors.subtitle,
                      ),
                      onSelected: (value) async {
                        if (value == 'rename') {
                          await _showRenameDialog(
                            context,
                            playlistId: p.id,
                            currentName: p.name,
                          );
                        }
                        if (value == 'delete') {
                          await _confirmDelete(
                            context,
                            playlistId: p.id,
                            playlistName: p.name,
                          );
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: 'rename',
                          child: Text(
                            'Rename',
                            style: TextStyle(color: AppColors.text),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text(
                            'Delete',
                            style: TextStyle(color: AppColors.text),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
