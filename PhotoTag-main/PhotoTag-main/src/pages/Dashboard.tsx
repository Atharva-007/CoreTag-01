// src/pages/Dashboard.tsx

import React from "react";
import { useDevice } from "@/context/DeviceContext";
import { MadeWithDyad } from "@/components/made-with-dyad";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Link } from "react-router-dom";
import {
  BatteryCharging,
  Bluetooth,
  Clock,
  Compass,
  Headphones,
  Palette,
  Settings,
  WifiOff,
} from "lucide-react";
import DevicePreview from "@/components/DevicePreview";
import { cn } from "@/lib/utils"; // Import cn for conditional class merging

const Dashboard = () => {
  const { physicalDeviceState, appPreviewState, connectDevice, disconnectDevice } = useDevice();
  const { isConnected, battery } = physicalDeviceState;

  return (
    <div className="min-h-screen flex flex-col items-center justify-between p-4 bg-gradient-to-br from-blue-50 to-indigo-100 dark:from-gray-900 dark:to-blue-950 text-foreground">
      <div className="w-full max-w-4xl mx-auto py-8">
        <h1 className="text-5xl md:text-6xl font-extrabold text-center mb-12 tracking-tight">
          ZeroCore - PhotoTag
        </h1>

        {/* Connection Status */}
        <Card className="mb-12 border-2 shadow-lg transition-all duration-200 hover:scale-[1.005] hover:shadow-xl">
          <CardHeader className={cn("flex flex-row items-center justify-between space-y-0", isConnected ? "pb-0" : "pb-4")}>
            <CardTitle className="text-xl font-semibold">
              {!isConnected && "Device Status"}
            </CardTitle>
            {/* Removed the top Bluetooth/WiFi icon when connected */}
            {!isConnected && (
              <WifiOff className="h-7 w-7 text-muted-foreground" />
            )}
          </CardHeader>
          <CardContent className={cn(isConnected ? "pt-2 pb-3" : "pt-4")}>
            {isConnected ? (
              <div className="flex items-center justify-between">
                <div className="text-xl font-bold flex items-center gap-2">
                  Connected
                  <span className="text-base text-muted-foreground flex items-center">
                    <BatteryCharging className="h-4 w-4 mr-1" /> {battery}%
                  </span>
                </div>
                <div className="flex items-center gap-2">
                  <Bluetooth className="h-5 w-5 text-blue-500 animate-pulse" />
                  <Button onClick={disconnectDevice} variant="destructive" size="sm">
                    Disconnect
                  </Button>
                </div>
              </div>
            ) : (
              <>
                <div className="text-3xl font-bold flex items-center gap-3">
                  Disconnected
                </div>
                <p className="text-sm text-muted-foreground mt-2">
                  Connect to your device to get started and see live updates.
                </p>
                <div className="mt-6">
                  <Button onClick={connectDevice} className="w-full md:w-auto">Connect Device</Button>
                </div>
              </>
            )}
          </CardContent>
        </Card>

        {/* Device Preview and Quick Access Tiles */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-12 items-start">
          {/* Device Preview */}
          <div className="flex justify-center items-center sticky top-4 md:top-20">
            <DevicePreview deviceState={appPreviewState} className="scale-110 md:scale-100 transition-transform duration-300 hover:scale-[1.05] hover:shadow-2xl" />
          </div>

          {/* Quick Access Tiles */}
          <div className="grid grid-cols-2 gap-6">
            <Link to="/aod-settings" className="group">
              <Card className="h-full flex flex-col items-center justify-center text-center p-6 border-2 transition-all duration-200 hover:scale-[1.02] hover:shadow-md group-hover:border-primary">
                <Clock className="h-9 w-9 mb-3 text-primary group-hover:text-primary-foreground transition-colors" />
                <CardTitle className="text-xl font-semibold">Time & Display</CardTitle>
                <CardDescription className="text-xs mt-1">AOD, Brightness</CardDescription>
              </Card>
            </Link>
            <Link to="/music-control" className="group">
              <Card className="h-full flex flex-col items-center justify-center text-center p-6 border-2 transition-all duration-200 hover:scale-[1.02] hover:shadow-md group-hover:border-primary">
                <Headphones className="h-9 w-9 mb-3 text-primary group-hover:text-primary-foreground transition-colors" />
                <CardTitle className="text-xl font-semibold">Music Control</CardTitle>
                <CardDescription className="text-xs mt-1">Play, Pause, Skip</CardDescription>
              </Card>
            </Link>
            <Link to="/navigation" className="group">
              <Card className="h-full flex flex-col items-center justify-center text-center p-6 border-2 transition-all duration-200 hover:scale-[1.02] hover:shadow-md group-hover:border-primary">
                <Compass className="h-9 w-9 mb-3 text-primary group-hover:text-primary-foreground transition-colors" />
                <CardTitle className="text-xl font-semibold">Directions</CardTitle>
                <CardDescription className="text-xs mt-1">Riding Mode, ETA</CardDescription>
              </Card>
            </Link>
            <Link to="/themes-widgets" className="group">
              <Card className="h-full flex flex-col items-center justify-center text-center p-6 border-2 transition-all duration-200 hover:scale-[1.02] hover:shadow-md group-hover:border-primary">
                <Palette className="h-9 w-9 mb-3 text-primary group-hover:text-primary-foreground transition-colors" />
                <CardTitle className="text-xl font-semibold">Themes & Widgets</CardTitle>
                <CardDescription className="text-xs mt-1">Customize display</CardDescription>
              </Card>
            </Link>
            {/* Placeholder for Device Settings - Visually disabled */}
            <div className="col-span-2"> {/* Make it span two columns for better visual balance */}
              <Card className="h-full flex flex-col items-center justify-center text-center p-6 opacity-60 cursor-not-allowed border-2">
                <Settings className="h-9 w-9 mb-3 text-muted-foreground" />
                <CardTitle className="text-xl font-semibold text-muted-foreground">Device Settings</CardTitle>
                <CardDescription className="text-xs mt-1">Coming Soon</CardDescription>
              </Card>
            </div>
          </div>
        </div>
      </div>
      <MadeWithDyad />
    </div>
  );
};

export default Dashboard;