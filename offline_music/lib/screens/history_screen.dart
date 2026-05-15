import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:offline_music_player/providers/audio_provider.dart';
import 'package:offline_music_player/utils/constants.dart';
import 'package:offline_music_player/widgets/song_tile.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final audioProvider = context.watch<AudioProvider>();
    final songs = audioProvider.recentlyPlayedSongs;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Recently Played'),
      ),
      body: songs.isEmpty
          ? const Center(
              child: Text(
                'Chưa có lịch sử phát',
                style: TextStyle(color: AppColors.subtitle),
              ),
            )
          : ListView.builder(
              itemCount: songs.length,
              itemBuilder: (_, i) => SongTile(
                song: songs[i],
                onTap: () {
                  audioProvider.setPlaylist(songs, i);
                }, dense: true,
              ),
            ),
    );
  }
}
