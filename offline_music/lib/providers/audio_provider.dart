import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:offline_music_player/models/playback_state_model.dart';
import 'package:offline_music_player/models/song_model.dart';
import 'package:offline_music_player/services/audio_player_service.dart';
import 'package:offline_music_player/services/storage_service.dart';

class AudioProvider extends ChangeNotifier {
  final AudioPlayerService _audioService;
  final StorageService _storageService;

  List<SongModel> _playlist = [];
  int _currentIndex = 0;

  bool _isShuffleEnabled = false;
  LoopMode _loopMode = LoopMode.off;

  double _volume = 1.0;
  double _speed = 1.0;

  List<String> _recentlyPlayedIds = [];

  StreamSubscription<int?>? _indexSub;
  StreamSubscription<Duration>? _positionSub;

  DateTime _lastSavedAt = DateTime.fromMillisecondsSinceEpoch(0);

  AudioProvider(this._audioService, this._storageService) {
    _init();
  }

  // ===== GETTER =====
  List<SongModel> get playlist => _playlist;
  int get currentIndex => _currentIndex;
  SongModel? get currentSong =>
      _playlist.isEmpty ? null : _playlist[_currentIndex];

  bool get isShuffleEnabled => _isShuffleEnabled;
  LoopMode get loopMode => _loopMode;

  double get volume => _volume;
  double get speed => _speed;

  List<String> get recentlyPlayedIds => _recentlyPlayedIds;

  /// Trả về danh sách SongModel từ danh sách ID đã phát
  List<SongModel> get recentlyPlayedSongs {
    if (_playlist.isEmpty || _recentlyPlayedIds.isEmpty) return [];

    return _recentlyPlayedIds
        .map((id) {
          try {
            return _playlist.firstWhere((s) => s.id == id);
          } catch (e) {
            return null;
          }
        })
        .whereType<SongModel>()
        .toList();
  }

  // Streams từ audio service
  Stream<Duration> get positionStream => _audioService.positionStream;
  Stream<Duration?> get durationStream => _audioService.durationStream;
  Stream<bool> get playingStream => _audioService.playingStream;
  Stream<PlaybackState> get playbackStateStream =>
      _audioService.playbackStateStream;

  // ===== INIT =====
  Future<void> _init() async {
    await _audioService.init();

    _isShuffleEnabled = await _storageService.getShuffleState();
    final repeat = await _storageService.getRepeatMode();
    _loopMode = _mapRepeatToLoopMode(repeat);

    _volume = await _storageService.getVolume();
    _speed = await _storageService.getSpeed();

    _recentlyPlayedIds = await _storageService.getRecentlyPlayed();

    await _audioService.setShuffleModeEnabled(_isShuffleEnabled);
    await _audioService.setLoopMode(_loopMode);
    await _audioService.setVolume(_volume);
    await _audioService.setSpeed(_speed);

    _indexSub = _audioService.currentIndexStream.listen((index) {
      if (index == null) return;
      _handleIndexChanged(index);
    });

    _positionSub = _audioService.positionStream.listen((pos) {
      _savePositionThrottled(pos);
    });
  }

  // Map repeat <-> loopMode
  LoopMode _mapRepeatToLoopMode(int repeat) {
    if (repeat == 1) return LoopMode.all;
    if (repeat == 2) return LoopMode.one;
    return LoopMode.off;
  }

  int _mapLoopModeToRepeat(LoopMode mode) {
    if (mode == LoopMode.all) return 1;
    if (mode == LoopMode.one) return 2;
    return 0;
  }

  // ===== HANDLE INDEX CHANGE =====
  Future<void> _handleIndexChanged(int index) async {
    if (_playlist.isEmpty) return;
    if (index < 0 || index >= _playlist.length) return;

    _currentIndex = index;

    final song = _playlist[_currentIndex];
    await _storageService.saveLastPlayed(song.id);

    // Thêm vào lịch sử nghe gần đây (Spotify style)
    await _storageService.addRecentlyPlayed(song.id);

    // Cập nhật danh sách _recentlyPlayedIds
    _recentlyPlayedIds = await _storageService.getRecentlyPlayed();

    notifyListeners();
  }

  // ===== SAVE POSITION THROTTLED =====
  Future<void> _savePositionThrottled(Duration position) async {
    final song = currentSong;
    if (song == null) return;

    final now = DateTime.now();
    if (now.difference(_lastSavedAt).inSeconds < 3) return;

    _lastSavedAt = now;
    await _storageService.savePlaybackPosition(song.id, position);
  }

