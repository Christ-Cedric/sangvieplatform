import React, { useState, useEffect } from "react";
import { HospitalLayout } from "../../components/layouts";
import { Typography, Badge, Button } from "../../components/ui";
import { MapPin, Navigation, Droplet, Search, Phone } from "lucide-react";
import { MapContainer, TileLayer, Marker, useMap, Popup } from "react-leaflet";
import L from "leaflet";
import { useTranslation } from "../../i18n";
import "leaflet/dist/leaflet.css";

const NEARBY_DONORS = [
  {
    id: 1,
    name: "Marie K.",
    bloodType: "O+",
    distance: "1.2 km",
    lastDonation: "Il y a 3 mois",
    available: true,
    phone: "+226 70 00 00 01",
    lat: 12.3754,
    lng: -1.5227
  },
  {
    id: 2,
    name: "Jean D.",
    bloodType: "A+",
    distance: "2.5 km",
    lastDonation: "Il y a 4 mois",
    available: true,
    phone: "+226 70 00 00 02",
    lat: 12.3810,
    lng: -1.5110
  },
  {
    id: 3,
    name: "Pierre S.",
    bloodType: "B+",
    distance: "3.1 km",
    lastDonation: "Il y a 6 mois",
    available: false,
    phone: "+226 70 00 00 03",
    lat: 12.3680,
    lng: -1.5300
  },
  {
    id: 4,
    name: "Anne T.",
    bloodType: "AB-",
    distance: "4.0 km",
    lastDonation: "Il y a 2 mois",
    available: true,
    phone: "+226 70 00 00 04",
    lat: 12.3550,
    lng: -1.5050
  },
  {
    id: 5,
    name: "Paul R.",
    bloodType: "O-",
    distance: "5.2 km",
    lastDonation: "Il y a 5 mois",
    available: true,
    phone: "+226 70 00 00 05",
    lat: 12.3900,
    lng: -1.4900
  },
];

const createDonorIcon = (available: boolean) => {
  const color = available ? "#CC0000" : "#888888";
  return L.divIcon({
    className: "custom-leaflet-icon",
    html: `<div style="width: 36px; height: 36px; border-radius: 50%; background-color: ${color}; display: flex; align-items: center; justify-content: center; box-shadow: 0 4px 12px rgba(0,0,0,0.3); border: 2px solid white;">
             <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 22a7 7 0 0 0 7-7c0-2-1-3.9-3-5.5s-3.5-4-4-6.5c-.5 2.5-2 4.9-4 6.5C6 11.1 5 13 5 15a7 7 0 0 0 7 7z"></path></svg>
           </div>`,
    iconSize: [36, 36],
    iconAnchor: [18, 36],
    popupAnchor: [0, -36]
  });
};

