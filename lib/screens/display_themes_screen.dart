import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/device_state_notifier.dart';

/// Hardware Display Theme Selection Screen
/// 
/// Allows users to customize the visual theme of their CoreTag device display
class DisplayThemesScreen extends ConsumerStatefulWidget {
  const DisplayThemesScreen({super.key});

  @override
  ConsumerState<DisplayThemesScreen> createState() => _DisplayThemesScreenState();
}

class _DisplayThemesScreenState extends ConsumerState<DisplayThemesScreen> {
  String? _selectedTheme;

  final List<DisplayTheme> _themes = [
    DisplayTheme(
      id: 'minimal_dark',
      name: 'Minimal Dark',
      description: 'Clean, minimalist black theme',
      primaryColor: const Color(0xFF000000),
      accentColor: const Color(0xFF6366F1),
      preview: 'assets/themes/minimal_dark.png',
    ),
    DisplayTheme(
      id: 'minimal_light',
      name: 'Minimal Light',
      description: 'Clean, minimalist white theme',
      primaryColor: const Color(0xFFFFFFFF),
      accentColor: const Color(0xFF6366F1),
      preview: 'assets/themes/minimal_light.png',
    ),
    DisplayTheme(
      id: 'neon_cyber',
      name: 'Neon Cyber',
      description: 'Futuristic neon colors',
      primaryColor: const Color(0xFF0A0E27),
      accentColor: const Color(0xFF00FFF0),
      preview: 'assets/themes/neon_cyber.png',
    ),
    DisplayTheme(
      id: 'nature_green',
      name: 'Nature Green',
      description: 'Calm forest greens',
      primaryColor: const Color(0xFF1B4332),
      accentColor: const Color(0xFF52B788),
      preview: 'assets/themes/nature_green.png',
    ),
    DisplayTheme(
      id: 'sunset_warm',
      name: 'Sunset Warm',
      description: 'Warm orange and pink',
      primaryColor: const Color(0xFF2D1B00),
      accentColor: const Color(0xFFFF6B35),
      preview: 'assets/themes/sunset_warm.png',
    ),
    DisplayTheme(
      id: 'ocean_blue',
      name: 'Ocean Blue',
      description: 'Deep ocean blues',
      primaryColor: const Color(0xFF001F3F),
      accentColor: const Color(0xFF3A86FF),
      preview: 'assets/themes/ocean_blue.png',
    ),
    DisplayTheme(
      id: 'purple_dream',
      name: 'Purple Dream',
      description: 'Royal purple gradient',
      primaryColor: const Color(0xFF1A0933),
      accentColor: const Color(0xFF9D4EDD),
      preview: 'assets/themes/purple_dream.png',
    ),
    DisplayTheme(
      id: 'retro_80s',
      name: 'Retro 80s',
      description: 'Classic 80s aesthetic',
      primaryColor: const Color(0xFF2B0B3F),
      accentColor: const Color(0xFFFF00FF),
      preview: 'assets/themes/retro_80s.png',
    ),
  ];

  @override
  void initState() {
    super.initState();
    final deviceState = ref.read(deviceStateNotifierProvider);
    _selectedTheme = deviceState.theme;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Premium Header with back and save buttons (matching watch customization screen)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                    ),
                  ),
                  // Screen title
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.palette, color: Colors.white, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Display Themes',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Info/Help button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () => _showInfoDialog(context),
                      icon: const Icon(Icons.info_outline, color: Color(0xFF6366F1)),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF6366F1).withOpacity(0.05),
                      const Color(0xFFF5F5F5),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    // Subtitle description
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                      child: Text(
                        'Choose a visual style for your CoreTag display',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),

                    // Theme Grid with improved animations
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16),
                        physics: const BouncingScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 0.72,
                        ),
                        itemCount: _themes.length,
                        itemBuilder: (context, index) {
                          final theme = _themes[index];
                          final isSelected = _selectedTheme == theme.id;

                          return TweenAnimationBuilder<double>(
                            duration: Duration(milliseconds: 300 + (index * 50)),
                            tween: Tween(begin: 0.0, end: 1.0),
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: 0.8 + (value * 0.2),
                                child: Opacity(
                                  opacity: value,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedTheme = theme.id;
                                      });
                                      ref.read(deviceStateNotifierProvider.notifier).setTheme(theme.id);
                                      
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Row(
                                            children: [
                                              const Icon(Icons.check_circle, color: Colors.white),
                                              const SizedBox(width: 12),
                                              Text('${theme.name} applied!'),
                                            ],
                                          ),
                                          backgroundColor: const Color(0xFF10B981),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                    child: _buildThemeCard(theme, isSelected, isDark),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    )
                  : null,
              color: isSelected
                  ? null
                  : (isDark ? Colors.white.withOpacity(0.05) : Colors.white),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? Colors.transparent
                    : (isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade300),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white70 : Colors.grey.shade700),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Color(0xFF6366F1)),
            SizedBox(width: 12),
            Text('About Display Themes'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Display themes customize how information appears on your CoreTag device screen.\n\n'
              '• Choose from 8 premium themes\n'
              '• Themes sync instantly\n'
              '• Dark themes save battery\n'
              '• Preview before applying',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeCard(DisplayTheme theme, bool isSelected, bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? const Color(0xFF6366F1) : Colors.transparent,
          width: isSelected ? 3 : 0,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? const Color(0xFF6366F1).withOpacity(0.4)
                : Colors.black.withOpacity(0.08),
            blurRadius: isSelected ? 20 : 10,
            offset: Offset(0, isSelected ? 8 : 4),
            spreadRadius: isSelected ? 2 : 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Theme Preview
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Color preview with device mockup
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [theme.primaryColor, theme.accentColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Decorative circles
                        Positioned(
                          top: -20,
                          right: -20,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -30,
                          left: -30,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.05),
                            ),
                          ),
                        ),
                        // Device icon
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  Icons.watch,
                                  size: 40,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Mini preview bars
                              Container(
                                width: 50,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                width: 70,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Theme info
                Expanded(
                  flex: 2,
                  child: Container(
                    color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          theme.name,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF1E293B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          theme.description,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.white60 : Colors.grey.shade600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        // Color swatches
                        Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: theme.primaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: theme.accentColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Selected overlay with checkmark
            if (isSelected)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: const Color(0xFF6366F1).withOpacity(0.1),
                  ),
                ),
              ),

            // Selected Badge
            if (isSelected)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withOpacity(0.5),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class DisplayTheme {
  final String id;
  final String name;
  final String description;
  final Color primaryColor;
  final Color accentColor;
  final String preview;

  DisplayTheme({
    required this.id,
    required this.name,
    required this.description,
    required this.primaryColor,
    required this.accentColor,
    required this.preview,
  });
}
