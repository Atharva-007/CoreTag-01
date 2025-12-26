// src/pages/MusicControl.tsx

import React from "react";
import { Link } from "react-router-dom";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Play, Pause, SkipForward, SkipBack, Headphones, ArrowLeft } from "lucide-react";
import DevicePreview from "@/components/DevicePreview";
import { useDevice } from "@/context/DeviceContext";

const MusicControl = () => {
  const { appPreviewState, updateAppPreview, simulateButtonPress } = useDevice();
  const { music } = appPreviewState;

  const togglePlayPause = () => {
    updateAppPreview({ music: { ...music, isPlaying: !music.isPlaying } });
    // In a real app, this would also send a command to the phone's media session
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
          <h1 className="text-4xl font-bold text-center tracking-tight">Music Control</h1>
          <Button onClick={() => simulateButtonPress("play_pause")} variant="secondary">
            Simulate Device Play/Pause
          </Button>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
          {/* Device Preview */}
          <div className="flex justify-center items-center sticky top-4 md:top-20">
            <DevicePreview deviceState={appPreviewState} className="scale-110 md:scale-100 transition-transform duration-300 hover:scale-[1.05] hover:shadow-2xl" />
          </div>

          {/* Music Controls */}
          <div className="space-y-6 flex flex-col justify-center">
            <Card className="text-center p-6 transition-all duration-200 hover:scale-[1.01] hover:shadow-md">
              <CardHeader className="pb-4">
                <Headphones className="h-12 w-12 mx-auto mb-4 text-primary" />
                <CardTitle className="text-3xl font-extrabold tracking-tight">
                  {music.trackTitle}
                </CardTitle>
              </CardHeader>
              <CardContent className="pt-4">
                <div className="flex items-center justify-center space-x-6 mt-4">
                  <Button variant="ghost" size="icon" className="h-14 w-14 text-muted-foreground hover:text-primary transition-colors">
                    <SkipBack className="h-8 w-8" />
                  </Button>
                  <Button onClick={togglePlayPause} size="icon" className="h-20 w-20 rounded-full shadow-lg hover:scale-105 transition-transform duration-200">
                    {music.isPlaying ? <Pause className="h-12 w-12" /> : <Play className="h-12 w-12" />}
                  </Button>
                  <Button variant="ghost" size="icon" className="h-14 w-14 text-muted-foreground hover:text-primary transition-colors">
                    <SkipForward className="h-8 w-8" />
                  </Button>
                </div>
                <p className="text-sm text-muted-foreground mt-6">
                  Control music playback on your connected device.
                </p>
              </CardContent>
            </Card>
          </div>
        </div>
      </div>
    </div>
  );
};

export default MusicControl;