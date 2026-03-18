import React, { useState, useEffect } from "react";
import { DonorLayout } from "../../components/layouts";
import { Card, Badge, Button } from "../../components/ui";
import { MapPin, Filter, X, CheckCircle2, Droplet, Clock, AlertTriangle, ChevronRight, Loader2 } from "lucide-react";
import { motion, AnimatePresence } from "motion/react";
import { getRequestsApi, updateDonorStatusApi, respondToRequestApi, type BloodRequest } from "../../api";
import { useAuth } from "../../AuthContext";
import { useTranslation } from "../../i18n";

const getUrgencyConfig = (t: any) => ({
  critique: {
    label: t("donor.home.urgency.vital"),
    badgeVariant: "critical" as const,
    dot: "bg-[#CC0000] animate-pulse",
    cardBorder: "border-l-4 border-l-[#CC0000]",
    icon: AlertTriangle,
    iconColor: "text-[#CC0000]",
    groupBg: "bg-[#CC0000]",
  },
  urgent: {
    label: t("dashboard.urgency.urgent"),
    badgeVariant: "moderate" as const,
    dot: "bg-[#D4720B]",
    cardBorder: "border-l-4 border-l-[#D4720B]",
    icon: Clock,
    iconColor: "text-[#D4720B]",
    groupBg: "bg-[#D4720B]",
  },
  normal: {
    label: t("dashboard.urgency.normal"),
    badgeVariant: "active" as const,
    dot: "bg-[#1A7A3F]",
    cardBorder: "border-l-4 border-l-[#1A7A3F]",
    icon: Clock,
    iconColor: "text-[#1A7A3F]",
    groupBg: "bg-[#1A7A3F]",
  },
});

/** Formate la date relative (simplifié) */
function formatTime(dateStr: string, t: any) {
  const date = new Date(dateStr);
  const now = new Date();
  const diffMin = Math.floor((now.getTime() - date.getTime()) / 60000);
  if (diffMin < 1) return t("donor.home.time.now");
  if (diffMin < 60) return t("dashboard.time.ago", { count: diffMin.toString(), unit: t("dashboard.time.min") });
  const diffHours = Math.floor(diffMin / 60);
  if (diffHours < 24) return t("dashboard.time.ago", { count: diffHours.toString(), unit: t("dashboard.time.hour") });
  return date.toLocaleDateString();
}

