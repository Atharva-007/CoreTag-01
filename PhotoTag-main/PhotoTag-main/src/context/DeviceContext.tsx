// src/context/DeviceContext.tsx
import React, { createContext, useContext, useState, useEffect, ReactNode, useCallback } from "react";
import { bleService, DeviceState } from "@/services/bleService";
import { toast } from "sonner";

interface DeviceContextType {
  physicalDeviceState: DeviceState;
  appPreviewState: DeviceState;
  connectDevice: () => Promise<void>;
  disconnectDevice: () => Promise<void>;
  updateAppPreview: (newState: Partial<DeviceState>) => void;
  applyChangesToDevice: () => Promise<void>;
  simulateButtonPress: (button: "play_pause" | "next" | "prev") => void;
}

const DeviceContext = createContext<DeviceContextType | undefined>(undefined);

export const DeviceProvider = ({ children }: { children: ReactNode }) => {
  const [physicalDeviceState, setPhysicalDeviceState] = useState<DeviceState>(
    bleService.getPhysicalDeviceState(),
  );
  const [appPreviewState, setAppPreviewState] = useState<DeviceState>(
    bleService.getAppPreviewState(),
  );

  useEffect(() => {
    const unsubscribe = bleService.subscribeToDeviceUpdates((state) => {
      setPhysicalDeviceState(state);
      // Also update app preview state to reflect physical device changes
      setAppPreviewState(state);
    });
    
    // Fix: Return a proper cleanup function that calls unsubscribe
    return () => {
      unsubscribe();
    };
  }, []);

  const connectDevice = useCallback(async () => {
    await bleService.connect();
    setPhysicalDeviceState(bleService.getPhysicalDeviceState());
    setAppPreviewState(bleService.getAppPreviewState());
  }, []);

  const disconnectDevice = useCallback(async () => {
    await bleService.disconnect();
    setPhysicalDeviceState(bleService.getPhysicalDeviceState());
    setAppPreviewState(bleService.getAppPreviewState());
  }, []);

  const updateAppPreview = useCallback((newState: Partial<DeviceState>) => {
    bleService.updateAppPreviewState(newState);
    setAppPreviewState(bleService.getAppPreviewState());
  }, []);

  const applyChangesToDevice = useCallback(async () => {
    const success = await bleService.writeConfigToDevice(appPreviewState);
    if (success) {
      setPhysicalDeviceState(bleService.getPhysicalDeviceState());
    }
  }, [appPreviewState]);

  const simulateButtonPress = useCallback((button: "play_pause" | "next" | "prev") => {
    bleService.simulateDeviceButtonPress(button);
    setPhysicalDeviceState(bleService.getPhysicalDeviceState());
    setAppPreviewState(bleService.getAppPreviewState());
  }, []);

  return (
    <DeviceContext.Provider
      value={{
        physicalDeviceState,
        appPreviewState,
        connectDevice,
        disconnectDevice,
        updateAppPreview,
        applyChangesToDevice,
        simulateButtonPress,
      }}
    >
      {children}
    </DeviceContext.Provider>
  );
};

export const useDevice = () => {
  const context = useContext(DeviceContext);
  if (context === undefined) {
    throw new Error("useDevice must be used within a DeviceProvider");
  }
  return context;
};