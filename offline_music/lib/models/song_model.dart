import 'dart:typed_data';

class SongModel {
  final String id;
  final String title;
  final String artist;
  final String? album;
  final String filePath;
  final Duration? duration;
  final int? albumId;
  final int? dateAdded;
  final int? fileSize;
final Uint8List? artwork;
  SongModel({
    required this.id,
    required this.title,
    required this.artist,
    this.album,
    required this.filePath,
    this.duration,
    this.albumId,
    this.dateAdded,
    this.fileSize,
    this.artwork,
  });

  int get intId => int.tryParse(id) ?? 0;

  factory SongModel.fromJson(Map<String, dynamic> json) {
    return SongModel(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      album: json['album'] as String?,
      filePath: json['filePath'] as String,
      duration: json['duration'] != null
          ? Duration(milliseconds: json['duration'] as int)
          : null,
      albumId: json['albumId'] as int?,
      dateAdded: json['dateAdded'] as int?,
      fileSize: json['fileSize'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'filePath': filePath,
      'duration': duration?.inMilliseconds,
      'albumId': albumId,
      'dateAdded': dateAdded,
      'fileSize': fileSize,
    };
  }

  factory SongModel.fromAudioQuery(dynamic audioModel) {
    return SongModel(
      id: audioModel.id.toString(),
      title: audioModel.title ?? 'Unknown Title',
      artist: (audioModel.artist == null || audioModel.artist == '<unknown>')
          ? 'Unknown Artist'
          : audioModel.artist,
      album: audioModel.album,
      filePath: audioModel.data,
      duration: audioModel.duration != null
          ? Duration(milliseconds: audioModel.duration)
          : null,
      albumId: audioModel.albumId,
      dateAdded: audioModel.dateAdded,
      fileSize: audioModel.size,
    );
  }
}