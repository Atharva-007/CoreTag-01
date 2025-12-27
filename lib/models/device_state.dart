class DeviceState {
  final bool isConnected;
  final int battery;
  final String theme;
  final List<String> widgets;
  final MusicState music;
  final NavigationState navigation;
  final WeatherState weather;
  final AODState aod;
  final String? backgroundImage;

  DeviceState({
    this.isConnected = false,
    this.battery = 85,
    this.theme = 'dark',
    this.widgets = const [],
    required this.music,
    required this.navigation,
    required this.weather,
    required this.aod,
    this.backgroundImage,
  });

  DeviceState copyWith({
    bool? isConnected,
    int? battery,
    String? theme,
    List<String>? widgets,
    MusicState? music,
    NavigationState? navigation,
    WeatherState? weather,
    AODState? aod,
    String? backgroundImage,
  }) {
    return DeviceState(
      isConnected: isConnected ?? this.isConnected,
      battery: battery ?? this.battery,
      theme: theme ?? this.theme,
      widgets: widgets ?? this.widgets,
      music: music ?? this.music,
      navigation: navigation ?? this.navigation,
      weather: weather ?? this.weather,
      aod: aod ?? this.aod,
      backgroundImage: backgroundImage ?? this.backgroundImage,
    );
  }
}

class MusicState {
  final bool isPlaying;
  final String trackTitle;
  final String artist;
  final String? albumArt; // Path to album art image

  const MusicState({
    this.isPlaying = false,
    this.trackTitle = 'No Track',
    this.artist = 'Unknown',
    this.albumArt,
  });

  MusicState copyWith({
    bool? isPlaying,
    String? trackTitle,
    String? artist,
    String? albumArt,
  }) {
    return MusicState(
      isPlaying: isPlaying ?? this.isPlaying,
      trackTitle: trackTitle ?? this.trackTitle,
      artist: artist ?? this.artist,
      albumArt: albumArt ?? this.albumArt,
    );
  }
}

class NavigationState {
  final bool ridingMode;
  final bool isNavigating;
  final String direction;
  final String distance;
  final String eta;
  final String? currentStreet;
  final String? nextTurn;
  final double? currentSpeed;
  final String? destination;

  const NavigationState({
    this.ridingMode = false,
    this.isNavigating = false,
    this.direction = 'Turn Left',
    this.distance = '500m',
    this.eta = '5 min',
    this.currentStreet,
    this.nextTurn,
    this.currentSpeed,
    this.destination,
  });

  NavigationState copyWith({
    bool? ridingMode,
    bool? isNavigating,
    String? direction,
    String? distance,
    String? eta,
    String? currentStreet,
    String? nextTurn,
    double? currentSpeed,
    String? destination,
  }) {
    return NavigationState(
      ridingMode: ridingMode ?? this.ridingMode,
      isNavigating: isNavigating ?? this.isNavigating,
      direction: direction ?? this.direction,
      distance: distance ?? this.distance,
      eta: eta ?? this.eta,
      currentStreet: currentStreet ?? this.currentStreet,
      nextTurn: nextTurn ?? this.nextTurn,
      currentSpeed: currentSpeed ?? this.currentSpeed,
      destination: destination ?? this.destination,
    );
  }
}

class WeatherState {
  final String condition;
  final int temperature;
  final String location;

  const WeatherState({
    this.condition = 'Sunny',
    this.temperature = 24,
    this.location = 'City',
  });

  WeatherState copyWith({
    String? condition,
    int? temperature,
    String? location,
  }) {
    return WeatherState(
      condition: condition ?? this.condition,
      temperature: temperature ?? this.temperature,
      location: location ?? this.location,
    );
  }
}

class AODState {
  final bool enabled;
  final String timeout;

  const AODState({
    this.enabled = false,
    this.timeout = 'always',
  });

  AODState copyWith({
    bool? enabled,
    String? timeout,
  }) {
    return AODState(
      enabled: enabled ?? this.enabled,
      timeout: timeout ?? this.timeout,
    );
  }
}
