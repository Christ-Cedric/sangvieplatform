import React, { useState, useEffect } from "react";
import { DonorLayout } from "../../components/layouts";
import { Badge } from "../../components/ui";
import { Calendar, MapPin, Award, Heart, Droplet, Loader2 } from "lucide-react";
import { motion } from "motion/react";
import { getMyDonationsApi } from "../../api";
import { useAuth } from "../../AuthContext";
import { useTranslation, useLanguage } from "../../i18n";

export function DonorHistory() {
  const { user } = useAuth();
  const { t } = useTranslation();
  const { language } = useLanguage();
  const [donations, setDonations] = useState<any[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    fetchDonations();
  }, []);

  const fetchDonations = async () => {
    setIsLoading(true);
    try {
      const data = await getMyDonationsApi();
      setDonations(data);
    } catch (error) {
      console.error("Failed to fetch donations", error);
    } finally {
      setIsLoading(false);
    }
  };

  const totalLives = donations.filter(d => d.statut === 'complete').length * 3;
  const completedDonations = donations.filter(d => d.statut === 'complete');
  const firstDonationDate = completedDonations.length > 0 
    ? new Date(completedDonations[completedDonations.length - 1].dateDon).toLocaleDateString(language === 'fr' ? 'fr-FR' : 'en-US', { month: 'short', year: 'numeric' })
    : t("donor.history.stats.none");

  return (
    <DonorLayout>
      <div className="p-4 md:p-6 max-w-2xl mx-auto">

        {/* ── Header ───────────────────────────────── */}
        <div className="mb-6">
          <p className="text-[11px] font-semibold text-[#AAAAAA] uppercase tracking-widest mb-1" style={{ fontFamily: "'DM Sans', sans-serif" }}>
            {t("donor.history.sub")}
          </p>
          <div className="flex items-center justify-between">
            <h1 className="text-[26px] font-bold text-[#0A0A0A]" style={{ fontFamily: "'DM Sans', sans-serif" }}>
              {t("donor.history.title")}
            </h1>
            <button onClick={fetchDonations} className="p-2 rounded-xl border border-[#E0E0E0] hover:bg-[#FAFAFA] transition-all">
              <Loader2 className={`w-4 h-4 text-[#888888] ${isLoading ? 'animate-spin' : ''}`} />
            </button>
          </div>
        </div>

        {/* ── Hero impact card ─────────────────────── */}
        <motion.div
          initial={{ opacity: 0, scale: 0.97 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ duration: 0.5 }}
          className="relative overflow-hidden rounded-2xl bg-gradient-to-br from-[#CC0000] to-[#990000] p-6 mb-6 text-white shadow-[0_8px_32px_rgba(204,0,0,0.35)]"
        >
          <div className="absolute -right-10 -top-10 w-32 h-32 rounded-full bg-white/10" />
          <div className="absolute -right-4 -bottom-8 w-24 h-24 rounded-full bg-black/10" />

          <div className="relative z-10 flex items-center justify-between">
            <div>
              <div className="flex items-center gap-2 mb-1">
                <Heart className="w-4 h-4 text-white/80 fill-white/80" />
                <span className="text-[12px] font-semibold text-white/70 uppercase tracking-wide" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                  {t("donor.history.lives_saved")}
                </span>
              </div>
              <p className="text-[52px] font-bold text-white leading-none" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                {totalLives}
              </p>
              <p className="text-white/60 text-[13px] mt-1" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                {t("donor.history.impact_desc", { count: completedDonations.length.toString() })}
              </p>
            </div>
            <div className="text-right">
              <div className="w-16 h-16 rounded-2xl bg-white/15 border border-white/20 flex items-center justify-center">
                <span className="text-white font-bold text-[18px]" style={{ fontFamily: "'DM Sans', sans-serif" }}>{user?.groupeSanguin || "??"}</span>
              </div>
              <p className="text-[11px] text-white/50 mt-1.5" style={{ fontFamily: "'DM Sans', sans-serif" }}>{t("donor.history.blood_group")}</p>
            </div>
          </div>
        </motion.div>

        {/* ── Stats Row ────────────────────────────── */}
        <div className="grid grid-cols-3 gap-3 mb-6">
          {[
            { icon: Award, label: t("donor.history.stats.total"), value: completedDonations.length.toString(), color: "text-[#D4720B]", bg: "bg-[#FFF8F0]" },
            { icon: Heart, label: t("donor.history.stats.lives"), value: totalLives.toString(), color: "text-[#CC0000]", bg: "bg-[#FFF0F0]" },
            { icon: Calendar, label: t("donor.history.stats.first"), value: firstDonationDate, color: "text-[#1A7A3F]", bg: "bg-[#F0FFF4]" },
          ].map((s, i) => (
            <motion.div
              key={i}
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.2 + i * 0.08 }}
              className="bg-white rounded-2xl border border-[#EBEBEB] p-4 text-center"
            >
              <div className={`inline-flex p-2 rounded-xl ${s.bg} mb-2`}>
                <s.icon className={`w-4 h-4 ${s.color}`} />
              </div>
              <p className="text-[20px] font-bold text-[#0A0A0A]" style={{ fontFamily: "'DM Sans', sans-serif" }}>{s.value}</p>
              <p className="text-[11px] text-[#AAAAAA] font-medium mt-0.5" style={{ fontFamily: "'DM Sans', sans-serif" }}>{s.label}</p>
            </motion.div>
          ))}
        </div>

        {/* ── Donation History List ─────────────────── */}
        <div>
          <h2 className="text-[16px] font-bold text-[#0A0A0A] mb-4" style={{ fontFamily: "'DM Sans', sans-serif" }}>
            {t("donor.history.detail_title")}
          </h2>
          <div className="space-y-3">
            {isLoading ? (
              <div className="py-20 flex flex-col items-center justify-center gap-4">
                <Loader2 className="w-8 h-8 text-[#CC0000] animate-spin" />
                <p className="text-[#888888] text-sm">{t("donor.history.loading")}</p>
              </div>
            ) : donations.length === 0 ? (
              <div className="py-20 text-center bg-white rounded-3xl border border-dashed border-[#E0E0E0]">
                <Droplet className="w-12 h-12 text-[#CC0000]/10 mx-auto mb-4" />
                <p className="text-[#888888] font-medium">{t("donor.history.empty")}</p>
              </div>
            ) : (
              donations.map((donation, idx) => (
                <motion.div
                  key={donation._id}
                  initial={{ opacity: 0, x: -10 }}
                  animate={{ opacity: 1, x: 0 }}
                  transition={{ delay: 0.4 + idx * 0.08 }}
                  className="bg-white rounded-2xl border border-[#EBEBEB] p-4 hover:shadow-[0_4px_16px_rgba(0,0,0,0.07)] transition-shadow"
                >
                  <div className="flex items-center gap-3">
                    <div className={`w-12 h-12 rounded-xl ${donation.statut === 'complete' ? 'bg-[#CC0000]' : 'bg-[#E0E0E0]'} flex items-center justify-center flex-shrink-0 transition-colors`}>
                      <span className="text-white font-bold text-[14px]" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                        {donation.groupeSanguin}
                      </span>
                    </div>

                    <div className="flex-1 min-w-0">
                      <p className="text-[14px] font-bold text-[#0A0A0A] truncate" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                        {donation.hospitalId?.nom || donation.lieuDon || t("hospital.verified_desc")}
                      </p>
                      <div className="flex items-center gap-3 mt-1">
                        <div className="flex items-center gap-1">
                          <Calendar className="w-3 h-3 text-[#AAAAAA]" />
                          <span className="text-[11px] text-[#AAAAAA]" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                            {new Date(donation.dateDon).toLocaleDateString(language === 'fr' ? 'fr-FR' : 'en-US', { day: 'numeric', month: 'short', year: 'numeric' })}
                          </span>
                        </div>
                        {donation.hospitalId?.region && (
                          <div className="flex items-center gap-1">
                            <MapPin className="w-3 h-3 text-[#AAAAAA]" />
                            <span className="text-[11px] text-[#AAAAAA]" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                              {donation.hospitalId?.region}
                            </span>
                          </div>
                        )}
                      </div>
                    </div>

                    <div className="text-right flex-shrink-0">
                      {donation.statut === 'complete' ? (
                        <>
                          <div className="flex items-center gap-1 justify-end mb-1">
                            <Heart className="w-3 h-3 text-[#CC0000] fill-[#CC0000]" />
                            <span className="text-[15px] font-bold text-[#CC0000]" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                              +3
                            </span>
                          </div>
                          <Badge variant="success" className="text-[10px]">{t("donor.history.status_complete")}</Badge>
                        </>
                       ) : (
                        <div className="flex flex-col items-end gap-1">
                          <Badge variant="pending" className="text-[10px]">{t("donor.history.status_pending")}</Badge>
                          <span className="text-[10px] text-[#AAAAAA]">{t("donor.history.status_planned")}</span>
                        </div>
                      )}
                    </div>
                  </div>
                </motion.div>
              ))
            )}
          </div>
        </div>
      </div>
    </DonorLayout>
  );
}
