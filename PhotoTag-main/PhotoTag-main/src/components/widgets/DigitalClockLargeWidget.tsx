import React from "react";
import { Clock } from "lucide-react";

interface DigitalClockLargeWidgetProps {
  time: string;
  theme: "light" | "dark";
}

const DigitalClockLargeWidget: React.FC<DigitalClockLargeWidgetProps> = ({ time, theme }) => {
  const textColor = theme === "dark" ? "text-gray-100" : "text-gray-900";
  return (
    <div className="flex flex-col items-center justify-center p-2">
      <Clock className={`h-6 w-6 text-primary mb-2 ${textColor}`} />
      <span className={`text-5xl font-extrabold tracking-tight ${textColor}`}>{time}</span>
    </div>
  );
};

export default DigitalClockLargeWidget;