export function DonorHome() {
  const { user } = useAuth();
  const { t } = useTranslation();
  const [isActive, setIsActive] = useState(true); // À récupérer idéalement via un fetch profile
  const [requests, setRequests] = useState<BloodRequest[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [isResponding, setIsResponding] = useState(false);
  const [error, setError] = useState("");
  const [selectedRequest, setSelectedRequest] = useState<BloodRequest | null>(null);
  const [successMessage, setSuccessMessage] = useState("");
  const [message, setMessage] = useState("");

  useEffect(() => {
    fetchRequests();
  }, []);

  const fetchRequests = async () => {
    setIsLoading(true);
    setError("");
    try {
      const data = await getRequestsApi();
      setRequests(data);
    } catch (err: any) {
      setError(t("donor.home.feed.error"));
    } finally {
      setIsLoading(false);
    }
  };

  const handleRespond = async () => {
    if (!selectedRequest || isResponding) return;
    setIsResponding(true);
    try {
      await respondToRequestApi(selectedRequest._id, message);
      setSuccessMessage(t("donor.home.modal.success"));
      setTimeout(() => setSuccessMessage(""), 5000);
      setSelectedRequest(null);
      setMessage("");
    } catch (err: any) {
      alert(err.message ?? t("donor.home.feed.error_respond"));
    } finally {
      setIsResponding(false);
    }
  };

  const toggleStatus = async () => {
    const nextStatus = !isActive;
    try {
      await updateDonorStatusApi(nextStatus ? "actif" : "inactif");
      setIsActive(nextStatus);
    } catch (err) {
      // Revert if error
      console.error("Failed to update status");
    }
  };

  return (
    <DonorLayout>
      <div className="p-4 md:p-6 max-w-2xl mx-auto">

        {/* ── Statut Donneur Card ─────────────────────── */}
        <motion.div
          initial={{ opacity: 0, y: -10 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.4 }}
          className={`rounded-2xl p-5 mb-6 flex items-center justify-between transition-all duration-300 ${
            isActive
              ? "bg-gradient-to-r from-[#E8F5EE] to-[#F0FFF4] border border-[#1A7A3F]/20"
              : "bg-[#F5F5F5] border border-[#E0E0E0]"
          }`}
        >
          <div className="flex items-center gap-3">
            <div className={`p-2.5 rounded-xl ${isActive ? "bg-[#1A7A3F]/10" : "bg-[#E0E0E0]"}`}>
              <Droplet className={`w-5 h-5 ${isActive ? "text-[#1A7A3F] fill-[#1A7A3F]/30" : "text-[#AAAAAA]"}`} />
            </div>
            <div>
              <p className="text-[14px] font-bold text-[#111111]" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                {t("donor.home.status.title")}
              </p>
              <p className="text-[12px] mt-0.5" style={{ fontFamily: "'DM Sans', sans-serif", color: isActive ? "#1A7A3F" : "#AAAAAA" }}>
                {isActive ? t("donor.home.status.active") : t("donor.home.status.inactive")}
              </p>
            </div>
          </div>
          {/* Toggle */}
          <button
            onClick={toggleStatus}
            className={`relative w-14 h-7 rounded-full transition-all duration-300 focus:outline-none focus:ring-2 focus:ring-offset-2 ${
              isActive ? "bg-[#1A7A3F] focus:ring-[#1A7A3F]/40" : "bg-[#D0D0D0] focus:ring-[#D0D0D0]"
            }`}
          >
            <motion.div
              layout
              transition={{ type: "spring", stiffness: 500, damping: 30 }}
              className="absolute top-0.5 w-6 h-6 rounded-full bg-white shadow-md"
              style={{ left: isActive ? "calc(100% - 26px)" : "2px" }}
            />
          </button>
        </motion.div>

        {/* ── Header section ──────────────────────────── */}
        <div className="flex items-center justify-between mb-5">
          <div>
            <h2 className="text-[20px] font-bold text-[#0A0A0A]" style={{ fontFamily: "'DM Sans', sans-serif" }}>
              {t("donor.home.feed.title")}
            </h2>
            <p className="text-[12px] text-[#AAAAAA] mt-0.5" style={{ fontFamily: "'DM Sans', sans-serif" }}>
              {isLoading ? t("donor.home.feed.searching") : t("donor.home.feed.count", { count: requests.length.toString() })}
            </p>
          </div>
          <button onClick={fetchRequests} className="flex items-center gap-1.5 text-[13px] font-semibold text-[#555555] bg-white border border-[#E0E0E0] px-3 py-1.5 rounded-xl hover:border-[#CC0000]/40 hover:text-[#CC0000] transition-all">
            <Loader2 className={`w-3.5 h-3.5 ${isLoading ? 'animate-spin' : ''}`} />
            {t("donor.home.feed.refresh")}
          </button>
        </div>

        {/* ── Feed List ───────────────────────────────── */}
        <div className="flex flex-col gap-3 mb-24 md:mb-8">
          {isLoading && (
             <div className="flex flex-col items-center justify-center py-20 gap-4">
               <Loader2 className="w-8 h-8 text-[#CC0000] animate-spin" />
              <p className="text-[#888888] text-sm">{t("donor.home.feed.loading")}</p>
            </div>
          )}

          {!isLoading && error && (
            <div className="text-center py-10">
              <p className="text-[#CC0000] mb-4">{error}</p>
              <Button variant="secondary" onClick={fetchRequests}>{t("donor.home.feed.retry")}</Button>
            </div>
          )}

          {!isLoading && !error && requests.length === 0 && (
            <div className="text-center py-20 bg-white rounded-3xl border border-dashed border-[#E0E0E0]">
              <CheckCircle2 className="w-12 h-12 text-[#1A7A3F] mx-auto mb-4 opacity-20" />
              <p className="text-[#888888] font-medium">{t("donor.home.feed.empty")}</p>
            </div>
          )}

          {!isLoading && requests.map((demande, idx) => {
            const config = getUrgencyConfig(t)[demande.niveauUrgence] || getUrgencyConfig(t).normal;
            return (
              <motion.div
                key={demande._id}
                initial={{ opacity: 0, y: 16 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: idx * 0.08, duration: 0.4 }}
              >
                <div
                  onClick={() => setSelectedRequest(demande)}
                  className={`bg-white rounded-2xl border border-[#EBEBEB] overflow-hidden cursor-pointer hover:shadow-[0_6px_24_rgba(0,0,0,0.10)] hover:-translate-y-0.5 transition-all duration-200 ${config.cardBorder}`}
                >
                  {/* Card header */}
                  <div className="p-4 pb-3">
                    <div className="flex items-center justify-between mb-3">
                      <div className="flex items-center gap-3">
                        <div className={`w-12 h-12 rounded-xl ${config.groupBg} flex items-center justify-center shadow-sm`}>
                          <span className="text-white font-bold text-[15px]" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                            {demande.groupeSanguin}
                          </span>
                        </div>
                        <div>
                          <p className="font-bold text-[14px] text-[#0A0A0A]" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                            {demande.hospitalId?.nom || t("donor.home.feed.unknown_hospital")}
                          </p>
                          <div className="flex items-center gap-1 mt-0.5">
                            <MapPin className="w-3 h-3 text-[#AAAAAA]" />
                            <span className="text-[11px] text-[#AAAAAA]" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                              {demande.hospitalId?.localisation || demande.hospitalId?.region || t("hospital.verified_desc")}
                            </span>
                          </div>
                        </div>
                      </div>
                      <div className="flex flex-col items-end gap-1.5">
                        <Badge variant={config.badgeVariant}>
                          <span className={`inline-block w-1.5 h-1.5 rounded-full mr-1 ${config.dot}`} />
                          {config.label}
                        </Badge>
                        <span className="text-[11px] text-[#BBBBBB]" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                          {formatTime(demande.createdAt, t)}
                        </span>
                      </div>
                    </div>

                    <p className="text-[13px] text-[#666666] leading-relaxed mb-3" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                      {demande.description || t("donor.home.feed.no_description")}
                    </p>
                  </div>

                  {/* Card footer */}
                  <div className="border-t border-[#F0F0F0] px-4 py-3 flex items-center justify-between bg-[#FAFAFA]">
                    <span className="text-[12px] font-semibold text-[#AAAAAA]" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                      {t("donor.home.feed.pockets_required", { count: demande.quantitePoches.toString(), s: demande.quantitePoches > 1 ? "s" : "", plural: demande.quantitePoches > 1 ? "s" : "" })}
                    </span>
                    <button
                      onClick={(e) => { e.stopPropagation(); setSelectedRequest(demande); }}
                      className="flex items-center gap-1 text-[13px] font-bold text-[#CC0000] hover:text-[#990000] transition-colors"
                      style={{ fontFamily: "'DM Sans', sans-serif" }}
                    >
                      {t("donor.home.feed.respond")}
                      <ChevronRight className="w-4 h-4" />
                    </button>
                  </div>
                </div>
              </motion.div>
            );
          })}
        </div>

        {/* ── Modal Détail ─────────────────────────────── */}
        <AnimatePresence>
          {selectedRequest && (
            <div className="fixed inset-0 z-[100] flex items-end md:items-center justify-center p-0 md:p-4">
              {/* Backdrop */}
              <motion.div
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                exit={{ opacity: 0 }}
                className="absolute inset-0 bg-black/50 backdrop-blur-sm"
                onClick={() => setSelectedRequest(null)}
              />
              {/* Sheet */}
              <motion.div
                initial={{ y: "100%" }}
                animate={{ y: 0 }}
                exit={{ y: "100%" }}
                transition={{ type: "spring", damping: 28, stiffness: 220 }}
                className="relative z-10 bg-white w-full max-w-lg rounded-t-3xl md:rounded-3xl shadow-2xl flex flex-col max-h-[92vh] overflow-hidden"
              >
                {/* Handle */}
                <div className="flex justify-center pt-3 pb-1">
                  <div className="w-10 h-1 rounded-full bg-[#E0E0E0]" />
                </div>

                {/* Close */}
                <button
                  onClick={() => setSelectedRequest(null)}
                  className="absolute top-4 right-4 p-2 rounded-xl bg-[#F5F5F5] hover:bg-[#E8E8E8] transition-colors"
                >
                  <X className="w-4 h-4 text-[#555555]" />
                </button>

                <div className="overflow-y-auto flex-1 p-6">
                  {/* Hero group */}
                  <div className="flex flex-col items-center mb-6 text-center">
                    <div
                      className={`w-20 h-20 rounded-2xl ${getUrgencyConfig(t)[selectedRequest.niveauUrgence]?.groupBg ?? "bg-[#CC0000]"} flex items-center justify-center mb-3 shadow-lg`}
                    >
                      <span className="text-white font-bold text-3xl" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                        {selectedRequest.groupeSanguin}
                      </span>
                    </div>
                    <Badge variant={getUrgencyConfig(t)[selectedRequest.niveauUrgence]?.badgeVariant ?? "critical"} className="mb-2">
                      {getUrgencyConfig(t)[selectedRequest.niveauUrgence]?.label || t("dashboard.urgency.critical")}
                    </Badge>
                    <h2 className="text-[20px] font-bold text-[#0A0A0A]" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                      {selectedRequest.hospitalId?.nom}
                    </h2>
                    <div className="flex items-center gap-1 mt-1 text-[#888888]">
                      <MapPin className="w-4 h-4" />
                      <span className="text-[13px]" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                        {selectedRequest.hospitalId?.region} · {selectedRequest.hospitalId?.localisation}
                      </span>
                    </div>
                  </div>

                  {/* Description */}
                  <div className="bg-[#F7F7F8] rounded-2xl p-4 mb-4">
                    <p className="text-[12px] font-semibold text-[#AAAAAA] uppercase tracking-wide mb-1.5" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                      {t("donor.home.modal.description")}
                    </p>
                    <p className="text-[14px] text-[#333333] leading-relaxed" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                      {selectedRequest.description || t("donor.home.modal.no_description")}
                    </p>
                  </div>

                  {/* Warning */}
                  <div className="bg-[#FFF8F0] border border-[#D4720B]/25 rounded-2xl p-4 mb-6 flex items-start gap-3">
                    <CheckCircle2 className="w-4.5 h-4.5 text-[#D4720B] mt-0.5 flex-shrink-0" style={{ width: "18px", height: "18px" }} />
                    <p className="text-[13px] text-[#D4720B] leading-relaxed" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                      {t("donor.home.modal.warning")}
                    </p>
                  </div>

                  {/* Message optionnel */}
                  <div className="mb-6">
                    <label className="block text-[11px] font-bold text-[#AAAAAA] uppercase tracking-wider mb-2">
                       {t("donor.home.modal.message_label")}
                    </label>
                    <textarea
                      value={message}
                      onChange={(e) => setMessage(e.target.value)}
                      placeholder={t("donor.home.modal.message_placeholder")}
                      className="w-full h-24 bg-[#F7F7F8] border border-[#EBEBEB] rounded-2xl p-4 text-sm focus:outline-none focus:border-[#CC0000] transition-colors resize-none"
                    />
                  </div>
                </div>

                {/* Footer actions */}
                <div className="p-4 border-t border-[#F0F0F0] flex gap-3">
                  <Button variant="secondary" className="flex-1" onClick={() => setSelectedRequest(null)} disabled={isResponding}>
                    {t("donor.home.modal.close")}
                  </Button>
                  <Button 
                    className="flex-1 bg-[#CC0000]" 
                    onClick={handleRespond}
                    disabled={isResponding}
                  >
                    {isResponding ? <Loader2 className="w-4 h-4 animate-spin" /> : t("donor.home.modal.submit")}
                  </Button>
                </div>
              </motion.div>
            </div>
          )}
        </AnimatePresence>

        {/* Success Toast */}
        <AnimatePresence>
          {successMessage && (
            <motion.div
              initial={{ opacity: 0, y: 50 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, scale: 0.95 }}
              className="fixed bottom-24 left-1/2 -translate-x-1/2 z-[200] w-[90%] max-w-sm"
            >
              <div className="bg-[#1A7A3F] text-white p-4 rounded-2xl shadow-xl flex items-center gap-3">
                <CheckCircle2 className="w-6 h-6 flex-shrink-0" />
                <p className="text-[13px] font-medium leading-tight">
                  {successMessage}
                </p>
              </div>
            </motion.div>
          )}
        </AnimatePresence>
      </div>
    </DonorLayout>
  );
}