  // ===== SET PLAYLIST =====
  Future<void> setPlaylist(
    List<SongModel> songs,
    int startIndex, {
    bool autoPlay = true,
  }) async {
    if (songs.isEmpty) return;
    if (startIndex < 0 || startIndex >= songs.length) return;

    _playlist = songs;
    _currentIndex = startIndex;

    final initialSong = songs[startIndex];
    final initialPos =
        await _storageService.getPlaybackPosition(initialSong.id);

    await _audioService.setPlaylist(
      songs.map((s) => s.filePath).toList(),
      initialIndex: startIndex,
      initialPosition: initialPos,
    );

    await _audioService.setShuffleModeEnabled(_isShuffleEnabled);
    await _audioService.setLoopMode(_loopMode);
    await _audioService.setVolume(_volume);
    await _audioService.setSpeed(_speed);

    // Thêm vào lịch sử
    await _handleIndexChanged(startIndex);

    if (autoPlay) {
      await _audioService.play();
    } else {
      await _audioService.pause();
    }

    notifyListeners();
  }

  // ===== RESTORE LAST SESSION =====
  Future<void> restoreLastSession(List<SongModel> allSongs) async {
    if (currentSong != null) return;
    if (allSongs.isEmpty) return;

    final lastId = await _storageService.getLastPlayed();
    if (lastId == null) return;

    final index = allSongs.indexWhere((s) => s.id == lastId);
    if (index == -1) return;

    await setPlaylist(allSongs, index, autoPlay: false);
  }

  // ===== PLAY / PAUSE =====
  Future<void> playPause() async {
    final song = currentSong;
    if (song == null) return;

    if (_audioService.isPlaying) {
      await _audioService.pause();
      await _storageService.savePlaybackPosition(
        song.id,
        _audioService.currentPosition,
      );
    } else {
      await _audioService.play();
    }

    notifyListeners();
  }

  // ===== NEXT / PREVIOUS =====
  Future<void> next() async {
    if (_playlist.isEmpty) return;

    if (_audioService.hasNext) {
      await _audioService.seekToNext();
      await _audioService.play();
    } else if (_loopMode == LoopMode.all) {
      await _audioService.seekToIndex(0);
      await _audioService.play();
    }
  }

  Future<void> previous() async {
    if (_playlist.isEmpty) return;

    if (_audioService.currentPosition.inSeconds > 3) {
      await _audioService.seek(Duration.zero);
      return;
    }

    if (_audioService.hasPrevious) {
      await _audioService.seekToPrevious();
      await _audioService.play();
    } else if (_loopMode == LoopMode.all) {
      await _audioService.seekToIndex(_playlist.length - 1);
      await _audioService.play();
    }
  }

  // ===== SEEK =====
  Future<void> seek(Duration position) async {
    await _audioService.seek(position);
  }

  // ===== SHUFFLE / REPEAT =====
  Future<void> toggleShuffle() async {
    _isShuffleEnabled = !_isShuffleEnabled;
    await _storageService.saveShuffleState(_isShuffleEnabled);
    await _audioService.setShuffleModeEnabled(_isShuffleEnabled);
    notifyListeners();
  }

  Future<void> toggleRepeat() async {
    if (_loopMode == LoopMode.off) {
      _loopMode = LoopMode.all;
    } else if (_loopMode == LoopMode.all) {
      _loopMode = LoopMode.one;
    } else {
      _loopMode = LoopMode.off;
    }

    await _audioService.setLoopMode(_loopMode);
    await _storageService.saveRepeatMode(_mapLoopModeToRepeat(_loopMode));
    notifyListeners();
  }

  // ===== VOLUME / SPEED =====
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await _audioService.setVolume(_volume);
    await _storageService.saveVolume(_volume);
    notifyListeners();
  }

  Future<void> setSpeed(double speed) async {
    _speed = speed.clamp(0.5, 2.0);
    await _audioService.setSpeed(_speed);
    await _storageService.saveSpeed(_speed);
    notifyListeners();
  }

  // ===== CLEAR RECENTLY PLAYED =====
  Future<void> clearRecentlyPlayed() async {
    _recentlyPlayedIds = [];
    await _storageService.clearRecentlyPlayed();
    notifyListeners();
  }

  // ===== DISPOSE =====
  @override
  void dispose() {
    _indexSub?.cancel();
    _positionSub?.cancel();
    _audioService.dispose();
    super.dispose();
  }
}
