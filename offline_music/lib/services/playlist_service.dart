import 'dart:io';

import 'package:offline_music_player/models/song_model.dart';

enum SongSortBy { title, artist, album, dateAdded }

class PlaylistService {
  /// Các thư mục phổ biến chứa nhạc trên Android
  final List<Directory> _musicCandidates = [
    Directory('/storage/emulated/0/Music'),
    Directory('/sdcard/Music'),
  ];

  /// Tìm thư mục Music hợp lệ
  Directory? _findMusicDirectory() {
    for (final dir in _musicCandidates) {
      if (dir.existsSync()) {
        return dir;
      }
    }
    return null;
  }

  /// Lấy toàn bộ bài hát từ file system
  Future<List<SongModel>> getAllSongs({
    SongSortBy sortBy = SongSortBy.title,
    bool ascending = true,
  }) async {
    final musicDir = _findMusicDirectory();
    if (musicDir == null) return [];

    final files = musicDir
        .listSync(recursive: true)
        .whereType<File>()
        .where(_isAudioFile)
        .toList();

    final songs = files.map(_fileToSong).toList();

    _sortSongs(songs, sortBy, ascending);

    return songs;
  }

  /// Kiểm tra file audio
  bool _isAudioFile(File f) {
    final p = f.path.toLowerCase();
    return p.endsWith('.mp3') || p.endsWith('.wav') || p.endsWith('.m4a');
  }

  /// Convert File → SongModel
  SongModel _fileToSong(File file) {
    final fileName = file.uri.pathSegments.last;
    final title = fileName.replaceAll(RegExp(r'\.(mp3|wav|m4a)$'), '');

    return SongModel(
      id: file.path,
      title: title,
      artist: 'Unknown artist',
      album: null,
      filePath: file.path,
      artwork: null, // chưa dùng metadata
    );
  }

  /// Sort danh sách bài hát
  void _sortSongs(
    List<SongModel> songs,
    SongSortBy sortBy,
    bool ascending,
  ) {
    int dir = ascending ? 1 : -1;

    songs.sort((a, b) {
      switch (sortBy) {
        case SongSortBy.title:
          return dir * a.title.compareTo(b.title);
        case SongSortBy.artist:
          return dir * a.artist.compareTo(b.artist);
        case SongSortBy.album:
          return dir *
              (a.album ?? '').compareTo(b.album ?? '');
        case SongSortBy.dateAdded:
          return 0; // file system không đảm bảo
      }
    });
  }

  /// Lấy danh sách artist
  List<String> extractArtists(List<SongModel> songs) {
    final set = <String>{};
    for (final s in songs) {
      if (s.artist.trim().isNotEmpty) {
        set.add(s.artist);
      }
    }
    return set.toList()..sort();
  }

  /// Lấy danh sách album
  List<String> extractAlbums(List<SongModel> songs) {
    final set = <String>{};
    for (final s in songs) {
      final a = s.album?.trim();
      if (a != null && a.isNotEmpty) {
        set.add(a);
      }
    }
    return set.toList()..sort();
  }
}