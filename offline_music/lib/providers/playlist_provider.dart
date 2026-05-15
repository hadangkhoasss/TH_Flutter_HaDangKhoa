import 'package:flutter/material.dart';
import 'package:offline_music_player/models/playlist_model.dart';
import 'package:offline_music_player/services/storage_service.dart';

class PlaylistProvider extends ChangeNotifier {
  final StorageService _storageService;

  List<PlaylistModel> _playlists = [];

  PlaylistProvider(this._storageService) {
    _loadPlaylists();
  }

  List<PlaylistModel> get playlists => _playlists;

  PlaylistModel? getPlaylistById(String id) {
    final index = _playlists.indexWhere((p) => p.id == id);
    if (index == -1) return null;
    return _playlists[index];
  }

  Future<void> _loadPlaylists() async {
    _playlists = await _storageService.getPlaylists();
    notifyListeners();
  }

  Future<void> addPlaylist(String name) async {
    final playlist = PlaylistModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      songIds: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _playlists.add(playlist);
    await _storageService.savePlaylists(_playlists);
    notifyListeners();
  }

  Future<void> deletePlaylist(String id) async {
    _playlists.removeWhere((p) => p.id == id);
    await _storageService.savePlaylists(_playlists);
    notifyListeners();
  }

  Future<void> renamePlaylist(String id, String newName) async {
    final index = _playlists.indexWhere((p) => p.id == id);
    if (index == -1) return;

    final playlist = _playlists[index].copyWith(
      name: newName,
      updatedAt: DateTime.now(),
    );

    _playlists[index] = playlist;
    await _storageService.savePlaylists(_playlists);
    notifyListeners();
  }

  Future<void> addSongToPlaylist(String playlistId, String songId) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index == -1) return;

    final playlist = _playlists[index];
    if (!playlist.songIds.contains(songId)) {
      final updated = playlist.copyWith(
        songIds: [...playlist.songIds, songId],
        updatedAt: DateTime.now(),
      );
      _playlists[index] = updated;
      await _storageService.savePlaylists(_playlists);
      notifyListeners();
    }
  }

  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index == -1) return;

    final playlist = _playlists[index];
    final updatedIds = List<String>.from(playlist.songIds)..remove(songId);

    final updated = playlist.copyWith(
      songIds: updatedIds,
      updatedAt: DateTime.now(),
    );

    _playlists[index] = updated;
    await _storageService.savePlaylists(_playlists);
    notifyListeners();
  }
}