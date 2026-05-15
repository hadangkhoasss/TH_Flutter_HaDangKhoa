import 'dart:convert';

import 'package:offline_music_player/models/playlist_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  // ===== KEY LƯU TRỮ TRONG SHARED PREFERENCES =====

  // Danh sách playlist người dùng
  static const String _playlistsKey = 'playlists';

  // Bài hát phát gần nhất
  static const String _lastPlayedKey = 'last_played';

  // Trạng thái trộn bài (shuffle)
  static const String _shuffleKey = 'shuffle_enabled';

  // Chế độ lặp (0: tắt, 1: lặp tất cả, 2: lặp 1 bài)
  static const String _repeatKey = 'repeat_mode';

  // Âm lượng phát nhạc
  static const String _volumeKey = 'volume';

  // Tốc độ phát nhạc
  static const String _speedKey = 'playback_speed';

  // Danh sách bài hát nghe gần đây
  static const String _recentlyPlayedKey = 'recently_played';

  // Vị trí phát của từng bài (resume)
  static const String _playbackPositionsKey = 'playback_positions';

  // ===== PLAYLIST =====

  // Lưu toàn bộ playlist vào bộ nhớ
  Future<void> savePlaylists(List<PlaylistModel> playlists) async {
    final prefs = await SharedPreferences.getInstance();
    final playlistsJson = playlists.map((p) => p.toJson()).toList();
    await prefs.setString(
      _playlistsKey,
      json.encode(playlistsJson),
    );
  }

  // Lấy danh sách playlist đã lưu
  Future<List<PlaylistModel>> getPlaylists() async {
    final prefs = await SharedPreferences.getInstance();
    final playlistsString = prefs.getString(_playlistsKey);

    if (playlistsString != null) {
      final List<dynamic> playlistsJson =
      json.decode(playlistsString);
      return playlistsJson
          .map(
            (item) => PlaylistModel.fromJson(
          item as Map<String, dynamic>,
        ),
      )
          .toList();
    }

    return [];
  }

  // ===== BÀI HÁT PHÁT GẦN NHẤT =====

  // Lưu ID bài hát vừa phát
  Future<void> saveLastPlayed(String songId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastPlayedKey, songId);
  }

  // Lấy ID bài hát phát gần nhất
  Future<String?> getLastPlayed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastPlayedKey);
  }

  // ===== SHUFFLE =====

  // Lưu trạng thái shuffle
  Future<void> saveShuffleState(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_shuffleKey, enabled);
  }

  // Lấy trạng thái shuffle
  Future<bool> getShuffleState() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_shuffleKey) ?? false;
  }

  // ===== REPEAT =====

  // Lưu chế độ lặp
  // 0: không lặp | 1: lặp tất cả | 2: lặp 1 bài
  Future<void> saveRepeatMode(int mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_repeatKey, mode);
  }

  // Lấy chế độ lặp
  Future<int> getRepeatMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_repeatKey) ?? 0;
  }

  // ===== ÂM LƯỢNG =====

  // Lưu âm lượng
  Future<void> saveVolume(double volume) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_volumeKey, volume);
  }

  // Lấy âm lượng
  Future<double> getVolume() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_volumeKey) ?? 1.0;
  }

  // ===== TỐC ĐỘ PHÁT =====

  // Lưu tốc độ phát (0.5x – 2.0x)
  Future<void> saveSpeed(double speed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_speedKey, speed);
  }

  // Lấy tốc độ phát
  Future<double> getSpeed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_speedKey) ?? 1.0;
  }

  // ===== NGHE GẦN ĐÂY (SPOTIFY STYLE) =====

  // Lấy danh sách bài hát nghe gần đây
  Future<List<String>> getRecentlyPlayed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_recentlyPlayedKey) ?? [];
  }

  // Thêm bài hát vào danh sách nghe gần đây
  // - Bài mới nhất luôn nằm đầu
  // - Không trùng lặp
  // - Giới hạn số lượng (mặc định 20)
  Future<void> addRecentlyPlayed(
      String songId, {
        int limit = 20,
      }) async {
    final prefs = await SharedPreferences.getInstance();
    final list =
        prefs.getStringList(_recentlyPlayedKey) ?? [];

    // Xóa nếu đã tồn tại
    list.remove(songId);

    // Thêm lên đầu danh sách
    list.insert(0, songId);

    // Cắt bớt nếu vượt giới hạn
    if (list.length > limit) {
      list.removeRange(limit, list.length);
    }

    await prefs.setStringList(_recentlyPlayedKey, list);
  }

  // Xóa toàn bộ lịch sử nghe gần đây
  Future<void> clearRecentlyPlayed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recentlyPlayedKey);
  }

  // ===== GHI NHỚ VỊ TRÍ PHÁT (RESUME) =====

  // Lưu vị trí phát hiện tại của bài hát
  Future<void> savePlaybackPosition(
      String songId,
      Duration position,
      ) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_playbackPositionsKey);

    final Map<String, dynamic> map =
    raw != null
        ? json.decode(raw)
    as Map<String, dynamic>
        : {};

    map[songId] = position.inMilliseconds;

    await prefs.setString(
      _playbackPositionsKey,
      json.encode(map),
    );
  }

  // Lấy vị trí phát đã lưu của bài hát
  Future<Duration> getPlaybackPosition(
      String songId,
      ) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_playbackPositionsKey);

    if (raw == null) {
      return Duration.zero;
    }

    final Map<String, dynamic> map =
    json.decode(raw) as Map<String, dynamic>;

    final value = map[songId];

    if (value is int) {
      return Duration(milliseconds: value);
    }

    return Duration.zero;
  }
}
