import React from "react";
import { BatteryCharging, BatteryMedium } from "lucide-react";

interface BatteryBarWidgetProps {
  battery: number;
  isConnected: boolean;
  theme: "light" | "dark";
}

const BatteryBarWidget: React.FC<BatteryBarWidgetProps> = ({ battery, isConnected, theme }) => {
  const barColor = battery > 20 ? "bg-green-500" : "bg-red-500";
  const textColor = theme === "dark" ? "text-gray-200" : "text-gray-800";

  return (
    <div className="flex flex-col items-center p-1 w-full max-w-[100px]">
      <div className="flex items-center justify-between w-full mb-1">
        {isConnected ? (
          <BatteryCharging className={`h-4 w-4 text-primary`} />
        ) : (
          <BatteryMedium className={`h-4 w-4 text-primary`} />
        )}
        <span className={`text-sm font-semibold ${textColor}`}>{battery}%</span>
      </div>
      <div className="w-full h-2 bg-gray-300 dark:bg-gray-700 rounded-full overflow-hidden">
        <div
          className={`h-full ${barColor} transition-all duration-500 ease-out`}
          style={{ width: `${battery}%` }}
        ></div>
      </div>
    </div>
  );
};

export default BatteryBarWidget;