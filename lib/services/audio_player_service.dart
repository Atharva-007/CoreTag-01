import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';

/// CoreTag Audio Player Service
/// 
/// Manages audio playback with background support using just_audio and audio_service.
/// Features:
/// - Background audio playback
/// - Play/pause/stop controls
/// - Volume control
/// - Position tracking
/// - Playlist support
/// - Notification controls
class CoreTagAudioPlayerService {
  static final CoreTagAudio PlayerService _instance = CoreTagAudioPlayerService._internal();
  factory CoreTagAudioPlayerService() => _instance;
  CoreTagAudioPlayerService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  AudioHandler? _audioHandler;
  
  bool _isInitialized = false;
  StreamSubscription? _playbackStateSubscription;
  StreamSubscription? _positionSubscription;

  // Streams for UI updates
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;
  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;
  Stream<double> get volumeStream => _audioPlayer.volumeStream;
  
  // Getters
  bool get isPlaying => _audioPlayer.playing;
  Duration get position => _audioPlayer.position;
  Duration? get duration => _audioPlayer.duration;
  double get volume => _audioPlayer.volume;

  /// Initialize the audio service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize audio session
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());

      // Initialize audio handler for background playback
      _audioHandler = await AudioService.init(
        builder: () => CoreTagAudioHandler(_audioPlayer),
        config: const AudioServiceConfig(
          androidNotificationChannelId: 'com.example.coretag.audio',
          androidNotificationChannelName: 'CoreTag Audio',
          androidNotificationOngoing: true,
          androidStopForegroundOnPause: true,
        ),
      );

      _isInitialized = true;
      debugPrint('CoreTag Audio Service initialized');
    } catch (e) {
      debugPrint('Error initializing audio service: $e');
    }
  }

  /// Play audio from URL
  Future<void> playFromUrl(String url, {String? title, String? artist}) async {
    try {
      await initialize();
      
      await _audioPlayer.setUrl(url);
      await _audioPlayer.play();

      // Update media item for notification
      _audioHandler?.mediaItem.add(MediaItem(
        id: url,
        album: "CoreTag",
        title: title ?? 'Unknown Track',
        artist: artist ?? 'Unknown Artist',
      ));

      debugPrint('Playing: $title by $artist');
    } catch (e) {
      debugPrint('Error playing audio: $e');
      rethrow;
    }
  }

  /// Play audio from asset
  Future<void> playFromAsset(String assetPath, {String? title, String? artist}) async {
    try {
      await initialize();
      
      await _audioPlayer.setAsset(assetPath);
      await _audioPlayer.play();

      _audioHandler?.mediaItem.add(MediaItem(
        id: assetPath,
        album: "CoreTag",
        title: title ?? 'Unknown Track',
        artist: artist ?? 'Unknown Artist',
      ));

      debugPrint('Playing asset: $assetPath');
    } catch (e) {
      debugPrint('Error playing asset: $e');
      rethrow;
    }
  }

  /// Play/pause toggle
  Future<void> playPause() async {
    if (_audioPlayer.playing) {
      await pause();
    } else {
      await play();
    }
  }

  /// Play
  Future<void> play() async {
    await _audioPlayer.play();
    debugPrint('Audio playing');
  }

  /// Pause
  Future<void> pause() async {
    await _audioPlayer.pause();
    debugPrint('Audio paused');
  }

  /// Stop
  Future<void> stop() async {
    await _audioPlayer.stop();
    debugPrint('Audio stopped');
  }

  /// Seek to position
  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
    debugPrint('Seeking to: ${position.inSeconds}s');
  }

  /// Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    await _audioPlayer.setVolume(volume.clamp(0.0, 1.0));
    debugPrint('Volume set to: $volume');
  }

  /// Set playback speed
  Future<void> setSpeed(double speed) async {
    await _audioPlayer.setSpeed(speed);
    debugPrint('Speed set to: ${speed}x');
  }

  /// Set loop mode
  Future<void> setLoopMode(LoopMode loopMode) async {
    await _audioPlayer.setLoopMode(loopMode);
    debugPrint('Loop mode: $loopMode');
  }

  /// Dispose audio player
  Future<void> dispose() async {
    await _playbackStateSubscription?.cancel();
    await _positionSubscription?.cancel();
    await _audioPlayer.dispose();
    _isInitialized = false;
    debugPrint('Audio service disposed');
  }
}

/// Audio Handler for background playback
class CoreTagAudioHandler extends BaseAudioHandler {
  final AudioPlayer _audioPlayer;

  CoreTagAudioHandler(this._audioPlayer) {
    // Listen to playback events
    _audioPlayer.playbackEventStream.listen((event) {
      playbackState.add(playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          if (_audioPlayer.playing) MediaControl.pause else MediaControl.play,
          MediaControl.stop,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1, 3],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_audioPlayer.processingState]!,
        playing: _audioPlayer.playing,
        updatePosition: _audioPlayer.position,
        bufferedPosition: _audioPlayer.bufferedPosition,
        speed: _audioPlayer.speed,
        queueIndex: 0,
      ));
    });
  }

  @override
  Future<void> play() => _audioPlayer.play();

  @override
  Future<void> pause() => _audioPlayer.pause();

  @override
  Future<void> stop() => _audioPlayer.stop();

  @override
  Future<void> seek(Duration position) => _audioPlayer.seek(position);

  @override
  Future<void> skipToNext() async {
    // Implement skip to next track
    debugPrint('Skip to next (not implemented)');
  }

  @override
  Future<void> skipToPrevious() async {
    // Implement skip to previous track
    debugPrint('Skip to previous (not implemented)');
  }
}
