// src/pages/ThemesWidgets.tsx
import React from "react";
import { Link } from "react-router-dom";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Checkbox } from "@/components/ui/checkbox";
import { Label } from "@/components/ui/label";
import DevicePreview from "@/components/DevicePreview";
import { useDevice } from "@/context/DeviceContext";
import { RadioGroup, RadioGroupItem } from "@/components/ui/radio-group";
import { cn } from "@/lib/utils";
import { Input } from "@/components/ui/input";
import { toast } from "sonner";
import {
  Accordion,
  AccordionContent,
  AccordionItem,
  AccordionTrigger,
} from "@/components/ui/accordion";
import { ArrowLeft, Image as ImageIcon } from "lucide-react";
import { DeviceState } from "@/services/bleService"; // Import DeviceState type

// Import ArrowLeft icon and ImageIcon
const widgetCategories = [
  {
    name: "Clock",
    idPrefix: "time-",
    options: [
      { id: "time-digital-small", name: "Digital Clock (Small)" },
      { id: "time-digital-large", name: "Digital Clock (Large)" },
      { id: "time-analog-small", name: "Analog Clock (Small)" },
      { id: "time-analog-large", name: "Analog Clock (Large)" },
      { id: "time-text-date", name: "Digital Clock with Date" },
    ],
  },
  {
    name: "Weather",
    idPrefix: "weather-",
    options: [
      { id: "weather-icon", name: "Weather Icon Only" },
      { id: "weather-temp-icon", name: "Temperature + Icon" },
      { id: "weather-full", name: "Full Weather Details" },
    ],
  },
  {
    name: "Battery",
    idPrefix: "battery-",
    options: [
      { id: "battery-status", name: "Battery Status (Text)" },
      { id: "battery-bar", name: "Battery Bar" },
    ],
  },
  {
    name: "Music",
    idPrefix: "music-",
    options: [
      { id: "music-mini", name: "Music Mini Widget" },
      { id: "music-full", name: "Full Music Controls" },
    ],
  },
  {
    name: "Directions",
    idPrefix: "directions-",
    options: [
      { id: "directions-compact", name: "Directions Compact" },
      { id: "directions-full", name: "Full Directions" },
    ],
  },
];

