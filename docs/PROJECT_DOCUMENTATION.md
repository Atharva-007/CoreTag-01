# CoreTag Project Documentation

## 1. Project Overview

CoreTag is a Flutter application designed to customize the screen of a connected hardware device, likely named "PhotoTag" or "CoreTag". The application provides a user-friendly interface to personalize the device's display by adding and configuring widgets, changing themes, and setting custom background images. The app features a live preview of the device's screen, allowing users to see their changes in real-time.

## 2. Architecture

The application follows a standard Flutter project structure.

*   **UI:** The user interface is built using Flutter widgets. The main screen of the application is the `DashboardScreen`, which serves as the central hub for all user interactions.
*   **State Management:** The application appears to use `StatefulWidget`s for managing state, with a centralized `DeviceState` model object that holds the configuration of the virtual device. This state is passed down the widget tree.
*   **Native Integration:** The application communicates with native Android code using `EventChannel` and `MethodChannel`. This is used to get real-time data for features like music track information and turn-by-turn navigation updates from other applications.

## 3. Key Features

*   **Device Preview:** A real-time preview of the connected device's screen is displayed within the app, which updates as the user customizes the layout and widgets.
*   **Widget Customization:** Users can add, remove, and customize a variety of widgets on the device's screen:
    *   **Time:** Both digital and analog clock widgets are available.
    *   **Weather:** Displays current weather information.
    *   **Music:** Shows the currently playing music track from other apps.
    *   **Navigation:** Provides turn-by-turn navigation instructions.
    *   **Photo:** Allows users to display a photo from their gallery.
*   **Theming and AOD:** The app supports both light and dark themes for the device's display. It also includes settings for an Always-On Display (AOD) mode.
*   **Background Photo:** Users can select a photo from their device's gallery, crop it to the desired aspect ratio, and set it as the background of the device's screen.
*   **Native Integrations:**
    *   **Music Detection:** The app listens to system notifications to get information about the currently playing music track from other apps.
    *   **Navigation Detection:** It listens to system notifications (presumably from apps like Google Maps) to display turn-by-turn navigation data.

## 4. Dependencies

The `pubspec.yaml` file lists the following key dependencies:

*   `flutter_animate`: Used for creating animations in the UI.
*   `image_picker` & `image_cropper`: Used for selecting and cropping images from the user's gallery.
*   `audio_service` & `just_audio`: Likely used for background audio capabilities or to control audio playback, though the primary function seems to be listening to other apps' audio sessions.
*   `permission_handler`: To request necessary permissions from the user, such as notification access.
*   `geolocator`: For accessing the device's GPS location, which is used for navigation features.

## 5. Future Development

For future development, it is recommended to:

*   **Analyze Native Code:** A deeper understanding of the native Android code in the `android` directory is required to fully grasp the implementation of the music and navigation event channels.
*   **Explore Other Screens:** The purpose and functionality of the other screens, such as `aod_settings_screen.dart` and `music_control_screen.dart`, should be investigated.
*   **Document Widgets:** The widgets in the `lib/widgets` directory should be documented to provide a complete picture of the UI components.
*   **Refactor State Management:** For better scalability and maintainability, consider migrating the state management from `StatefulWidget`s and `setState` to a more robust solution like Provider, BLoC, or Riverpod.
