import React from "react";
import { MapPin, ArrowLeft, ArrowRight, ArrowUp, Gauge, Clock } from "lucide-react";
import { DeviceState } from "@/services/bleService";

interface DirectionsFullWidgetProps {
  navigation: DeviceState['navigation'];
  theme: "light" | "dark";
}

const DirectionsFullWidget: React.FC<DirectionsFullWidgetProps> = ({ navigation, theme }) => {
  const iconSize = 60;
  const iconClasses = "text-blue-500"; // Use a consistent bright color
  const textColor = theme === "dark" ? "text-gray-100" : "text-gray-900";
  const mutedTextColor = theme === "dark" ? "text-gray-400" : "text-gray-600";

  const getNavigationIcon = (nextTurn: string) => {
    if (nextTurn.toLowerCase().includes("left")) {
      return <ArrowLeft size={iconSize} className={iconClasses} />;
    }
    if (nextTurn.toLowerCase().includes("right")) {
      return <ArrowRight size={iconSize} className={iconClasses} />;
    }
    if (nextTurn.toLowerCase().includes("straight")) {
      return <ArrowUp size={iconSize} className={iconClasses} />;
    }
    return <MapPin size={iconSize} className={iconClasses} />;
  };

  if (!navigation.ridingMode) return null;

  return (
    <div className="flex flex-col items-center p-2 w-full">
      {getNavigationIcon(navigation.nextTurn)}
      <span className={`text-xl font-bold text-center mt-2 ${textColor}`}>{navigation.nextTurn}</span>
      <div className="flex items-center space-x-2 mt-2">
        <Clock className={`h-4 w-4 ${mutedTextColor}`} />
        <span className={`text-sm ${mutedTextColor}`}>{navigation.eta}</span>
        <Gauge className={`h-4 w-4 ml-4 ${mutedTextColor}`} />
        <span className={`text-sm ${mutedTextColor}`}>{navigation.currentSpeed} km/h</span>
      </div>
      <span className={`text-sm mt-1 ${mutedTextColor}`}>Distance: {navigation.distanceRemaining}</span>
    </div>
  );
};

export default DirectionsFullWidget;