const ThemesWidgets = () => {
  const { appPreviewState, updateAppPreview, applyChangesToDevice } = useDevice();
  const { theme, widgets, backgroundImage } = appPreviewState;

  const handleThemeChange = (value: string) => {
    updateAppPreview({ theme: value as "light" | "dark" });
  };

  const handleWidgetSelection = (categoryIdPrefix: string, selectedWidgetId: string) => {
    let newWidgets = widgets.filter(id => !id.startsWith(categoryIdPrefix)); // Remove existing from this category
    if (selectedWidgetId) { // Add new selection if not "none" or empty
      newWidgets.push(selectedWidgetId);
    }
    updateAppPreview({ widgets: newWidgets });
  };

  const handleImageUpload = (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (file) {
      if (!file.type.startsWith("image/")) {
        toast.error("Please upload an image file.");
        return;
      }
      const reader = new FileReader();
      reader.onloadend = () => {
        updateAppPreview({ backgroundImage: reader.result as string });
        toast.success("Background image uploaded!");
      };
      reader.onerror = () => {
        toast.error("Failed to read image file.");
      };
      reader.readAsDataURL(file);
    }
  };

  const handleClearImage = () => {
    updateAppPreview({ backgroundImage: undefined });
    toast.info("Background image cleared.");
  };

  // Create temporary device states for theme previews with explicit typing
  const lightThemePreviewState: DeviceState = {
    ...appPreviewState,
    theme: "light"
  };
  
  const darkThemePreviewState: DeviceState = {
    ...appPreviewState,
    theme: "dark"
  };

  return (
    <div className="min-h-screen flex flex-col items-center p-4 bg-gradient-to-br from-blue-50 to-indigo-100 dark:from-gray-900 dark:to-blue-950 text-foreground">
      <div className="w-full max-w-4xl mx-auto py-8">
        <div className="flex items-center justify-between mb-8">
          <Link to="/">
            <Button variant="outline" className="flex items-center gap-2">
              <ArrowLeft className="h-4 w-4" /> Back to Dashboard
            </Button>
          </Link>
          <h1 className="text-4xl font-bold text-center tracking-tight">Themes & Widgets Studio</h1>
          <Button onClick={applyChangesToDevice}>Apply to Device</Button>
        </div>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
          {/* Device Preview */}
          <div className="flex justify-center items-center sticky top-4 md:top-20">
            <DevicePreview deviceState={appPreviewState} className="scale-110 md:scale-100 transition-transform duration-300 hover:scale-[1.05] hover:shadow-2xl" />
          </div>
          {/* Theme and Widget Controls */}
          <div className="space-y-6">
            <Card className="transition-all duration-200 hover:scale-[1.01] hover:shadow-md">
              <CardHeader>
                <CardTitle>Theme Selection</CardTitle>
              </CardHeader>
              <CardContent>
                <RadioGroup value={theme} onValueChange={handleThemeChange} className="grid grid-cols-2 gap-4">
                  <div
                    className={cn(
                      "relative p-2 border rounded-md cursor-pointer flex flex-col items-center justify-center",
                      "transition-all duration-200 hover:scale-[1.02] hover:shadow-md",
                      theme === "light" ? "border-primary ring-2 ring-primary" : "border-border",
                    )}
                  >
                    <RadioGroupItem value="light" id="theme-light" className="sr-only" />
                    <Label htmlFor="theme-light" className="flex flex-col items-center justify-center h-full w-full">
                      <DevicePreview deviceState={lightThemePreviewState} className="w-24 h-40 scale-75 origin-top" />
                      <span className="mt-2 text-sm font-medium">Light Theme</span>
                    </Label>
                  </div>
                  <div
                    className={cn(
                      "relative p-2 border rounded-md cursor-pointer flex flex-col items-center justify-center",
                      "transition-all duration-200 hover:scale-[1.02] hover:shadow-md",
                      theme === "dark" ? "border-primary ring-2 ring-primary" : "border-border",
                    )}
                  >
                    <RadioGroupItem value="dark" id="theme-dark" className="sr-only" />
                    <Label htmlFor="theme-dark" className="flex flex-col items-center justify-center h-full w-full">
                      <DevicePreview deviceState={darkThemePreviewState} className="w-24 h-40 scale-75 origin-top" />
                      <span className="mt-2 text-sm font-medium">Dark Theme</span>
                    </Label>
                  </div>
                </RadioGroup>
                <p className="text-sm text-muted-foreground mt-4">
                  Choose a pre-built theme. Customization options coming soon.
                </p>
              </CardContent>
            </Card>
            <Card className="transition-all duration-200 hover:scale-[1.01] hover:shadow-md">
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle>Custom Background Image</CardTitle>
                <ImageIcon className="h-5 w-5 text-muted-foreground" />
              </CardHeader>
              <CardContent>
                <Label htmlFor="background-image-upload" className="mb-2 block">Upload Image</Label>
                <Input id="background-image-upload" type="file" accept="image/*" onChange={handleImageUpload} className="mb-4" />
                {backgroundImage && (
                  <Button variant="outline" onClick={handleClearImage} className="w-full">
                    Clear Background Image
                  </Button>
                )}
                <p className="text-sm text-muted-foreground mt-4">
                  Upload an image to use as the device background.
                </p>
              </CardContent>
            </Card>
            <Card className="transition-all duration-200 hover:scale-[1.01] hover:shadow-md">
              <CardHeader>
                <CardTitle>Widgets</CardTitle>
              </CardHeader>
              <CardContent>
                <Accordion type="single" collapsible className="w-full">
                  {widgetCategories.map((category) => (
                    <AccordionItem key={category.name} value={category.name}>
                      <AccordionTrigger>{category.name}</AccordionTrigger>
                      <AccordionContent>
                        <RadioGroup
                          value={widgets.find(id => id.startsWith(category.idPrefix)) || ""}
                          onValueChange={(value) => handleWidgetSelection(category.idPrefix, value)}
                          className="space-y-2"
                        >
                          {category.options.map((option) => (
                            <div key={option.id} className="flex items-center space-x-2">
                              <RadioGroupItem value={option.id} id={option.id} />
                              <Label htmlFor={option.id}>{option.name}</Label>
                            </div>
                          ))}
                          <div className="flex items-center space-x-2">
                            <RadioGroupItem value="" id={`${category.idPrefix}-none`} />
                            <Label htmlFor={`${category.idPrefix}-none`}>None</Label>
                          </div>
                        </RadioGroup>
                      </AccordionContent>
                    </AccordionItem>
                  ))}
                </Accordion>
                <p className="text-sm text-muted-foreground mt-4">
                  Select one widget per category to display on your device.
                </p>
              </CardContent>
            </Card>
          </div>
        </div>
      </div>
    </div>
  );
};

export default ThemesWidgets;