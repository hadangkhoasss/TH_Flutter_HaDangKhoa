import 'package:flutter/material.dart';
import 'package:offline_music_player/models/song_model.dart';

class AlbumArt extends StatelessWidget {
  final SongModel? song;
  final double size;

  const AlbumArt({
    super.key,
    required this.song,
    this.size = 300,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12), // bo góc kiểu Spotify
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _buildArtwork(),
      ),
    );
  }

  // Hiển thị ảnh album (hiện dùng ảnh mặc định cho ổn định)
  Widget _buildArtwork() {
    return Image.asset(
      'assets/images/default_album_art.jpg',
      fit: BoxFit.cover,
    );
  }
}
