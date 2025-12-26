// src/pages/Navigation.tsx

import React from "react";
import { Link } from "react-router-dom";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Switch } from "@/components/ui/switch";
import { Label } from "@/components/ui/label";
import { MapPin, Sun, Moon, ArrowLeft, Gauge } from "lucide-react"; // Added ArrowLeft and Gauge icons
import DevicePreview from "@/components/DevicePreview";
import { useDevice } from "@/context/DeviceContext";

const Navigation = () => {
  const { appPreviewState, updateAppPreview, applyChangesToDevice } = useDevice();
  const { navigation } = appPreviewState;

  const handleRidingModeToggle = (checked: boolean) => {
    updateAppPreview({ navigation: { ...navigation, ridingMode: checked } });
  };

  const handleThemeToggle = (checked: boolean) => {
    updateAppPreview({ navigation: { ...navigation, theme: checked ? "dark" : "light" } });
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
          <h1 className="text-4xl font-bold text-center tracking-tight">Navigation / Directions</h1>
          <Button onClick={applyChangesToDevice}>Apply to Device</Button>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
          {/* Device Preview */}
          <div className="flex justify-center items-center sticky top-4 md:top-20">
            <DevicePreview deviceState={appPreviewState} className="scale-110 md:scale-100 transition-transform duration-300 hover:scale-[1.05] hover:shadow-2xl" />
          </div>

          {/* Navigation Controls */}
          <div className="space-y-6">
            <Card className="transition-all duration-200 hover:scale-[1.01] hover:shadow-md">
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-lg font-semibold">Riding Mode</CardTitle>
                <MapPin className="h-5 w-5 text-muted-foreground" />
              </CardHeader>
              <CardContent>
                <div className="flex items-center justify-between">
                  <Label htmlFor="riding-mode-toggle" className="text-base">Enable Riding Mode</Label>
                  <Switch
                    id="riding-mode-toggle"
                    checked={navigation.ridingMode}
                    onCheckedChange={handleRidingModeToggle}
                  />
                </div>
                <p className="text-sm text-muted-foreground mt-2">
                  Optimizes display for essential navigation data.
                </p>
              </CardContent>
            </Card>

            <Card className="transition-all duration-200 hover:scale-[1.01] hover:shadow-md">
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-lg font-semibold">Navigation Data (Mock)</CardTitle>
                <Gauge className="h-5 w-5 text-muted-foreground" />
              </CardHeader>
              <CardContent className="space-y-3">
                <div className="flex justify-between items-center border-b pb-2 last:border-b-0 last:pb-0 border-border/50">
                  <span className="text-sm text-muted-foreground">Next Turn:</span>
                  <span className="font-semibold text-right">{navigation.nextTurn}</span>
                </div>
                <div className="flex justify-between items-center border-b pb-2 last:border-b-0 last:pb-0 border-border/50">
                  <span className="text-sm text-muted-foreground">ETA:</span>
                  <span className="font-semibold text-right">{navigation.eta}</span>
                </div>
                <div className="flex justify-between items-center border-b pb-2 last:border-b-0 last:pb-0 border-border/50">
                  <span className="text-sm text-muted-foreground">Current Speed:</span>
                  <span className="font-semibold text-right">{navigation.currentSpeed} km/h</span>
                </div>
                <div className="flex justify-between items-center">
                  <span className="text-sm text-muted-foreground">Distance Remaining:</span>
                  <span className="font-semibold text-right">{navigation.distanceRemaining}</span>
                </div>
                <Button
                  onClick={() => updateAppPreview({
                    navigation: {
                      ...navigation,
                      nextTurn: "Turn right in 50m",
                      eta: "1 min",
                      currentSpeed: 30,
                      distanceRemaining: "0.5 km",
                    }
                  })}
                  className="mt-4 w-full"
                >
                  Simulate Next Turn
                </Button>
              </CardContent>
            </Card>

            <Card className="transition-all duration-200 hover:scale-[1.01] hover:shadow-md">
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-lg font-semibold">Display Theme</CardTitle>
                {navigation.theme === "dark" ? <Moon className="h-5 w-5 text-muted-foreground" /> : <Sun className="h-5 w-5 text-muted-foreground" />}
              </CardHeader>
              <CardContent>
                <div className="flex items-center justify-between">
                  <Label htmlFor="nav-theme-toggle" className="text-base">Dark Mode</Label>
                  <Switch
                    id="nav-theme-toggle"
                    checked={navigation.theme === "dark"}
                    onCheckedChange={handleThemeToggle}
                  />
                </div>
                <p className="text-sm text-muted-foreground mt-2">
                  Set the visual theme for navigation display.
                </p>
              </CardContent>
            </Card>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Navigation;