// src/components/DevicePreview.tsx

import React from "react";
import { DeviceState } from "@/services/bleService";
import { cn } from "@/lib/utils";
import { WifiOff } from "lucide-react";
import DigitalClockSmallWidget from "./widgets/DigitalClockSmallWidget";
import AnalogClockSmallWidget from "./widgets/AnalogClockSmallWidget";
import DigitalClockLargeWidget from "./widgets/DigitalClockLargeWidget";
import AnalogClockLargeWidget from "./widgets/AnalogClockLargeWidget";
import TextDateClockWidget from "./widgets/TextDateClockWidget";
import WeatherWidget from "./widgets/WeatherWidget"; // This is the icon-only weather
import WeatherTempIconWidget from "./widgets/WeatherTempIconWidget";
import WeatherFullWidget from "./widgets/WeatherFullWidget";
import BatteryWidget from "./widgets/BatteryWidget"; // This is the text battery
import BatteryBarWidget from "./widgets/BatteryBarWidget";
import MusicMiniWidget from "./widgets/MusicMiniWidget";
import MusicFullWidget from "./widgets/MusicFullWidget";
import DirectionsCompactWidget from "./widgets/DirectionsCompactWidget";
import DirectionsFullWidget from "./widgets/DirectionsFullWidget";

interface DevicePreviewProps {
  deviceState: DeviceState;
  className?: string;
}

const DevicePreview: React.FC<DevicePreviewProps> = ({ deviceState, className }) => {
  const { isConnected, battery, aod, music, navigation, theme, widgets, backgroundImage, weather } = deviceState;

  // AOD always-on implies dark theme for power saving, but we'll ensure elements are bright
  const displayTheme = aod.enabled && aod.timeout === "always" ? "dark" : theme;

  const currentTime = new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });

  return (
    <div
      className={cn(
        "relative w-48 h-80 rounded-2xl shadow-xl flex flex-col items-center justify-center", // Removed p-2
        "border-[3px] border-gray-800 dark:border-gray-200 bg-gray-950 dark:bg-gray-50", // Slimmer border
        className,
      )}
      style={{
        backgroundColor: displayTheme === "dark" ? "#1a1a1a" : "#f0f0f0",
        color: displayTheme === "dark" ? "#e0e0e0" : "#333333",
      }}
    >
      {/* Device Bezel / Frame - now handled by the main div's border */}
      <div className="absolute top-2 left-1/2 -translate-x-1/2 w-12 h-1.5 bg-gray-600 dark:bg-gray-400 rounded-full"></div> {/* Top speaker/sensor */}

      {/* Screen Area */}
      <div
        className={cn(
          "relative w-full h-full rounded-lg overflow-hidden", // Changed to w-full h-full
          "flex flex-col justify-between p-2 text-xs",
          "bg-cover bg-center", // Added for background image styling
        )}
        style={{
          backgroundColor: displayTheme === "dark" ? "#000000" : "#ffffff",
          color: displayTheme === "dark" ? "#e0e0e0" : "#333333",
          backgroundImage: backgroundImage ? `url(${backgroundImage})` : "none", // Apply custom background image
        }}
      >
        {/* Overlay for readability if background image is present */}
        {backgroundImage && (
          <div className="absolute inset-0 bg-black/30 dark:bg-black/50 z-0"></div>
        )}

        {/* Top Status Bar */}
        <div className="relative z-10 flex justify-between items-center text-[0.6rem] font-mono">
          <span>{currentTime}</span>
          <div className="flex items-center space-x-1">
            {!isConnected && <WifiOff size={10} className="text-red-500" />}
            {isConnected && (
              // Battery widget in status bar is always the compact text version
              <BatteryWidget battery={battery} isConnected={isConnected} theme={displayTheme} />
            )}
          </div>
        </div>

        {/* Main Content Area - Render Widgets */}
        <div className="relative z-10 flex-grow flex flex-col items-center justify-center space-y-1 text-center">
          {widgets.includes("time-digital-small") && (
            <DigitalClockSmallWidget time={currentTime} theme={displayTheme} />
          )}
          {widgets.includes("time-digital-large") && (
            <DigitalClockLargeWidget time={currentTime} theme={displayTheme} />
          )}
          {widgets.includes("time-analog-small") && (
            <AnalogClockSmallWidget theme={displayTheme} />
          )}
          {widgets.includes("time-analog-large") && (
            <AnalogClockLargeWidget theme={displayTheme} />
          )}
          {widgets.includes("time-text-date") && (
            <TextDateClockWidget theme={displayTheme} />
          )}

          {widgets.includes("weather-icon") && (
            <WeatherWidget weather={weather} theme={displayTheme} />
          )}
          {widgets.includes("weather-temp-icon") && (
            <WeatherTempIconWidget weather={weather} theme={displayTheme} />
          )}
          {widgets.includes("weather-full") && (
            <WeatherFullWidget weather={weather} theme={displayTheme} />
          )}

          {widgets.includes("battery-status") && !isConnected && ( // Only show if not in top status bar
            <BatteryWidget battery={battery} isConnected={isConnected} theme={displayTheme} />
          )}
          {widgets.includes("battery-bar") && (
            <BatteryBarWidget battery={battery} isConnected={isConnected} theme={displayTheme} />
          )}

          {widgets.includes("music-mini") && (
            <MusicMiniWidget isPlaying={music.isPlaying} trackTitle={music.trackTitle} theme={displayTheme} />
          )}
          {widgets.includes("music-full") && (
            <MusicFullWidget isPlaying={music.isPlaying} trackTitle={music.trackTitle} theme={displayTheme} />
          )}

          {widgets.includes("directions-compact") && (
            <DirectionsCompactWidget navigation={navigation} theme={displayTheme} />
          )}
          {widgets.includes("directions-full") && (
            <DirectionsFullWidget navigation={navigation} theme={displayTheme} />
          )}

          {/* Fallback if no widgets are active */}
          {!widgets.length && !navigation.ridingMode && !music.isPlaying && (
            <span className="text-gray-500 dark:text-gray-400">No widgets active</span>
          )}
        </div>

        {/* Bottom Indicator/Info */}
        <div className="relative z-10 text-[0.6rem] text-center opacity-70">
          {aod.enabled ? "AOD ON" : "AOD OFF"}
        </div>
      </div>
    </div>
  );
};

export default DevicePreview;