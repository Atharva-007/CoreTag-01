# Mode-Based Customization Architecture

**Implementation Date:** January 7, 2026  
**Feature:** Dynamic Device Mode Customization Screens  
**Status:** ✅ Fully Implemented

---

## 🎯 Overview

The CoreTag app now supports **three distinct device modes**, each with its own dedicated customization screen:

1. **Watch Mode** - Full smartwatch features
2. **Carry Mode** - Optimized for bag/pocket use
3. **Tag Mode** - Minimal item tracking

---

## 📐 Navigation Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                      DASHBOARD SCREEN                        │
│                                                              │
│  ┌────────────────────────────────────────────────────┐    │
│  │         Device Preview (Mode-Aware)                 │    │
│  │  • Shows widgets based on current mode              │    │
│  │  • Real-time state synchronization                  │    │
│  └────────────────────────────────────────────────────┘    │
│                                                              │
│  ┌────────────────────────────────────────────────────┐    │
│  │         Edit Widgets Button                         │    │
│  │  onClick → Check deviceState.deviceMode             │    │
│  └────────────────────────────────────────────────────┘    │
│                                                              │
│  ┌────────────────────────────────────────────────────┐    │
│  │         Mode Selection (Theme Section)              │    │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐         │    │
│  │  │   Tag    │  │  Carry   │  │  Watch   │         │    │
│  │  └──────────┘  └──────────┘  └──────────┘         │    │
│  │      ↓              ↓              ↓               │    │
│  │  Updates deviceState.deviceMode                     │    │
│  └────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
                           ↓
        ┌──────────────────┴──────────────────┐
        │   Mode-Based Navigation Logic        │
        │   (dashboard_screen.dart L236-290)   │
        └──────────────────┬──────────────────┘
                           ↓
        ┌──────────────────┴──────────────────┐
        │                                      │
        ↓                  ↓                   ↓
┌───────────────┐  ┌───────────────┐  ┌───────────────┐
│  WATCH MODE   │  │  CARRY MODE   │  │   TAG MODE    │
│ Customization │  │ Customization │  │ Customization │
│               │  │               │  │               │
│ ✓ Full Widget │  │ 🚧 Placeholder │  │ 🚧 Placeholder │
│   Editor      │  │   Music Focus │  │   Tracking    │
│ ✓ Background  │  │   Nav Alerts  │  │   Location    │
│ ✓ Time/Weather│  │   Power Save  │  │   Last Seen   │
│ ✓ Music/Nav   │  │               │  │               │
│ ✓ Photo       │  │               │  │               │
└───────┬───────┘  └───────┬───────┘  └───────┬───────┘
        │                  │                   │
        └──────────────────┴───────────────────┘
                           ↓
                ┌──────────────────────┐
                │  Save Changes (✓)    │
                │  Returns DeviceState │
                └──────────┬───────────┘
                           ↓
        ┌──────────────────────────────────────┐
        │  deviceStateNotifier.updateDeviceState│
        │  • Persists changes globally          │
        │  • Updates dashboard preview          │
        │  • Syncs with Riverpod provider       │
        └──────────────────────────────────────┘
```

---

## 🗂️ File Structure

```
lib/
├── screens/
│   ├── dashboard_screen.dart              # Main entry, mode routing
│   ├── watch_customization_screen.dart    # ✅ Full implementation
│   ├── carry_customization_screen.dart    # 🚧 Placeholder UI
│   ├── tag_customization_screen.dart      # 🚧 Placeholder UI
│   └── widget_customization_screen.dart   # ⚠️ DEPRECATED (redirects)
├── models/
│   └── device_state.dart                  # Contains deviceMode field
├── state/
│   └── device_state_notifier.dart         # Global state management
└── widgets/
    ├── device_preview.dart                # Mode-aware preview
    └── new_customization_panel.dart       # Widget options
