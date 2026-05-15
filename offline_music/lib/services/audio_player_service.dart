import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:offline_music_player/models/playback_state_model.dart';
import 'package:rxdart/rxdart.dart';

class AudioPlayerService {
  final AudioPlayer _audioPlayer;

  AudioPlayerService({AudioPlayer? audioPlayer})
    : _audioPlayer = audioPlayer ?? AudioPlayer();

  StreamSubscription? _noisySub;

  Future<void> init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    _noisySub = session.becomingNoisyEventStream.listen((_) {
      pause();
    });
  }

  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;
  Stream<bool> get playingStream => _audioPlayer.playingStream;
  Stream<int?> get currentIndexStream => _audioPlayer.currentIndexStream;
  Duration get currentPosition => _audioPlayer.position;
  Duration? get currentDuration => _audioPlayer.duration;
  bool get isPlaying => _audioPlayer.playing;
  int? get currentIndex => _audioPlayer.currentIndex;
  bool get hasNext => _audioPlayer.hasNext;
  bool get hasPrevious => _audioPlayer.hasPrevious;

  Stream<PlaybackState> get playbackStateStream {
    return Rx.combineLatest3<Duration, Duration?, bool, PlaybackState>(
      positionStream,
      durationStream,
      playingStream,
      (position, duration, isPlaying) {
        return PlaybackState(
          position: position,
          duration: duration ?? Duration.zero,
          isPlaying: isPlaying,
        );
      },
    );
  }

  AudioSource _buildSource(String path) {
    if (path.startsWith('assets/')) {
      return AudioSource.asset(path);
    }
    return AudioSource.file(path);
  }

  Future<void> setPlaylist(
    List<String> paths, {
    required int initialIndex,
    required Duration initialPosition,
  }) async {
    final sources = paths.map(_buildSource).toList();
    final playlist = ConcatenatingAudioSource(children: sources);

    await _audioPlayer.setAudioSource(
      playlist,
      initialIndex: initialIndex,
      initialPosition: initialPosition,
      preload: true,
    );
  }

  Future<void> play() async => _audioPlayer.play();

  Future<void> pause() async => _audioPlayer.pause();

  Future<void> stop() async => _audioPlayer.stop();

  Future<void> seek(Duration position) async => _audioPlayer.seek(position);

  Future<void> seekToIndex(
    int index, {
    Duration position = Duration.zero,
  }) async {
    await _audioPlayer.seek(position, index: index);
  }

  Future<void> seekToNext() async {
    if (hasNext) {
      await _audioPlayer.seekToNext();
    }
  }

  Future<void> seekToPrevious() async {
    if (hasPrevious) {
      await _audioPlayer.seekToPrevious();
    }
  }

  Future<void> setVolume(double volume) async => _audioPlayer.setVolume(volume);

  Future<void> setSpeed(double speed) async => _audioPlayer.setSpeed(speed);

  Future<void> setLoopMode(LoopMode loopMode) async =>
      _audioPlayer.setLoopMode(loopMode);

  Future<void> setShuffleModeEnabled(bool enabled) async {
    await _audioPlayer.setShuffleModeEnabled(enabled);
    if (enabled) {
      await _audioPlayer.shuffle();
    }
  }

  Future<void> loadAudio(String path) async {
    await setPlaylist([path], initialIndex: 0, initialPosition: Duration.zero);
  }

  void dispose() {
    _noisySub?.cancel();
    _audioPlayer.dispose();
  }
}