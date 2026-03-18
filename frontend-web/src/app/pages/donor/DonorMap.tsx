import React, { useState, useEffect, useRef } from "react";
import { DonorLayout } from "../../components/layouts";
import { Badge, Button } from "../../components/ui";
import { MapPin, Navigation2, Phone, ChevronRight, X, AlertTriangle } from "lucide-react";
import { useTranslation } from "../../i18n";
import { motion, AnimatePresence } from "motion/react";
import { MapContainer, TileLayer, Marker, useMap } from "react-leaflet";
import L from "leaflet";
import "leaflet/dist/leaflet.css";

const HOSPITALS = [
  { id: 1, name: "CHU Yalgado Ouédraogo", distance: "2.5 km", urgentNeeds: ["O+", "A-"], urgency: "critical", phone: "+226 25 30 66 44", address: "Secteur 4, Ouagadougou", lat: 12.3941, lng: -1.5034 },
  { id: 2, name: "Clinique Sandof", distance: "5.1 km", urgentNeeds: ["B+"], urgency: "moderate", phone: "+226 25 36 00 10", address: "Zone du Bois, Ouagadougou", lat: 12.3812, lng: -1.4912 },
  { id: 3, name: "CMA Pissy", distance: "7.8 km", urgentNeeds: ["O+", "AB-"], urgency: "critical", phone: "+226 25 34 22 11", address: "Pissy, Ouagadougou", lat: 12.3615, lng: -1.5451 },
];

const URGENCY_COLOR = { critical: "#CC0000", moderate: "#D4720B" } as const;

// Custom Icons
const createIcon = (color: string) => {
  return L.divIcon({
    className: "custom-leaflet-icon",
    html: `<div style="width: 40px; height: 40px; border-radius: 50%; background-color: ${color}; display: flex; align-items: center; justify-content: center; box-shadow: 0 4px 16px rgba(0,0,0,0.25); border: 2px solid white;">
             <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0Z"></path><circle cx="12" cy="10" r="3"></circle></svg>
           </div>`,
    iconSize: [40, 40],
    iconAnchor: [20, 40]
  });
};

const userIcon = L.divIcon({
  className: "user-leaflet-icon",
  html: `<div style="width: 24px; height: 24px; border-radius: 50%; background-color: #1A7A3F; border: 4px solid white; box-shadow: 0 4px 10px rgba(0,0,0,0.3);"></div>`,
  iconSize: [24, 24],
  iconAnchor: [12, 12]
});

// Component to handle map center changes
function RecenterController({ lat, lng, zoom }: { lat?: number, lng?: number, zoom?: number }) {
  const map = useMap();
  useEffect(() => {
    if (lat && lng) {
      map.flyTo([lat, lng], zoom || map.getZoom(), { animate: true, duration: 1.5 });
    }
  }, [lat, lng, zoom, map]);
  return null;
}