```

---

## 🔧 Implementation Details

### 1. Dashboard Navigation Logic

**File:** `lib/screens/dashboard_screen.dart` (Lines 236-290)

```dart
Widget _buildEditDeviceWidgetButton(DeviceState deviceState) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: () async {
        // ============================================================
        // MODE-BASED NAVIGATION LOGIC
        // ============================================================
        Widget customizationScreen;
        
        switch (deviceState.deviceMode) {
          case 'watch':
            customizationScreen = WatchCustomizationScreen(
              allWidgetCards: allWidgetCards,
              initialDeviceState: deviceState,
            );
            break;
          
          case 'carry':
            customizationScreen = CarryCustomizationScreen(
              allWidgetCards: allWidgetCards,
              initialDeviceState: deviceState,
            );
            break;
          
          case 'tag':
            customizationScreen = TagCustomizationScreen(
              allWidgetCards: allWidgetCards,
              initialDeviceState: deviceState,
            );
            break;
          
          default:
            // Fallback to watch mode
            customizationScreen = WatchCustomizationScreen(
              allWidgetCards: allWidgetCards,
              initialDeviceState: deviceState,
            );
        }

        // Navigate and await result
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => customizationScreen),
        );

        // Update global state if changes were saved
        if (result != null && result is DeviceState) {
          ref.read(deviceStateNotifierProvider.notifier)
             .updateDeviceState(result);
        }
      },
      // ... UI code
    ),
  );
}
```

**Key Points:**
- ✅ Detects current mode from `deviceState.deviceMode`
- ✅ Routes to mode-specific screen
- ✅ Handles state updates on return
- ✅ Fallback to Watch mode for safety

---

### 2. Watch Customization Screen

**File:** `lib/screens/watch_customization_screen.dart`

**Status:** ✅ **Fully Functional**

**Features:**
```dart
✓ Real-time device preview
✓ Widget selection (Time, Weather, Music, Nav, Photo)
✓ Background image picker with cropping
✓ Category-based widget management
✓ State persistence on save
✓ Mode indicator badge
```

**Widget Selection Logic:**
```dart
void _onWidgetSelected(String? newWidgetId) {
  if (newWidgetId == null) return;
  
  // Extract category (e.g., 'time', 'music')
  final categoryPrefix = newWidgetId.split('-').first;
  
  // Remove existing widgets from same category
  final newWidgets = deviceState.widgets
      .where((w) => !w.id.startsWith(categoryPrefix))
      .toList();
  
  // Add new widget
  newWidgets.add(CustomWidgetState(id: newWidgetId));
  
  setState(() {
    _selectedWidgetId = newWidgetId;
    deviceState = deviceState.copyWith(widgets: newWidgets);
  });
}
```

**Background Image Handling:**
```dart
Future<void> _pickCustomPhoto() async {
  final picker = ImagePicker();
  final image = await picker.pickImage(source: ImageSource.gallery);
  
  if (image != null) {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: image.path,
      // Aspect ratio presets: square, 3x2, 4x3, 16x9, original
    );
    
    if (croppedFile != null) {
      setState(() {
        deviceState = deviceState.copyWith(
          backgroundImage: croppedFile.path
        );
      });
    }
  }
}
```

---

### 3. Carry Customization Screen

**File:** `lib/screens/carry_customization_screen.dart`

**Status:** 🚧 **Placeholder Implementation**

**Planned Features:**
```
🎵 Music Controls (Primary)
   - Play/Pause/Skip
   - Volume control
   - Track info display

🧭 Navigation Alerts
   - Turn-by-turn notifications
   - Distance to destination
   - ETA updates

🔔 Smart Notifications
   - Priority filtering
   - Quick actions
   - Minimal distraction

🔋 Power Optimization
   - Reduced refresh rate
   - Essential widgets only
   - Battery saver mode
```

**Current UI:**
- Mode badge (pink gradient)
- Feature list placeholder
- Save/Back navigation
- "Coming Soon" message

**Color Scheme:**
```dart
Gradient: #EC4899 → #DB2777 (Pink/Magenta)
Icon: Icons.backpack
```

---

### 4. Tag Customization Screen

**File:** `lib/screens/tag_customization_screen.dart`

**Status:** 🚧 **Placeholder Implementation**

**Planned Features:**
```
📍 Location Tracking
   - Current location
   - Location history
   - Geofencing alerts

⏰ Last Seen Timestamp
   - When last active
   - Movement detection
   - Stationary alerts

🔋 Battery Status
   - Minimal power draw
   - Low battery warnings
   - Sleep mode optimization

🔔 Find My Device
   - Ping/Beep function
   - LED flash
   - Remote alerts
