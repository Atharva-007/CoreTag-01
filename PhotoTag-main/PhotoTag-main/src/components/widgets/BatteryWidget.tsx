import React from "react";
import { BatteryMedium, BatteryCharging } from "lucide-react";

interface BatteryWidgetProps {
  battery: number;
  isConnected: boolean;
  theme: "light" | "dark";
}

const BatteryWidget: React.FC<BatteryWidgetProps> = ({ battery, isConnected, theme }) => {
  const textColor = theme === "dark" ? "text-gray-200" : "text-gray-800";
  const iconColor = battery > 20 ? "text-green-500" : "text-red-500";

  return (
    <div className="flex items-center p-1">
      {isConnected ? (
        <BatteryCharging className={`h-5 w-5 ${iconColor} mr-1`} />
      ) : (
        <BatteryMedium className={`h-5 w-5 ${iconColor} mr-1`} />
      )}
      <span className={`text-sm font-semibold ${textColor}`}>{battery}%</span>
    </div>
  );
};

export default BatteryWidget;