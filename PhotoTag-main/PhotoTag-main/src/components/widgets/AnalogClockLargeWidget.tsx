import React, { useEffect, useState } from "react";
import { Clock } from "lucide-react";

interface AnalogClockLargeWidgetProps {
  theme: "light" | "dark";
}

const AnalogClockLargeWidget: React.FC<AnalogClockLargeWidgetProps> = ({ theme }) => {
  const [time, setTime] = useState(new Date());

  useEffect(() => {
    const timerId = setInterval(() => setTime(new Date()), 1000);
    return () => clearInterval(timerId);
  }, []);

  const hours = time.getHours();
  const minutes = time.getMinutes();
  const seconds = time.getSeconds();

  const hourDeg = (hours % 12) * 30 + minutes * 0.5;
  const minuteDeg = minutes * 6 + seconds * 0.1;
  const secondDeg = seconds * 6;

  const handColor = theme === "dark" ? "bg-primary-foreground" : "bg-primary";
  const accentColor = theme === "dark" ? "bg-blue-400" : "bg-blue-600"; // For second hand
  const borderColor = theme === "dark" ? "border-primary-foreground" : "border-primary";

  return (
    <div className={`relative w-24 h-24 rounded-full border-2 ${borderColor} flex items-center justify-center p-2`}>
      <div className={`absolute w-1.5 h-1.5 rounded-full ${handColor} z-20`}></div> {/* Center dot */}
      {/* Hour Hand */}
      <div
        className={`absolute bottom-1/2 left-1/2 w-0.5 h-8 ${handColor} origin-bottom rounded-t-full`}
        style={{ transform: `translateX(-50%) rotate(${hourDeg}deg)` }}
      ></div>
      {/* Minute Hand */}
      <div
        className={`absolute bottom-1/2 left-1/2 w-0.5 h-10 ${handColor} origin-bottom rounded-t-full`}
        style={{ transform: `translateX(-50%) rotate(${minuteDeg}deg)` }}
      ></div>
      {/* Second Hand */}
      <div
        className={`absolute bottom-1/2 left-1/2 w-0.5 h-9 ${accentColor} origin-bottom rounded-t-full`}
        style={{ transform: `translateX(-50%) rotate(${secondDeg}deg)` }}
      ></div>
    </div>
  );
};

export default AnalogClockLargeWidget;