```

**Current UI:**
- Mode badge (orange gradient)
- Feature list placeholder
- Save/Back navigation
- "Coming Soon" message

**Color Scheme:**
```dart
Gradient: #F59E0B → #EF4444 (Orange/Red)
Icon: Icons.label
```

---

## 🔄 State Management Flow

### Mode Change Sequence

```
1. User taps mode button (Tag/Carry/Watch)
   ↓
2. deviceStateNotifier.setDeviceMode(mode)
   ↓
3. Riverpod updates global state
   ↓
4. Dashboard rebuilds with new mode
   ↓
5. Device preview updates (if widgets change)
   ↓
6. Edit button now routes to correct screen
```

### Customization Save Sequence

```
1. User modifies widgets/settings
   ↓
2. Local state updates in customization screen
   ↓
3. Device preview updates in real-time
   ↓
4. User taps Save (✓ button)
   ↓
5. Navigator.pop(context, deviceState)
   ↓
6. Dashboard receives DeviceState result
   ↓
7. deviceStateNotifier.updateDeviceState(result)
   ↓
8. Global state persisted
   ↓
9. All listeners rebuild with new state
```

---

## 📊 State Model

**File:** `lib/models/device_state.dart`

```dart
class DeviceState {
  final bool isConnected;
  final int battery;
  final String theme;              // 'light' | 'dark'
  final String deviceMode;         // 'tag' | 'carry' | 'watch' ⭐
  final List<CustomWidgetState> widgets;
  final MusicState music;
  final NavigationState navigation;
  final WeatherState weather;
  final AODState aod;
  final String? backgroundImage;
  final String customName;

  DeviceState copyWith({
    String? deviceMode,  // ⭐ Mode can be updated
    // ... other fields
  });
}
```

**Mode State Management:**

```dart
// lib/state/device_state_notifier.dart

class DeviceStateNotifier extends StateNotifier<DeviceState> {
  
  /// Updates the device mode (tag, carry, or watch)
  void setDeviceMode(String mode) {
    state = state.copyWith(deviceMode: mode);
  }
  
  /// Updates entire device state (from customization screens)
  void updateDeviceState(DeviceState newState) {
    state = newState;
  }
}
```

---

## 🎨 UI Consistency

### Mode Badges

Each customization screen displays a mode indicator badge in the header:

| Mode   | Icon              | Gradient           | Position     |
|--------|-------------------|--------------------|--------------|
| Watch  | `Icons.watch`     | Purple (#6366F1)   | Center       |
| Carry  | `Icons.backpack`  | Pink (#EC4899)     | Center       |
| Tag    | `Icons.label`     | Orange (#F59E0B)   | Center       |

**Implementation:**
```dart
Container(
  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  decoration: BoxDecoration(
    gradient: LinearGradient(colors: [color1, color2]),
    borderRadius: BorderRadius.circular(20),
  ),
  child: Row(
    children: [
      Icon(modeIcon, color: Colors.white, size: 16),
      SizedBox(width: 6),
      Text('${modeName} Mode', style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      )),
    ],
  ),
)
```

### Header Structure

All screens share consistent header layout:

```
┌─────────────────────────────────────────────┐
│  [← Back]    [Mode Badge]    [✓ Save]      │
└─────────────────────────────────────────────┘
```

- **Back Button:** Circular, white, shadow
- **Save Button:** Circular, white, colored icon
- **Badge:** Centered, gradient, rounded

---

## 🧪 Testing Scenarios

### Test Case 1: Mode Switching
```
1. Open dashboard
2. Select "Carry" mode
3. Tap "Edit Widgets"
4. EXPECT: CarryCustomizationScreen opens
5. VERIFY: Pink badge shows "Carry Mode"
```

### Test Case 2: State Persistence
```
1. Open dashboard in Watch mode
2. Tap "Edit Widgets"
3. Change background image
4. Add music widget
5. Tap Save
6. EXPECT: Dashboard preview updates
7. Switch to Carry mode
8. Switch back to Watch mode
9. VERIFY: Changes persist
```

### Test Case 3: Fallback Behavior
```
1. Manually set deviceMode to invalid value
2. Tap "Edit Widgets"
3. EXPECT: WatchCustomizationScreen opens (default)
```

---

## 🚀 Future Enhancements

### Carry Mode Implementation
```dart
// lib/screens/carry_customization_screen.dart

