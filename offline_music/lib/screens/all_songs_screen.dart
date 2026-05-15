import 'package:flutter/material.dart';
import 'package:offline_music_player/models/song_model.dart';
import 'package:offline_music_player/services/playlist_service.dart';
import 'package:offline_music_player/utils/constants.dart';
import 'package:offline_music_player/widgets/song_tile.dart';


class AllSongsScreen extends StatefulWidget {
  const AllSongsScreen({super.key});

  @override
  State<AllSongsScreen> createState() => _AllSongsScreenState();
}

class _AllSongsScreenState extends State<AllSongsScreen> {
  // Service lấy danh sách bài hát từ bộ nhớ
  final PlaylistService _playlistService = PlaylistService();

  // Danh sách toàn bộ bài hát
  List<SongModel> _songs = [];

  // Trạng thái loading
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSongs();
  }

  // Load toàn bộ bài hát
  Future<void> _loadSongs() async {
    try {
      final songs = await _playlistService.getAllSongs();
      setState(() {
        _songs = songs;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // ===== APP BAR PHONG CÁCH SPOTIFY =====
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        centerTitle: false,
        title: const Text(
          'All Songs',
          style: TextStyle(
            color: AppColors.text,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // ===== NỘI DUNG =====
      body: _isLoading
          // Đang load
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )

          // Không có bài hát
          : _songs.isEmpty
              ? const Center(
                  child: Text(
                    'No songs found',
                    style: TextStyle(
                      color: AppColors.subtitle,
                      fontSize: 16,
                    ),
                  ),
                )

              // Danh sách bài hát
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),

                  // Số lượng bài hát
                  itemCount: _songs.length,

                  // Khoảng cách giữa các item (giống Spotify)
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 4),

                  itemBuilder: (context, index) {
                    final song = _songs[index];

                    return SongTile(
                      song: song,

                      // Bấm để phát (có thể gắn AudioProvider sau)
                      onTap: () {
                        // TODO: kết nối AudioProvider nếu cần
                      }, dense: true,
                    );
                  },
                ),
    );
  }
}
