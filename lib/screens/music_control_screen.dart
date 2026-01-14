import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/device_state.dart';
import '../state/device_state_notifier.dart';
import '../services/audio_player_service.dart';
import 'dart:io';

class MusicControlScreen extends ConsumerStatefulWidget {
  const MusicControlScreen({super.key});

  @override
  ConsumerState<MusicControlScreen> createState() => _MusicControlScreenState();
}

class _MusicControlScreenState extends ConsumerState<MusicControlScreen> 
    with SingleTickerProviderStateMixin {
  late AnimationController _albumArtController;
  
  @override
  void initState() {
    super.initState();
    _albumArtController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _albumArtController.forward();
  }

  @override
  void dispose() {
    _albumArtController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceState = ref.watch(deviceStateNotifierProvider);
    final notifier = ref.read(deviceStateNotifierProvider.notifier);
    final musicState = deviceState.music;
    final isDark = deviceState.theme == 'dark';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        elevation: 0,
        title: Text(
          'Music Control',
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        ),
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // Album Art
            _buildAlbumArt(musicState, isDark),
            
            const SizedBox(height: 40),
            
            // Track Info
            _buildTrackInfo(musicState, isDark),
            
            const SizedBox(height: 40),
            
            // Playback Controls
            _buildPlaybackControls(musicState, notifier, isDark),
            
            const SizedBox(height: 50),
            
            // Additional Controls
            _buildAdditionalControls(isDark),
            
            const SizedBox(height: 30),
            
            // Music Widget Preview
            _buildMusicWidgetPreview(deviceState, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildAlbumArt(MusicState musicState, bool isDark) {
    return Hero(
      tag: 'album_art',
      child: Container(
        width: 280,
        height: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.2),
              blurRadius: 30,
              spreadRadius: 5,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: musicState.albumArt != null && File(musicState.albumArt!).existsSync()
              ? FadeTransition(
                  opacity: _albumArtController,
                  child: Image.file(
                    File(musicState.albumArt!),
                    fit: BoxFit.cover,
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF6366F1),
                        const Color(0xFF8B5CF6),
                        const Color(0xFFA855F7),
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.music_note_rounded,
                    size: 120,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildTrackInfo(MusicState musicState, bool isDark) {
    return Column(
      children: [
        Text(
          musicState.trackTitle,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 12),
        Text(
          musicState.artist,
          style: TextStyle(
            fontSize: 18,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildPlaybackControls(MusicState musicState, DeviceStateNotifier notifier, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Previous Button
        _buildControlButton(
          icon: Icons.skip_previous_rounded,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Previous track - controlled by music app')),
            );
          },
          isDark: isDark,
        ),
        
        const SizedBox(width: 20),
        
        // Play/Pause Button (Larger)
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                notifier.updateMusicState(isPlaying: !musicState.isPlaying);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(musicState.isPlaying ? 'Paused' : 'Playing'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(40),
              child: Icon(
                musicState.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                size: 44,
                color: Colors.white,
              ),
            ),
          ),
        ),
        
        const SizedBox(width: 20),
        
        // Next Button
        _buildControlButton(
          icon: Icons.skip_next_rounded,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Next track - controlled by music app')),
            );
          },
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required bool isDark,
  }) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(30),
          child: Icon(
            icon,
            size: 30,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildAdditionalControls(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildSmallButton(Icons.shuffle_rounded, 'Shuffle', isDark),
        _buildSmallButton(Icons.repeat_rounded, 'Repeat', isDark),
        _buildSmallButton(Icons.favorite_border_rounded, 'Like', isDark),
        _buildSmallButton(Icons.playlist_play_rounded, 'Playlist', isDark),
      ],
    );
  }

  Widget _buildSmallButton(IconData icon, String label, bool isDark) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, size: 24),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$label - controlled by music app')),
            );
          },
          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildMusicWidgetPreview(DeviceState deviceState, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF2A2A2A), const Color(0xFF1A1A1A)]
              : [Colors.white, Colors.grey.shade50],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 20,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
              const SizedBox(width: 8),
              Text(
                'Device Widget Preview',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A1A) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    ),
                  ),
                  child: const Icon(Icons.music_note, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        deviceState.music.trackTitle,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        deviceState.music.artist,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  deviceState.music.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'This is how music will appear on your CoreTag device',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
