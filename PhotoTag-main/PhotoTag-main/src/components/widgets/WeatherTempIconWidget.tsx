import React from "react";
import { Sun, Cloud, CloudRain, Snowflake } from "lucide-react";
import { DeviceState } from "@/services/bleService";

interface WeatherTempIconWidgetProps {
  weather: DeviceState['weather'];
  theme: "light" | "dark";
}

const WeatherTempIconWidget: React.FC<WeatherTempIconWidgetProps> = ({ weather, theme }) => {
  const iconColor = theme === "dark" ? "text-yellow-300" : "text-yellow-500";
  const textColor = theme === "dark" ? "text-gray-200" : "text-gray-800";

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
    <div className="flex flex-col items-center p-1">
      <IconComponent className={`h-10 w-10 ${iconColor}`} />
      <span className={`text-xl font-bold ${textColor}`}>{weather.temperature}°C</span>
    </div>
  );
};

export default WeatherTempIconWidget;