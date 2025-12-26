// src/services/bleService.ts

import { toast } from "sonner";

export interface DeviceState {
  isConnected: boolean;
  battery: number;
  aod: {
    enabled: boolean;
    timeout: "10s" | "30s" | "1m" | "always";
    brightness: number; // 0-100
    autoDim: boolean;
  };
  music: {
    isPlaying: boolean;
    trackTitle: string;
  };
  navigation: {
    ridingMode: boolean;
    nextTurn: string; // e.g., "Turn left in 200m"
    eta: string; // e.g., "15 min"
    currentSpeed: number; // km/h or mph
    distanceRemaining: string; // e.g., "5 km"
    theme: "light" | "dark";
  };
  theme: "light" | "dark";
  widgets: string[]; // e.g., ["time-digital", "weather-icon"]
  backgroundImage?: string; // New property for custom background image
  weather: { // New weather property
    condition: "sunny" | "cloudy" | "rainy" | "snowy";
    temperature: number; // in Celsius
  };
  // Add more device-specific states as needed
}

const initialDeviceState: DeviceState = {
  isConnected: false,
  battery: 0,
  aod: {
    enabled: true,
    timeout: "30s",
    brightness: 70,
    autoDim: true,
  },
  music: {
    isPlaying: false,
    trackTitle: "No Music Playing",
  },
  navigation: {
    ridingMode: false,
    nextTurn: "Start navigation",
    eta: "--",
    currentSpeed: 0,
    distanceRemaining: "--",
    theme: "dark",
  },
  theme: "dark",
  widgets: ["time-digital", "battery-status"],
  backgroundImage: undefined, // Initialize as undefined
  weather: { // Initial weather state
    condition: "sunny",
    temperature: 25,
  },
};

let mockPhysicalDeviceState: DeviceState = { ...initialDeviceState };
let mockAppPreviewState: DeviceState = { ...initialDeviceState };

const listeners = new Set<(state: DeviceState) => void>();

const notifyListeners = () => {
  listeners.forEach((listener) => listener(mockPhysicalDeviceState));
};

export const bleService = {
  connect: async (): Promise<boolean> => {
    toast.loading("Connecting to device...");
    return new Promise((resolve) => {
      setTimeout(() => {
        mockPhysicalDeviceState = { ...mockPhysicalDeviceState, isConnected: true, battery: 85 };
        mockAppPreviewState = { ...mockAppPreviewState, isConnected: true, battery: 85 };
        notifyListeners();
        toast.success("Device connected!");
        resolve(true);
      }, 2000);
    });
  },

  disconnect: async (): Promise<boolean> => {
    toast.loading("Disconnecting from device...");
    return new Promise((resolve) => {
      setTimeout(() => {
        mockPhysicalDeviceState = { ...mockPhysicalDeviceState, isConnected: false, battery: 0 };
        mockAppPreviewState = { ...mockAppPreviewState, isConnected: false, battery: 0 };
        notifyListeners();
        toast.info("Device disconnected.");
        resolve(true);
      }, 1500);
    });
  },

  getPhysicalDeviceState: (): DeviceState => {
    return { ...mockPhysicalDeviceState };
  },

  // This function simulates writing a new configuration to the physical device
  writeConfigToDevice: async (config: Partial<DeviceState>): Promise<boolean> => {
    if (!mockPhysicalDeviceState.isConnected) {
      toast.error("Device not connected. Cannot apply changes.");
      return false;
    }
    toast.loading("Applying changes to device...");
    return new Promise((resolve) => {
      setTimeout(() => {
        mockPhysicalDeviceState = { ...mockPhysicalDeviceState, ...config };
        notifyListeners();
        toast.success("Changes applied to device!");
        resolve(true);
      }, 2500);
    });
  },

  // This function simulates a device button press
  simulateDeviceButtonPress: (button: "play_pause" | "next" | "prev"): void => {
    if (!mockPhysicalDeviceState.isConnected) {
      toast.error("Device not connected. Cannot simulate button press.");
      return;
    }
    toast.info(`Device button '${button}' pressed.`);
    // Simulate state change based on button press
    if (button === "play_pause") {
      mockPhysicalDeviceState.music.isPlaying = !mockPhysicalDeviceState.music.isPlaying;
      mockAppPreviewState.music.isPlaying = mockPhysicalDeviceState.music.isPlaying;
    }
    notifyListeners();
  },

  // For real-time updates from device (e.g., battery changes, button presses)
  subscribeToDeviceUpdates: (callback: (state: DeviceState) => void) => {
    listeners.add(callback);
    return () => listeners.delete(callback);
  },

  // Initial state for the app's preview
  getAppPreviewState: (): DeviceState => {
    return { ...mockAppPreviewState };
  },

  // Update the app's preview state (without sending to device yet)
  updateAppPreviewState: (newState: Partial<DeviceState>): void => {
    mockAppPreviewState = { ...mockAppPreviewState, ...newState };
    // No need to notify physical device listeners here, as this is only for app preview
  },
};