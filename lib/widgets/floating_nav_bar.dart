import 'package:flutter/material.dart';

/// Modern Floating Bottom Navigation Bar Widget
/// 
/// A glassmorphic floating navigation bar with three primary actions:
/// 1. Find My Device - Locate connected CoreTag device
/// 2. Add Device - Connect new devices (center FAB)
/// 3. Display Themes - Hardware display theme selection
class BottomNavBar extends StatelessWidget {
  final VoidCallback onFindDevice;
  final VoidCallback onAddDevice;
  final VoidCallback onDisplayThemes;
  final int currentIndex;

  const BottomNavBar({
    super.key,
    required this.onFindDevice,
    required this.onAddDevice,
    required this.onDisplayThemes,
    this.currentIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
      child: Container(
        height: 70,
        constraints: BoxConstraints(maxWidth: screenWidth - 32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [
                    const Color(0xFF1E1E1E).withOpacity(0.95),
                    const Color(0xFF2A2A2A).withOpacity(0.95),
                  ]
                : [
                    Colors.white.withOpacity(0.95),
                    Colors.white.withOpacity(0.90),
                  ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.05),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.5)
                  : Colors.black.withOpacity(0.15),
              blurRadius: 30,
              spreadRadius: 0,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: const Color(0xFF6366F1).withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: -5,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Bottom Navigation Items
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Find Device Button
                _buildFloatingNavItem(
                  icon: Icons.radar,
                  label: 'Find',
                  isActive: currentIndex == 0,
                  onTap: onFindDevice,
                  isDark: isDark,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                  ),
                ),
              
                // Spacer for center FAB
                const SizedBox(width: 80),
              
                // Display Themes Button
                _buildFloatingNavItem(
                  icon: Icons.palette_rounded,
                  label: 'Themes',
                  isActive: currentIndex == 2,
                  onTap: onDisplayThemes,
                  isDark: isDark,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                  ),
                ),
              ],
            ),
          
            // Center Floating Action Button
            Positioned(
              left: screenWidth / 2 - 36 - 16,
              top: -25,
              child: GestureDetector(
                onTap: onAddDevice,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withOpacity(0.5),
                        blurRadius: 25,
                        spreadRadius: 0,
                        offset: const Offset(0, 10),
                      ),
                      BoxShadow(
                        color: const Color(0xFF8B5CF6).withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 5,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    required bool isDark,
    required Gradient gradient,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Floating Icon Container
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: isActive ? 50 : 44,
                height: isActive ? 50 : 44,
                decoration: BoxDecoration(
                  gradient: isActive
                      ? gradient
                      : LinearGradient(
                          colors: [
                            (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                            (isDark ? Colors.grey.shade800 : Colors.grey.shade400),
                          ],
                        ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: gradient.colors.first.withOpacity(0.4),
                            blurRadius: 16,
                            spreadRadius: 0,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: isActive ? 26 : 22,
                ),
              ),
              const SizedBox(height: 4),
              // Label
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: isActive ? 12 : 10,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive
                      ? (isDark ? Colors.white : const Color(0xFF1E293B))
                      : (isDark ? Colors.grey.shade500 : Colors.grey.shade600),
                  letterSpacing: 0.3,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
