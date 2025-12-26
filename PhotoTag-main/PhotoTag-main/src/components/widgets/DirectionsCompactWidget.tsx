import React from "react";
import { MapPin, ArrowLeft, ArrowRight, ArrowUp } from "lucide-react";
import { DeviceState } from "@/services/bleService";

interface DirectionsCompactWidgetProps {
  navigation: DeviceState['navigation'];
  theme: "light" | "dark";
}

const DirectionsCompactWidget: React.FC<DirectionsCompactWidgetProps> = ({ navigation, theme }) => {
  const iconSize = 40; // Smaller icon for compact widget
  const iconClasses = "text-blue-500"; // Use a consistent bright color
  const textColor = theme === "dark" ? "text-gray-200" : "text-gray-800";

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
    <div className="flex flex-col items-center p-1">
      {getNavigationIcon(navigation.nextTurn)}
      <span className={`text-xs font-semibold ${textColor}`}>{navigation.nextTurn}</span>
      <span className={`text-[0.6rem] ${textColor}`}>{navigation.distanceRemaining} / {navigation.eta}</span>
    </div>
  );
};

export default DirectionsCompactWidget;