export function DonorMap() {
  const { t } = useTranslation();
  const [selectedId, setSelectedId] = useState<number | null>(null);
  const selected = HOSPITALS.find((h) => h.id === selectedId) ?? null;
  const [userLocation, setUserLocation] = useState<{lat: number, lng: number} | null>(null);
  const [mapCenter, setMapCenter] = useState<{lat: number, lng: number}>({ lat: 12.3714, lng: -1.5197 }); // Ouaga
  const [mapZoom, setMapZoom] = useState(13);

  useEffect(() => {
    // Demande de permission et géolocalisation
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(
        (pos) => {
          const loc = { lat: pos.coords.latitude, lng: pos.coords.longitude };
          setUserLocation(loc);
          setMapCenter(loc);
          setMapZoom(14);
        },
        (err) => console.log("Geolocation error", err),
        { enableHighAccuracy: true }
      );
    }
  }, []);

  const handleHospitalSelect = (h: (typeof HOSPITALS)[0]) => {
    setSelectedId(h.id);
    setMapCenter({ lat: h.lat, lng: h.lng });
    setMapZoom(15);
  };

  const locateMe = () => {
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(
        (pos) => {
          const loc = { lat: pos.coords.latitude, lng: pos.coords.longitude };
          setUserLocation(loc);
          setMapCenter(loc);
          setMapZoom(15);
        }
      );
    }
  };

  const getDirections = () => {
    if (!selected) return;
    const url = `https://www.google.com/maps/dir/?api=1&destination=${selected.lat},${selected.lng}`;
    window.open(url, '_blank');
  };

  return (
    <DonorLayout>
      <div className="relative h-[calc(100vh-64px)] md:h-screen overflow-hidden">

        {/* ── Map ─────────────────────────── */}
        <div className="absolute inset-0 z-0">
          <MapContainer 
            center={[12.3714, -1.5197]} 
            zoom={13} 
            style={{ width: "100%", height: "100%" }}
            zoomControl={false}
          >
            <TileLayer
              attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
              url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
            />
            <RecenterController lat={mapCenter.lat} lng={mapCenter.lng} zoom={mapZoom} />
            
            {HOSPITALS.map((h) => (
              <Marker 
                key={h.id} 
                position={[h.lat, h.lng]} 
                icon={createIcon(URGENCY_COLOR[h.urgency as keyof typeof URGENCY_COLOR])}
                eventHandlers={{
                  click: () => handleHospitalSelect(h)
                }}
              />
            ))}
            
            {userLocation && (
              <Marker position={[userLocation.lat, userLocation.lng]} icon={userIcon} />
            )}
          </MapContainer>
        </div>

        {/* ── Locate me button ───────────────────────── */}
        <button 
          onClick={locateMe}
          className="absolute top-4 right-4 z-30 w-10 h-10 bg-white rounded-xl shadow-[0_2px_12px_rgba(0,0,0,0.15)] flex items-center justify-center hover:bg-[#F5F5F5] transition-colors"
        >
          <Navigation2 className="w-5 h-5 text-[#CC0000]" />
        </button>

        {/* ── Legend top-left ────────────────────────── */}
        <div className="absolute top-4 left-4 z-30 bg-white/90 backdrop-blur-sm rounded-xl p-3 shadow-[0_2px_12px_rgba(0,0,0,0.1)]">
          <p className="text-[11px] font-bold text-[#0A0A0A] mb-2 uppercase tracking-wide" style={{ fontFamily: "'DM Sans', sans-serif" }}>
            {t("map.hospital.nearby", { count: HOSPITALS.length.toString() })}
          </p>
          <div className="flex flex-col gap-1.5">
            <div className="flex items-center gap-1.5">
              <div className="w-3 h-3 rounded-full bg-[#CC0000]" />
              <span className="text-[10px] text-[#555555]" style={{ fontFamily: "'DM Sans', sans-serif" }}>{t("map.hospital.urgency_vital")}</span>
            </div>
            <div className="flex items-center gap-1.5">
              <div className="w-3 h-3 rounded-full bg-[#D4720B]" />
              <span className="text-[10px] text-[#555555]" style={{ fontFamily: "'DM Sans', sans-serif" }}>{t("map.hospital.urgency_moderate")}</span>
            </div>
            <div className="flex items-center gap-1.5">
              <div className="w-3 h-3 rounded-full bg-[#1A7A3F]" />
              <span className="text-[10px] text-[#555555]" style={{ fontFamily: "'DM Sans', sans-serif" }}>{t("map.hospital.your_position")}</span>
            </div>
          </div>
        </div>

        {/* ── Bottom hospital list ───────────────────── */}
        <div className="absolute bottom-0 left-0 right-0 z-20 pb-20 md:pb-0 pointer-events-none">
          {/* Gradient fade */}
          <div className="h-12 bg-gradient-to-t from-white to-transparent" />

          <div className="bg-white px-4 pt-0 pb-4 pointer-events-auto">
            {/* List */}
            <div className="max-w-2xl mx-auto space-y-2">
              {HOSPITALS.map((h) => (
                <button
                  key={h.id}
                  onClick={() => handleHospitalSelect(h)}
                  className={`w-full flex items-center gap-3 p-3.5 rounded-xl text-left transition-all border ${
                    selectedId === h.id
                      ? "border-[#CC0000]/30 bg-[#FFF0F0] shadow-sm"
                      : "border-[#EBEBEB] bg-white hover:border-[#DDDDDD]"
                  }`}
                >
                  {/* Blood group indicator */}
                  <div
                    className="w-11 h-11 rounded-xl flex flex-col items-center justify-center flex-shrink-0"
                    style={{ backgroundColor: `${URGENCY_COLOR[h.urgency as keyof typeof URGENCY_COLOR]}15` }}
                  >
                    {h.urgentNeeds.slice(0, 1).map((g) => (
                      <span
                        key={g}
                        className="text-[13px] font-bold"
                        style={{ color: URGENCY_COLOR[h.urgency as keyof typeof URGENCY_COLOR], fontFamily: "'DM Sans', sans-serif" }}
                      >
                        {g}
                      </span>
                    ))}
                    {h.urgentNeeds.length > 1 && (
                      <span className="text-[9px] text-[#AAAAAA]" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                        +{h.urgentNeeds.length - 1}
                      </span>
                    )}
                  </div>

                  {/* Info */}
                  <div className="flex-1 min-w-0">
                    <p className="text-[13px] font-bold text-[#0A0A0A] truncate" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                      {h.name}
                    </p>
                    <div className="flex items-center gap-2 mt-0.5">
                      <span className="text-[11px] text-[#AAAAAA]" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                        {h.distance}
                      </span>
                      <Badge variant={h.urgency as any} className="text-[10px] py-0">
                        {h.urgency === "critical" ? t("map.urgency.critical") : t("map.urgency.moderate")}
                      </Badge>
                    </div>
                  </div>

                  <ChevronRight className={`w-4 h-4 flex-shrink-0 transition-colors ${selectedId === h.id ? "text-[#CC0000]" : "text-[#DDDDDD]"}`} />
                </button>
              ))}
            </div>
          </div>
        </div>

        {/* ── Hospital detail sheet ──────────────────── */}
        <AnimatePresence>
          {selected && (
            <div className="absolute inset-0 z-[100] flex items-end justify-center md:items-center md:p-4 pointer-events-none">
              <motion.div
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                exit={{ opacity: 0 }}
                className="absolute inset-0 bg-black/40 backdrop-blur-sm pointer-events-auto"
                onClick={() => setSelectedId(null)}
              />
              <motion.div
                initial={{ y: "100%" }}
                animate={{ y: 0 }}
                exit={{ y: "100%" }}
                transition={{ type: "spring", damping: 28, stiffness: 220 }}
                className="relative z-10 bg-white w-full max-w-lg rounded-t-3xl md:rounded-3xl shadow-2xl overflow-hidden pointer-events-auto"
              >
                {/* Handle */}
                <div className="flex justify-center pt-3 md:hidden">
                  <div className="w-10 h-1 rounded-full bg-[#E0E0E0]" />
                </div>

                {/* Close */}
                <button
                  onClick={() => setSelectedId(null)}
                  className="absolute top-4 right-4 p-2 rounded-xl bg-[#F5F5F5] hover:bg-[#E8E8E8]"
                >
                  <X className="w-4 h-4 text-[#555555]" />
                </button>

                <div className="p-6">
                  {/* Header */}
                  <div className="flex items-start gap-4 mb-5">
                    <div
                      className="w-14 h-14 rounded-2xl flex items-center justify-center flex-shrink-0"
                      style={{ backgroundColor: `${URGENCY_COLOR[selected.urgency as keyof typeof URGENCY_COLOR]}15` }}
                    >
                      <MapPin className="w-6 h-6" style={{ color: URGENCY_COLOR[selected.urgency as keyof typeof URGENCY_COLOR] }} />
                    </div>
                    <div className="flex-1 min-w-0">
                      <h2 className="text-[17px] font-bold text-[#0A0A0A]" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                        {selected.name}
                      </h2>
                      <p className="text-[12px] text-[#AAAAAA] mt-0.5" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                        {selected.address} · {selected.distance}
                      </p>
                      <div className="flex items-center gap-2 mt-2">
                        {selected.urgentNeeds.map((g) => (
                          <span
                            key={g}
                            className="px-2 py-0.5 rounded-lg text-[12px] font-bold text-white"
                            style={{ backgroundColor: URGENCY_COLOR[selected.urgency as keyof typeof URGENCY_COLOR], fontFamily: "'DM Sans', sans-serif" }}
                          >
                            {g}
                          </span>
                        ))}
                        <Badge variant={selected.urgency as any}>
                          {selected.urgency === "critical" ? t("map.hospital.urgency_vital") : t("map.hospital.urgency_moderate")}
                        </Badge>
                      </div>
                    </div>
                  </div>

                  {/* Alert */}
                  {selected.urgency === "critical" && (
                    <div className="flex gap-2.5 bg-[#FFF0F0] border border-[#CC0000]/20 rounded-xl p-3.5 mb-5">
                      <AlertTriangle className="w-4 h-4 text-[#CC0000] flex-shrink-0 mt-0.5" />
                      <p className="text-[12px] text-[#CC0000] leading-relaxed" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                        {t("map.hospital.critical_alert")}
                      </p>
                    </div>
                  )}

                  {/* Actions */}
                  <div className="flex gap-3">
                    <Button onClick={getDirections} className="flex-1 flex items-center gap-2">
                      <Navigation2 className="w-4 h-4" />
                      {t("map.hospital.itinerary")}
                    </Button>
                    <button className="flex-1 flex items-center justify-center gap-2 py-2.5 rounded-xl border-2 border-[#EBEBEB] text-[14px] font-semibold text-[#333333] hover:border-[#CCCCCC] transition-all" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                      <Phone className="w-4 h-4" />
                      {t("map.hospital.call")}
                    </button>
                  </div>
                </div>
              </motion.div>
            </div>
          )}
        </AnimatePresence>
      </div>
    </DonorLayout>
  );
}