class _CarryCustomizationScreenState extends State<CarryCustomizationScreen> {
  // TODO: Add music control panel
  Widget _buildMusicPanel() { }
  
  // TODO: Add navigation compact view
  Widget _buildNavigationPanel() { }
  
  // TODO: Add notification filters
  Widget _buildNotificationSettings() { }
  
  // TODO: Add power optimization toggles
  Widget _buildPowerSettings() { }
}
```

### Tag Mode Implementation
```dart
// lib/screens/tag_customization_screen.dart

class _TagCustomizationScreenState extends State<TagCustomizationScreen> {
  // TODO: Add location tracking view
  Widget _buildLocationTracker() { }
  
  // TODO: Add last seen timestamp
  Widget _buildLastSeenDisplay() { }
  
  // TODO: Add find device button
  Widget _buildFindDeviceButton() { }
  
  // TODO: Add battery status indicator
  Widget _buildBatteryStatus() { }
}
```

### Mode-Specific Widget Filtering
```dart
// Filter available widgets based on mode
List<WidgetCard> getAvailableWidgets(String mode) {
  switch (mode) {
    case 'watch':
      return allWidgetCards; // All widgets
    case 'carry':
      return allWidgetCards.where((w) => 
        w.id.startsWith('music') || 
        w.id.startsWith('nav')
      ).toList();
    case 'tag':
      return []; // No customizable widgets
    default:
      return allWidgetCards;
  }
}
```

---

## 📝 Code Comments

All navigation and mode logic is extensively commented:

**Dashboard (Lines 236-290):**
```dart
// ============================================================
// MODE-BASED NAVIGATION LOGIC
// ============================================================
// Routes to different customization screens based on device mode:
// - 'watch' → WatchCustomizationScreen (full customization)
// - 'carry' → CarryCustomizationScreen (music/nav focused)
// - 'tag'   → TagCustomizationScreen (minimal tracking)
// ============================================================
```

**Watch Screen (Lines 1-22):**
```dart
/// Watch Mode Customization Screen
/// 
/// This screen handles customization specifically for Watch mode.
/// Features:
/// - Full widget customization (time, weather, music, navigation, photo)
/// - Background image selection
/// - Real-time device preview
/// - State persistence on save
/// 
/// Navigation Flow:
/// Dashboard (Watch mode) → Edit Widgets → WatchCustomizationScreen
```

---

## 🔍 Migration Guide

### Old Code (Before)
```dart
// dashboard_screen.dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => WidgetCustomizationScreen(
      allWidgetCards: allWidgetCards,
      initialDeviceState: deviceState,
    ),
  ),
);
```

### New Code (After)
```dart
// dashboard_screen.dart
Widget customizationScreen;

switch (deviceState.deviceMode) {
  case 'watch':
    customizationScreen = WatchCustomizationScreen(...);
    break;
  case 'carry':
    customizationScreen = CarryCustomizationScreen(...);
    break;
  case 'tag':
    customizationScreen = TagCustomizationScreen(...);
    break;
}

Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => customizationScreen),
);
```

---

## ✅ Checklist

- [x] Create WatchCustomizationScreen (full implementation)
- [x] Create CarryCustomizationScreen (placeholder)
- [x] Create TagCustomizationScreen (placeholder)
- [x] Update dashboard navigation logic
- [x] Add mode detection switch statement
- [x] Deprecate old WidgetCustomizationScreen
- [x] Add mode indicator badges
- [x] Document navigation flow
- [x] Add inline code comments
- [x] Update imports in dashboard
- [x] Test mode switching
- [x] Verify state persistence
- [ ] Implement Carry mode features (future)
- [ ] Implement Tag mode features (future)
- [ ] Add unit tests for navigation
- [ ] Add widget tests for each screen

---

## 🎯 Summary

**Completed:**
✅ Mode-based navigation routing  
✅ Three distinct customization screens  
✅ State synchronization across modes  
✅ Real-time preview updates  
✅ Backward compatibility (deprecated wrapper)  
✅ Comprehensive documentation  

**Next Steps:**
🚧 Implement Carry mode features  
🚧 Implement Tag mode features  
🧪 Add automated tests  
📱 User testing and feedback  

---

**Documentation by:** GitHub Copilot CLI  
**Last Updated:** 2026-01-07  
**Version:** 1.0.0
