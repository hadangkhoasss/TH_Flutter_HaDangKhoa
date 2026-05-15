import 'package:flutter/material.dart';
import 'package:offline_music_player/providers/audio_provider.dart';
import 'package:offline_music_player/providers/theme_provider.dart';
import 'package:offline_music_player/utils/constants.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final audioProvider = context.watch<AudioProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Cài đặt'),
      ),
      body: ListView(
        children: [
          // ===== GIAO DIỆN =====
          SwitchListTile(
            title: const Text(
              'Chế độ tối',
              style: TextStyle(color: AppColors.text),
            ),
            subtitle: const Text(
              'Giao diện tối kiểu Spotify',
              style: TextStyle(color: AppColors.subtitle),
            ),
            value: themeProvider.isDarkMode,
            onChanged: (_) => themeProvider.toggleTheme(),
          ),

          const Divider(),

          // ===== ÂM THANH =====
          ListTile(
            title: const Text(
              'Âm lượng',
              style: TextStyle(color: AppColors.text),
            ),
            subtitle: Slider(
              value: audioProvider.volume,
              min: 0.0,
              max: 1.0,
              onChanged: audioProvider.setVolume,
            ),
          ),

          ListTile(
            title: const Text(
              'Tốc độ phát',
              style: TextStyle(color: AppColors.text),
            ),
            subtitle: Wrap(
              spacing: 8,
              children: [0.75, 1.0, 1.25, 1.5, 2.0].map((s) {
                final selected = audioProvider.speed == s;
                return ChoiceChip(
                  label: Text('${s}x'),
                  selected: selected,
                  selectedColor: AppColors.primary,
                  onSelected: (_) => audioProvider.setSpeed(s),
                );
              }).toList(),
            ),
          ),

          const Divider(),

          // ===== DỮ LIỆU PHÁT GẦN ĐÂY =====
          ListTile(
            title: const Text(
              'Xóa danh sách phát gần đây',
              style: TextStyle(color: AppColors.text),
            ),
            subtitle: const Text(
              'Xóa lịch sử các bài đã nghe',
              style: TextStyle(color: AppColors.subtitle),
            ),
            trailing: const Icon(
              Icons.delete_outline,
              color: AppColors.subtitle,
            ),
            onTap: () async {
              await context
                  .read<AudioProvider>()
                  .clearRecentlyPlayed();

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('Đã xóa danh sách phát gần đây'),
                  ),
                );
              }
            },
          ),

          const Divider(),

          // ===== GIỚI THIỆU =====
          const ListTile(
            title: Text(
              'Giới thiệu',
              style: TextStyle(color: AppColors.text),
            ),
            subtitle: Text(
              'Trình phát nhạc offline đơn giản theo phong cách Spotify',
              style: TextStyle(color: AppColors.subtitle),
            ),
          ),
        ],
      ),
    );
  }
}