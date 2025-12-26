import { Toaster } from "@/components/ui/toaster";
import { Toaster as Sonner } from "@/components/ui/sonner";
import { TooltipProvider } from "@/components/ui/tooltip";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { BrowserRouter, Routes, Route } from "react-router-dom";
import Dashboard from "./pages/Dashboard"; // Changed from Index
import NotFound from "./pages/NotFound";
import { DeviceProvider } from "./context/DeviceContext"; // Import DeviceProvider
import AODSettings from "./pages/AODSettings";
import MusicControl from "./pages/MusicControl";
import Navigation from "./pages/Navigation";
import ThemesWidgets from "./pages/ThemesWidgets";

const queryClient = new QueryClient();

const App = () => (
  <QueryClientProvider client={queryClient}>
    <TooltipProvider>
      <Toaster />
      <Sonner />
      <BrowserRouter>
        <DeviceProvider> {/* Wrap the app with DeviceProvider */}
          <Routes>
            <Route path="/" element={<Dashboard />} />
            <Route path="/aod-settings" element={<AODSettings />} />
            <Route path="/music-control" element={<MusicControl />} />
            <Route path="/navigation" element={<Navigation />} />
            <Route path="/themes-widgets" element={<ThemesWidgets />} />
            {/* ADD ALL CUSTOM ROUTES ABOVE THE CATCH-ALL "*" ROUTE */}
            <Route path="*" element={<NotFound />} />
          </Routes>
        </DeviceProvider>
      </BrowserRouter>
    </TooltipProvider>
  </QueryClientProvider>
);

export default App;