const hospitalIcon = L.divIcon({
  className: "hospital-leaflet-icon",
  html: `<div style="width: 30px; height: 30px; border-radius: 50%; background-color: #1A7A3F; border: 3px solid white; box-shadow: 0 4px 10px rgba(0,0,0,0.3); display: flex; align-items: center; justify-content: center;">
             <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"></path><polyline points="9 22 9 12 15 12 15 22"></polyline></svg>
         </div>`,
  iconSize: [30, 30],
  iconAnchor: [15, 30]
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

export function HospitalMap() {
  const { t } = useTranslation();
  const [selectedDonor, setSelectedDonor] = useState<number | null>(null);
  const [searchQuery, setSearchQuery] = useState("");
  const [filterBloodType, setFilterBloodType] = useState<string | null>(null);
  const [hospitalLocation, setHospitalLocation] = useState<{lat: number, lng: number} | null>(null);
  const [mapCenter, setMapCenter] = useState<{lat: number, lng: number}>({ lat: 12.3714, lng: -1.5197 }); // Ouaga
  const [mapZoom, setMapZoom] = useState(13);

  useEffect(() => {
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(
        (pos) => {
          const loc = { lat: pos.coords.latitude, lng: pos.coords.longitude };
          setHospitalLocation(loc);
          setMapCenter(loc);
          setMapZoom(14);
        },
        (err) => console.log("Geolocation error", err),
        { enableHighAccuracy: true }
      );
    }
  }, []);

  const locateMe = () => {
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(
        (pos) => {
          const loc = { lat: pos.coords.latitude, lng: pos.coords.longitude };
          setHospitalLocation(loc);
          setMapCenter(loc);
          setMapZoom(15);
        }
      );
    }
  };

  const handleDonorSelect = (id: number, lat?: number, lng?: number) => {
    setSelectedDonor(id);
    if (lat && lng) {
      setMapCenter({ lat, lng });
      setMapZoom(16);
    }
  };

  const filteredDonors = NEARBY_DONORS.filter((donor) => {
    const matchesSearch = donor.name.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesBloodType = filterBloodType ? donor.bloodType === filterBloodType : true;
    return matchesSearch && matchesBloodType;
  });

  return (
    <HospitalLayout>
      <div className="flex flex-col h-[calc(100vh-180px)] lg:h-[calc(100vh-120px)]">
        {/* Header */}
        <div className="mb-4">
          <Typography.H1 className="text-[24px] md:text-[32px] mb-2">{t("map.donor.title")}</Typography.H1>
          <Typography.Body className="text-[#888888]">
            {t("map.donor.sub")}
          </Typography.Body>
        </div>

        {/* Search and Filters */}
        <div className="flex flex-col md:flex-row gap-3 mb-4">
          <div className="relative flex-1">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-[#888888]" />
            <input
              type="text"
              placeholder={t("map.donor.search")}
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full pl-10 pr-4 py-3 rounded-lg border border-[#E0E0E0] focus:outline-none focus:border-[#CC0000] focus:ring-4 focus:ring-[#CC0000]/15 font-['DM_Sans'] text-[#111111] placeholder:text-[#888888]"
            />
          </div>
          <div className="flex gap-2 flex-wrap">
            {["O+", "A+", "B+", "AB+", "O-", "A-", "B-", "AB-"].map((type) => (
              <button
                key={type}
                onClick={() => setFilterBloodType(filterBloodType === type ? null : type)}
                className={`px-3 py-2 rounded-lg border font-['DM_Sans'] text-sm font-medium transition-all ${
                  filterBloodType === type
                    ? 'bg-[#CC0000] text-white border-[#CC0000]'
                    : 'bg-white text-[#111111] border-[#E0E0E0] hover:border-[#CC0000]/50'
                }`}
              >
                {type}
              </button>
            ))}
          </div>
        </div>

        {/* Map and List Container */}
        <div className="flex-1 flex flex-col lg:flex-row gap-4 min-h-0">
          {/* Map Area */}
          <div className="relative flex-1 bg-gradient-to-br from-[#E8F5E9] to-[#F5F5F5] rounded-xl overflow-hidden min-h-[300px] lg:min-h-0 z-0 border border-[#EBEBEB]">
            <MapContainer 
              center={[12.3714, -1.5197]} 
              zoom={13} 
              style={{ width: "100%", height: "100%" }}
              zoomControl={true}
            >
              <TileLayer
                attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
                url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
              />
              <RecenterController lat={mapCenter.lat} lng={mapCenter.lng} zoom={mapZoom} />
              
              {hospitalLocation && (
                <Marker position={[hospitalLocation.lat, hospitalLocation.lng]} icon={hospitalIcon}>
                  <Popup>{t("map.hospital.hospital_pos")}</Popup>
                </Marker>
              )}

              {filteredDonors.map((donor) => (
                <Marker 
                  key={donor.id} 
                  position={[donor.lat, donor.lng]} 
                  icon={createDonorIcon(donor.available)}
                  eventHandlers={{ click: () => handleDonorSelect(donor.id, donor.lat, donor.lng) }}
                >
                  <Popup>
                    <div className="text-center font-['DM_Sans']">
                      <h3 className="font-bold text-[#111111]">{donor.name}</h3>
                      <p className="text-sm text-[#888888]">{donor.bloodType} • {donor.distance}</p>
                      {donor.available && (
                        <a href="/messages" className="inline-block mt-2 px-3 py-1 bg-[#CC0000] text-white rounded-md text-xs font-semibold no-underline">
                          {t("map.hospital.contact")}
                        </a>
                      )}
                    </div>
                  </Popup>
                </Marker>
              ))}
            </MapContainer>

            {/* My Location Button */}
            <button 
              onClick={locateMe}
              className="absolute top-4 right-4 z-[400] bg-white p-3 rounded-full shadow-md hover:shadow-lg hover:bg-gray-50 transition-all border border-gray-100"
            >
              <Navigation className="w-5 h-5 text-[#CC0000]" />
            </button>

            {/* Map Legend */}
            <div className="absolute bottom-4 left-4 z-[400] bg-white/95 backdrop-blur-sm rounded-lg p-3 shadow-md border border-gray-100">
              <div className="flex items-center gap-4 text-xs font-['DM_Sans'] font-medium">
                <div className="flex items-center gap-1.5">
                  <div className="w-3 h-3 rounded-full bg-[#CC0000]"></div>
                  <span className="text-[#333333]">{t("map.status.available")}</span>
                </div>
                <div className="flex items-center gap-1.5">
                  <div className="w-3 h-3 rounded-full bg-[#888888]"></div>
                  <span className="text-[#333333]">{t("map.status.unavailable")}</span>
                </div>
              </div>
            </div>
          </div>

          {/* Donors List */}
          <div className="w-full lg:w-[400px] bg-white rounded-xl border border-[#E0E0E0] shadow-sm overflow-hidden flex flex-col z-10 relative">
            <div className="p-4 border-b border-[#E0E0E0] flex justify-between items-center">
              <Typography.H2 className="text-[18px]">
                {t("map.donor.nearby", { count: filteredDonors.length.toString() })}
              </Typography.H2>
            </div>
            <div className="flex-1 overflow-y-auto">
              {filteredDonors.map((donor) => (
                <div
                  key={donor.id}
                  onClick={() => handleDonorSelect(donor.id, donor.lat, donor.lng)}
                  className={`p-4 border-b border-[#E0E0E0] hover:bg-[#F9F9F9] cursor-pointer transition-colors ${
                    selectedDonor === donor.id ? 'bg-[#CC0000]/5 border-l-4 border-l-[#CC0000]' : ''
                  }`}
                >
                  <div className="flex justify-between items-start mb-2">
                    <div className="flex items-center gap-3">
                      <div className="w-10 h-10 rounded-full bg-[#CC0000]/10 flex items-center justify-center font-['DM_Sans'] font-semibold text-[#CC0000]">
                        {donor.bloodType}
                      </div>
                      <div>
                        <h3 className="font-['DM_Sans'] font-semibold text-[#111111]">
                          {donor.name}
                        </h3>
                        <div className="flex items-center text-[#888888] text-sm">
                          <MapPin className="w-3 h-3 mr-1" />
                          {donor.distance}
                        </div>
                      </div>
                    </div>
                    <Badge variant={donor.available ? "active" : "inactive"}>
                      {donor.available ? t("map.status.available") : t("map.status.unavailable")}
                    </Badge>
                  </div>
                                    <div className="flex justify-between items-center mt-3">
                    <Typography.Small className="text-[#888888]">
                      {t("map.donor.last_donation", { time: donor.lastDonation })}
                    </Typography.Small>
                    {selectedDonor === donor.id && donor.available && (
                      <Button size="sm" className="bg-[#CC0000]" onClick={() => window.location.href = '/messages'}>
                        {t("map.hospital.contact")}
                      </Button>
                    )}
                  </div>
                </div>
              ))}
                            {filteredDonors.length === 0 && (
                <div className="p-8 text-center text-[#888888]">
                  <Typography.Body>
                    {t("map.donor.empty")}
                  </Typography.Body>
                </div>
              )}
            </div>
          </div>
        </div>
      </div>
    </HospitalLayout>
  );
}

