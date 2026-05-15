import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:offline_music_player/providers/audio_provider.dart';
import 'package:offline_music_player/providers/playlist_provider.dart';
import 'package:offline_music_player/providers/theme_provider.dart';
import 'package:offline_music_player/screens/main_shell.dart';
import 'package:offline_music_player/services/audio_player_service.dart';
import 'package:offline_music_player/services/storage_service.dart';
import 'package:offline_music_player/utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => AudioPlayerService()),
        Provider(create: (_) => StorageService()),

        ChangeNotifierProxyProvider2<
            AudioPlayerService,
            StorageService,
            AudioProvider>(
          create: (_) => AudioProvider(
            AudioPlayerService(),
            StorageService(),
          ),
          update: (_, audio, storage, __) =>
              AudioProvider(audio, storage),
        ),

        ChangeNotifierProxyProvider<
            StorageService,
            PlaylistProvider>(
          create: (_) => PlaylistProvider(StorageService()),
          update: (_, storage, __) =>
              PlaylistProvider(storage),
        ),

        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeProvider>().themeMode;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Offline Music Player',
      themeMode: themeMode,

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
      ),

      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: AppColors.background,
      ),

      home: const MainShell(),
    );
  }
}
