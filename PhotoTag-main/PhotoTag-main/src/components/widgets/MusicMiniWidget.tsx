import React from "react";
import { Music } from "lucide-react";

interface MusicMiniWidgetProps {
  isPlaying: boolean;
  trackTitle: string;
  theme: "light" | "dark";
}

const MusicMiniWidget: React.FC<MusicMiniWidgetProps> = ({ isPlaying, trackTitle, theme }) => {
  const textColor = theme === "dark" ? "text-gray-200" : "text-gray-800";

  if (!isPlaying) return null;

  return (
    <div className="flex items-center p-1">
      <Music className={`h-4 w-4 text-primary mr-1`} />
      <span className={`text-sm truncate max-w-[80px] ${textColor}`}>{trackTitle}</span>
    </div>
  );
};

export default MusicMiniWidget;