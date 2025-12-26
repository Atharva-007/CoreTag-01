import React from "react";
import { Music, Play, Pause, SkipForward, SkipBack } from "lucide-react";

interface MusicFullWidgetProps {
  isPlaying: boolean;
  trackTitle: string;
  theme: "light" | "dark";
}

const MusicFullWidget: React.FC<MusicFullWidgetProps> = ({ isPlaying, trackTitle, theme }) => {
  const textColor = theme === "dark" ? "text-gray-100" : "text-gray-900";
  const mutedTextColor = theme === "dark" ? "text-gray-400" : "text-gray-600";
  
  // Use a consistent bright color for controls that works in both themes
  const controlColor = "text-blue-500";

  return (
    <div className="flex flex-col items-center p-2 w-full">
      <Music className={`h-6 w-6 ${controlColor} mb-2 ${textColor}`} />
      <span className={`text-lg font-bold truncate w-full text-center ${textColor}`}>{trackTitle}</span>
      <span className={`text-sm ${mutedTextColor}`}>Artist Name</span> {/* Mock artist */}
      <div className="flex items-center justify-center space-x-4 mt-4">
        <SkipBack className={`h-6 w-6 ${controlColor} opacity-70 hover:opacity-100 cursor-pointer`} />
        {isPlaying ? (
          <Pause className={`h-8 w-8 ${controlColor} hover:scale-110 transition-transform cursor-pointer`} />
        ) : (
          <Play className={`h-8 w-8 ${controlColor} hover:scale-110 transition-transform cursor-pointer`} />
        )}
        <SkipForward className={`h-6 w-6 ${controlColor} opacity-70 hover:opacity-100 cursor-pointer`} />
      </div>
    </div>
  );
};

export default MusicFullWidget;