import React from "react";
import { Sun, Cloud, CloudRain, Snowflake, MapPin } from "lucide-react";
import { DeviceState } from "@/services/bleService";

interface WeatherFullWidgetProps {
  weather: DeviceState['weather'];
  theme: "light" | "dark";
}

const WeatherFullWidget: React.FC<WeatherFullWidgetProps> = ({ weather, theme }) => {
  const iconColor = theme === "dark" ? "text-yellow-300" : "text-yellow-500";
  const textColor = theme === "dark" ? "text-gray-200" : "text-gray-800";
  const mutedTextColor = theme === "dark" ? "text-gray-400" : "text-gray-600";

  let IconComponent;
  switch (weather.condition) {
    case "sunny":
      IconComponent = Sun;
      break;
    case "cloudy":
      IconComponent = Cloud;
      break;
    case "rainy":
      IconComponent = CloudRain;
      break;
    case "snowy":
      IconComponent = Snowflake;
      break;
    default:
      IconComponent = Sun;
  }

  return (
    <div className="flex flex-col items-center p-2">
      <IconComponent className={`h-12 w-12 ${iconColor}`} />
      <span className={`text-3xl font-bold ${textColor}`}>{weather.temperature}°C</span>
      <span className={`text-sm capitalize ${mutedTextColor}`}>{weather.condition}</span>
      <div className="flex items-center text-xs mt-1">
        <MapPin className={`h-3 w-3 mr-1 ${mutedTextColor}`} />
        <span className={mutedTextColor}>New York</span> {/* Mock city for now */}
      </div>
    </div>
  );
};

export default WeatherFullWidget;