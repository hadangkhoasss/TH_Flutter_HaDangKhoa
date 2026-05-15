import 'package:flutter/material.dart';
import 'package:offline_music_player/models/song_model.dart';
import 'package:offline_music_player/providers/audio_provider.dart';
import 'package:offline_music_player/services/permission_service.dart';
import 'package:offline_music_player/services/playlist_service.dart';
import 'package:offline_music_player/utils/constants.dart';
import 'package:offline_music_player/widgets/mini_player.dart';
import 'package:offline_music_player/widgets/song_tile.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Service lấy danh sách nhạc từ bộ nhớ
  final PlaylistService _playlistService = PlaylistService();

  // Service xử lý quyền truy cập storage
  final PermissionService _permissionService = PermissionService();

  // Controller cho ô tìm kiếm
  final TextEditingController _searchController = TextEditingController();

  // Danh sách bài hát gốc
  List<SongModel> _allSongs = [];

  // Danh sách bài hát sau khi lọc / tìm kiếm
  List<SongModel> _displaySongs = [];

  // Trạng thái loading & quyền
  bool _isLoading = true;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();

    // Lắng nghe search để lọc realtime
    _searchController.addListener(_applySearch);

    // Khởi tạo app
    _initApp();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Khởi tạo: xin quyền + load nhạc
  Future<void> _initApp() async {
    _hasPermission = await _permissionService.hasPermissions();

    if (!_hasPermission) {
      _hasPermission =
          await _permissionService.requestNeededPermissions();
    }

    if (_hasPermission) {
      _allSongs = await _playlistService.getAllSongs();
      _displaySongs = List.from(_allSongs);
    }

    setState(() => _isLoading = false);
  }

  /// Lọc danh sách bài hát theo search
  void _applySearch() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      _displaySongs = _allSongs
          .where((s) =>
              s.title.toLowerCase().contains(query) ||
              s.artist.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : !_hasPermission
                      ? _buildPermissionDenied()
                      : _buildSongList(),
            ),

            // Mini player chỉ hiện khi đang phát nhạc
            Consumer<AudioProvider>(
              builder: (_, p, __) =>
                  p.currentSong == null
                      ? const SizedBox()
                      : const MiniPlayer(),
            ),
          ],
        ),
      ),
    );
  }

  /// Header + Search (style Spotify)
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Library',
            style: TextStyle(
              color: AppColors.text,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Ô tìm kiếm
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 14,
              ),
              decoration: const InputDecoration(
                icon: Icon(Icons.search, color: AppColors.subtitle),
                hintText: 'Search songs or artists',
                hintStyle:
                    TextStyle(color: AppColors.subtitle, fontSize: 14),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Danh sách bài hát
  Widget _buildSongList() {
    if (_displaySongs.isEmpty) {
      return const Center(
        child: Text(
          'No music found',
          style: TextStyle(color: AppColors.subtitle),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: _displaySongs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 2),
      itemBuilder: (_, index) {
        final song = _displaySongs[index];

        return SongTile(
          dense: true, // item thấp – giống Spotify
          song: song,
          onTap: () {
            // Phát bài theo index trong playlist gốc
            final realIndex =
                _allSongs.indexWhere((s) => s.id == song.id);

            if (realIndex != -1) {
              context
                  .read<AudioProvider>()
                  .setPlaylist(_allSongs, realIndex);
            }
          },
        );
      },
    );
  }

  /// Màn hình khi chưa có quyền
  Widget _buildPermissionDenied() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.music_off,
              size: 64, color: AppColors.subtitle),
          const SizedBox(height: 16),
          const Text(
            'Storage permission required',
            style: TextStyle(color: AppColors.text),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: openAppSettings,
            child: const Text('Open settings'),
          ),
        ],
      ),
    );
  }
}
