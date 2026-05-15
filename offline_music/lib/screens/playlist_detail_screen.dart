import 'package:flutter/material.dart';
import 'package:offline_music_player/models/song_model.dart';
import 'package:offline_music_player/providers/audio_provider.dart';
import 'package:offline_music_player/providers/playlist_provider.dart';
import 'package:offline_music_player/services/playlist_service.dart';
import 'package:offline_music_player/utils/constants.dart';
import 'package:offline_music_player/widgets/song_tile.dart';
import 'package:provider/provider.dart';

class PlaylistDetailScreen extends StatefulWidget {
  final String playlistId;

  const PlaylistDetailScreen({
    super.key,
    required this.playlistId,
  });

  @override
  State<PlaylistDetailScreen> createState() =>
      _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState
    extends State<PlaylistDetailScreen> {
  // Service dùng để lấy danh sách bài hát
  final PlaylistService _playlistService =
      PlaylistService();

  // Danh sách toàn bộ bài hát trong máy
  List<SongModel> _allSongs = [];

  // Trạng thái tải dữ liệu
  bool _loadingSongs = true;

  @override
  void initState() {
    super.initState();
    _loadAllSongs();
  }

  // Tải toàn bộ bài hát từ bộ nhớ
  Future<void> _loadAllSongs() async {
    try {
      final songs =
          await _playlistService.getAllSongs();
      setState(() {
        _allSongs = songs;
        _loadingSongs = false;
      });
    } catch (_) {
      setState(() => _loadingSongs = false);
    }
  }

  // Lọc bài hát theo danh sách id của playlist
  List<SongModel> _songsInPlaylist(
      List<String> songIds) {
    return songIds
        .map((id) =>
            _allSongs.where((s) => s.id == id).toList())
        .where((e) => e.isNotEmpty)
        .map((e) => e.first)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final playlistProvider =
        context.watch<PlaylistProvider>();
    final playlist = playlistProvider
        .getPlaylistById(widget.playlistId);

    return Scaffold(
      backgroundColor: AppColors.background,

      // Nút thêm bài hát (giống Spotify)
      floatingActionButton: playlist == null ||
              _loadingSongs
          ? null
          : FloatingActionButton(
              backgroundColor: AppColors.primary,
              onPressed: () => _showAddSongsSheet(
                context,
                playlist.songIds,
              ),
              child: const Icon(Icons.add),
            ),

      body: SafeArea(
        child: playlist == null
            ? _buildNotFound()
            : Column(
                children: [
                  _buildHeader(
                    context,
                    playlist.name,
                    playlist.songIds.length,
                  ),
                  Expanded(
                    child: _loadingSongs
                        ? const Center(
                            child:
                                CircularProgressIndicator(),
                          )
                        : _buildPlaylistBody(
                            context,
                            playlist.songIds,
                          ),
                  ),
                ],
              ),
      ),
    );
  }

  // ===== HEADER PLAYLIST =====
  Widget _buildHeader(
    BuildContext context,
    String name,
    int count,
  ) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.accent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '$count bài hát',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // Menu tuỳ chọn playlist
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert,
              color: Colors.white,
            ),
            onSelected: (v) async {
              if (v == 'rename') {
                await _renamePlaylist(context, name);
              }
              if (v == 'delete') {
                await _deletePlaylist(context, name);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'rename',
                child: Text(
                  'Đổi tên playlist',
                  style:
                      TextStyle(color: AppColors.text),
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Text(
                  'Xóa playlist',
                  style:
                      TextStyle(color: AppColors.text),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===== DANH SÁCH BÀI HÁT =====
  Widget _buildPlaylistBody(
    BuildContext context,
    List<String> ids,
  ) {
    final songs = _songsInPlaylist(ids);

    if (songs.isEmpty) {
      return const Center(
        child: Text(
          'Playlist này chưa có bài hát',
          style: TextStyle(color: AppColors.subtitle),
        ),
      );
    }

    return ListView.separated(
      padding:
          const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: songs.length,
      separatorBuilder: (_, __) =>
          const SizedBox(height: 6),
      itemBuilder: (context, index) {
        final song = songs[index];
        return SongTile(
          song: song,

          // Phát nhạc
          onTap: () {
            context
                .read<AudioProvider>()
                .setPlaylist(songs, index);
          },

          // Xóa bài khỏi playlist
          onRemove: () async {
            await context
                .read<PlaylistProvider>()
                .removeSongFromPlaylist(
                  widget.playlistId,
                  song.id,
                );
          }, dense: true,
        );
      },
    );
  }

  // Playlist không tồn tại
  Widget _buildNotFound() {
    return const Center(
      child: Text(
        'Không tìm thấy playlist',
        style: TextStyle(color: AppColors.text),
      ),
    );
  }

  // ===== CÁC HÀM CÓ SẴN (GIỮ NGUYÊN LOGIC) =====

  Future<void> _showAddSongsSheet(
    BuildContext context,
    List<String> currentIds,
  ) async {
    // giữ nguyên code của bạn
  }

  Future<void> _renamePlaylist(
    BuildContext context,
    String currentName,
  ) async {
    // giữ nguyên code của bạn
  }

  Future<void> _deletePlaylist(
    BuildContext context,
    String name,
  ) async {
    // giữ nguyên code của bạn
  }
}
