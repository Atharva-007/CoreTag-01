// src/pages/AODSettings.tsx

import React from "react";
import { Link } from "react-router-dom";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Switch } from "@/components/ui/switch";
import { Label } from "@/components/ui/label";
import { Slider } from "@/components/ui/slider";
import { RadioGroup, RadioGroupItem } from "@/components/ui/radio-group";
import DevicePreview from "@/components/DevicePreview";
import { useDevice } from "@/context/DeviceContext";
import { ArrowLeft, Sun, Moon, Clock, BatteryCharging } from "lucide-react"; // Added icons

const AODSettings = () => {
  const { appPreviewState, updateAppPreview, applyChangesToDevice } = useDevice();
  const { aod } = appPreviewState;

  const handleAODToggle = (checked: boolean) => {
    updateAppPreview({ aod: { ...aod, enabled: checked } });
  };

  const handleTimeoutChange = (value: string) => {
    updateAppPreview({ aod: { ...aod, timeout: value as "10s" | "30s" | "1m" | "always" } });
  };

  const handleBrightnessChange = (value: number[]) => {
    updateAppPreview({ aod: { ...aod, brightness: value[0] } });
  };

  const handleAutoDimToggle = (checked: boolean) => {
    updateAppPreview({ aod: { ...aod, autoDim: checked } });
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
          <h1 className="text-4xl font-bold text-center tracking-tight">Always-On Display Settings</h1>
          <Button onClick={applyChangesToDevice}>Apply to Device</Button>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
          {/* Device Preview */}
          <div className="flex justify-center items-center sticky top-4 md:top-20">
            <DevicePreview deviceState={appPreviewState} className="scale-110 md:scale-100 transition-transform duration-300 hover:scale-[1.05] hover:shadow-2xl" />
          </div>

          {/* Settings Controls */}
          <div className="space-y-6">
            <Card className="transition-all duration-200 hover:scale-[1.01] hover:shadow-md">
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-lg font-semibold">Always On Display</CardTitle>
                <Clock className="h-5 w-5 text-muted-foreground" />
              </CardHeader>
              <CardContent>
                <div className="flex items-center justify-between">
                  <Label htmlFor="aod-toggle" className="text-base">Enable AOD</Label>
                  <Switch
                    id="aod-toggle"
                    checked={aod.enabled}
                    onCheckedChange={handleAODToggle}
                  />
                </div>
                <p className="text-sm text-muted-foreground mt-2">
                  Keep essential information visible at all times.
                </p>
              </CardContent>
            </Card>

            <Card className="transition-all duration-200 hover:scale-[1.01] hover:shadow-md">
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-lg font-semibold">AOD Timeout</CardTitle>
                <Clock className="h-5 w-5 text-muted-foreground" />
              </CardHeader>
              <CardContent>
                <RadioGroup
                  value={aod.timeout}
                  onValueChange={handleTimeoutChange}
                  className="grid grid-cols-2 gap-4"
                >
                  <div className="flex items-center space-x-2">
                    <RadioGroupItem value="10s" id="timeout-10s" />
                    <Label htmlFor="timeout-10s">10 seconds</Label>
                  </div>
                  <div className="flex items-center space-x-2">
                    <RadioGroupItem value="30s" id="timeout-30s" />
                    <Label htmlFor="timeout-30s">30 seconds</Label>
                  </div>
                  <div className="flex items-center space-x-2">
                    <RadioGroupItem value="1m" id="timeout-1m" />
                    <Label htmlFor="timeout-1m">1 minute</Label>
                  </div>
                  <div className="flex items-center space-x-2">
                    <RadioGroupItem value="always" id="timeout-always" />
                    <Label htmlFor="timeout-always">Always On (low brightness)</Label>
                  </div>
                </RadioGroup>
                <p className="text-sm text-muted-foreground mt-4">
                  Determines how long the AOD stays active before turning off.
                </p>
              </CardContent>
            </Card>

            <Card className="transition-all duration-200 hover:scale-[1.01] hover:shadow-md">
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-lg font-semibold">Brightness Control</CardTitle>
                <Sun className="h-5 w-5 text-muted-foreground" />
              </CardHeader>
              <CardContent>
                <div className="flex items-center space-x-4">
                  <Slider
                    min={0}
                    max={100}
                    step={1}
                    value={[aod.brightness]}
                    onValueChange={handleBrightnessChange}
                    className="w-full"
                  />
                  <span className="w-10 text-right text-sm font-medium">{aod.brightness}%</span>
                </div>
                <div className="flex items-center justify-between mt-6">
                  <Label htmlFor="auto-dim-toggle" className="text-base">Auto-Dim Logic</Label>
                  <Switch
                    id="auto-dim-toggle"
                    checked={aod.autoDim}
                    onCheckedChange={handleAutoDimToggle}
                  />
                </div>
                <p className="text-sm text-muted-foreground mt-2">
                  Automatically adjusts brightness based on ambient light.
                </p>
                <div className="mt-6 p-3 bg-muted rounded-md flex items-center gap-2 text-sm text-muted-foreground border-l-4 border-blue-500">
                  <BatteryCharging className="h-4 w-4" />
                  <span>Power-saving indicators: Currently consuming minimal power.</span>
                </div>
              </CardContent>
            </Card>
          </div>
        </div>
      </div>
    </div>
  );
};

export default AODSettings;