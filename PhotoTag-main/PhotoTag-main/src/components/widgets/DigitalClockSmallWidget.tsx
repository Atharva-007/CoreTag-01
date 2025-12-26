import React from "react";
import { Clock } from "lucide-react";

interface DigitalClockSmallWidgetProps {
  time: string;
  theme: "light" | "dark";
}

const DigitalClockSmallWidget: React.FC<DigitalClockSmallWidgetProps> = ({ time, theme }) => {
  const textColor = theme === "dark" ? "text-gray-200" : "text-gray-800";
  return (
    <div className="flex flex-col items-center justify-center p-1">
      <Clock className={`h-4 w-4 text-primary mb-1 ${textColor}`} />
      <span className={`text-xl font-bold ${textColor}`}>{time}</span>
    </div>
  );
};

export default DigitalClockSmallWidget;