import React, { useEffect, useState } from "react";
import { CalendarClock } from "lucide-react";

interface TextDateClockWidgetProps {
  theme: "light" | "dark";
}

const TextDateClockWidget: React.FC<TextDateClockWidgetProps> = ({ theme }) => {
  const [dateTime, setDateTime] = useState(new Date());

  useEffect(() => {
    const timerId = setInterval(() => setDateTime(new Date()), 1000);
    return () => clearInterval(timerId);
  }, []);

  const time = dateTime.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
  const date = dateTime.toLocaleDateString([], { weekday: 'short', month: 'short', day: 'numeric' });

  const textColor = theme === "dark" ? "text-gray-100" : "text-gray-900";
  const mutedTextColor = theme === "dark" ? "text-gray-400" : "text-gray-600";

  return (
    <div className="flex flex-col items-center justify-center p-2">
      <CalendarClock className={`h-5 w-5 text-primary mb-1 ${textColor}`} />
      <span className={`text-4xl font-extrabold tracking-tight ${textColor}`}>{time}</span>
      <span className={`text-sm ${mutedTextColor}`}>{date}</span>
    </div>
  );
};

export default TextDateClockWidget;