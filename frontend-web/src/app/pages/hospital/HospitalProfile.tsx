import React, { useState, useEffect } from "react";
import { useNavigate } from "react-router";
import { HospitalLayout } from "../../components/layouts";
import { Input, Button } from "../../components/ui";
import { Building2, Mail, Phone, MapPin, LogOut, Bell, Globe, Pencil, Check, ShieldCheck, ChevronRight, Users, Droplet, Loader2, X, Tag } from "lucide-react";
import { motion, AnimatePresence } from "motion/react";
import { useAuth } from "../../AuthContext";
import { updateHospitalProfileApi, getMyRequestsApi } from "../../api";
import { useTranslation, useLanguage } from "../../i18n";

export function HospitalProfile() {
  const navigate = useNavigate();
  const { user, logout } = useAuth();
  const { t } = useTranslation();
  const { language, setLanguage } = useLanguage();
  const [isEditing, setIsEditing] = useState(false);
  const [isSaving, setIsSaving] = useState(false);
  const [notificationsOn, setNotificationsOn] = useState(true);
  const [stats, setStats] = useState({ requestsCount: 0 });

  const [formData, setFormData] = useState({
    nom: user?.nom || "",
    contact: user?.contact || "",
    region: user?.region || "",
    localisation: user?.localisation || "",
  });

  useEffect(() => {
    fetchStats();
  }, []);

  const fetchStats = async () => {
    try {
      const requests = await getMyRequestsApi();
      setStats({ requestsCount: requests.length });
    } catch (e) {
      console.error(e);
    }
  };

  const handleLogout = () => {
    logout();
    navigate("/home", { replace: true });
  };

  const handleSave = async () => {
    setIsSaving(true);
    try {
      await updateHospitalProfileApi(formData);
      setIsEditing(false);
    } catch (err: any) {
      alert(err.message || t("profile.error_save"));
    } finally {
      setIsSaving(false);
    }
  };

  const Field = ({ icon: Icon, label, field, value, type = "text", editable = true }: { icon: any; label: string; field?: keyof typeof formData; value: string; type?: string; editable?: boolean }) => (
    <div className="flex items-start gap-3 py-3.5 border-b border-[#F5F5F5] last:border-0">
      <div className="p-2 rounded-xl bg-[#F5F5F5] flex-shrink-0 mt-0.5">
        <Icon className="w-4 h-4 text-[#888888]" />
      </div>
      <div className="flex-1 min-w-0">
        <p className="text-[11px] font-semibold text-[#AAAAAA] uppercase tracking-wide mb-1" style={{ fontFamily: "'DM Sans', sans-serif" }}>
          {label}
        </p>
        {isEditing && editable && field ? (
          <Input type={type} value={value} onChange={(e) => setFormData({ ...formData, [field]: e.target.value })} className="h-9 text-[14px]" />
        ) : (
          <p className="text-[14px] font-semibold text-[#111111]" style={{ fontFamily: "'DM Sans', sans-serif" }}>{value}</p>
        )}
      </div>
    </div>
  );

  return (
    <HospitalLayout>
      <div className="max-w-xl mx-auto pb-10">

        {/* ── Hero Card ────────────────────────────── */}
        <motion.div
          initial={{ opacity: 0, y: -8 }}
          animate={{ opacity: 1, y: 0 }}
          className="rounded-2xl overflow-hidden mb-5 shadow-[0_4px_24px_rgba(204,0,0,0.15)]"
        >
          {/* Banner */}
          <div className="h-24 bg-gradient-to-br from-[#CC0000] to-[#800000] relative">
            <div className="absolute -bottom-6 left-6">
              <div className="w-16 h-16 rounded-2xl bg-white border-4 border-white shadow-lg flex items-center justify-center">
                <Building2 className="w-8 h-8 text-[#CC0000]" />
              </div>
            </div>
          </div>
          {/* Info */}
          <div className="bg-white pt-10 pb-5 px-6">
            <div className="flex items-start justify-between">
              <div className="flex-1 min-w-0">
                <h1 className="text-[18px] font-bold text-[#0A0A0A]" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                  {formData.nom}
                </h1>
                <div className="flex items-center gap-2 mt-1.5">
                  <div className="flex items-center gap-1 bg-[#F0FFF4] border border-[#1A7A3F]/20 rounded-full px-2.5 py-0.5">
                    <ShieldCheck className="w-3 h-3 text-[#1A7A3F]" />
                    <span className="text-[11px] font-bold text-[#1A7A3F]" style={{ fontFamily: "'DM Sans', sans-serif" }}>{t("profile.verified")}</span>
                  </div>
                  <span className="text-[11px] text-[#AAAAAA]" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                    ID: {user?.numeroAgrement || "N/A"}
                  </span>
                </div>
              </div>
            </div>
            {/* Quick stats */}
            <div className="grid grid-cols-2 gap-3 mt-5">
              <div className="bg-[#F7F7F8] rounded-xl p-3 flex items-center gap-2">
                <Tag className="w-4 h-4 text-[#5B5BD6]" />
                <div>
                  <p className="text-[17px] font-bold text-[#0A0A0A]" style={{ fontFamily: "'DM Sans', sans-serif" }}>{stats.requestsCount}</p>
                  <p className="text-[10px] text-[#AAAAAA] font-medium" style={{ fontFamily: "'DM Sans', sans-serif" }}>{t("profile.total_requests")}</p>
                </div>
              </div>
              <div className="bg-[#F7F7F8] rounded-xl p-3 flex items-center gap-2">
                <Droplet className="w-4 h-4 text-[#CC0000]" />
                <div>
                  <p className="text-[17px] font-bold text-[#0A0A0A]" style={{ fontFamily: "'DM Sans', sans-serif" }}>--</p>
                  <p className="text-[10px] text-[#AAAAAA] font-medium" style={{ fontFamily: "'DM Sans', sans-serif" }}>{t("profile.confirmed_donations")}</p>
                </div>
              </div>
            </div>
          </div>
        </motion.div>

        {/* ── Info Card ─────────────────────────────── */}
        <div className="bg-white rounded-2xl border border-[#EBEBEB] mb-4 overflow-hidden shadow-[0_1px_8px_rgba(0,0,0,0.05)]">
          <div className="flex items-center justify-between px-5 py-4 border-b border-[#F5F5F5]">
            <h2 className="text-[15px] font-bold text-[#0A0A0A]" style={{ fontFamily: "'DM Sans', sans-serif" }}>
              {t("profile.hospital_info")}
            </h2>
            <button
              onClick={() => isEditing ? setIsEditing(false) : setIsEditing(true)}
              className={`flex items-center gap-1.5 text-[12px] font-bold px-3 py-1.5 rounded-xl transition-all ${
                isEditing ? "bg-[#CC0000]/10 text-[#CC0000]" : "bg-[#F5F5F5] text-[#555555] hover:bg-[#EBEBEB]"
               }`}
              style={{ fontFamily: "'DM Sans', sans-serif" }}
            >
              {isEditing ? <><X className="w-3.5 h-3.5" /> {t("profile.cancel")}</> : <><Pencil className="w-3.5 h-3.5" /> {t("profile.edit")}</>}
            </button>
          </div>
          <div className="px-5">
            <Field icon={Building2} label={t("profile.hospital_name")} field="nom" value={formData.nom} />
            <Field icon={Mail} label={t("profile.inst_email")} value={user?.email || ""} editable={false} />
            <Field icon={Phone} label={t("profile.phone")} field="contact" value={formData.contact} type="tel" />
            <Field icon={MapPin} label={t("profile.region")} field="region" value={formData.region} />
            <Field icon={MapPin} label={t("profile.location")} field="localisation" value={formData.localisation} />
            <Field icon={ShieldCheck} label={t("profile.license")} value={user?.numeroAgrement || ""} editable={false} />
          </div>
          <AnimatePresence>
            {isEditing && (
              <motion.div
                initial={{ height: 0, opacity: 0 }}
                animate={{ height: "auto", opacity: 1 }}
                exit={{ height: 0, opacity: 0 }}
                className="overflow-hidden"
              >
                <div className="px-5 pb-5 pt-2">
                  <Button className="w-full bg-[#CC0000]" onClick={handleSave} disabled={isSaving}>
                     {isSaving ? <Loader2 className="w-4 h-4 animate-spin" /> : t("profile.save")}
                  </Button>
                </div>
              </motion.div>
            )}
          </AnimatePresence>
        </div>

        {/* ── Settings Card ─────────────────────────── */}
        <div className="bg-white rounded-2xl border border-[#EBEBEB] mb-4 overflow-hidden shadow-[0_1px_8px_rgba(0,0,0,0.05)]">
          <div className="px-5 py-4 border-b border-[#F5F5F5]">
            <h2 className="text-[15px] font-bold text-[#0A0A0A]" style={{ fontFamily: "'DM Sans', sans-serif" }}>{t("profile.settings")}</h2>
          </div>
          <div className="px-5 py-4 flex items-center justify-between border-b border-[#F5F5F5]">
            <div className="flex items-center gap-3">
              <div className="p-2 rounded-xl bg-[#F5F5F5]">
                <Bell className="w-4 h-4 text-[#888888]" />
              </div>
               <div>
                 <p className="text-[14px] font-semibold text-[#111111]" style={{ fontFamily: "'DM Sans', sans-serif" }}>{t("profile.notifs")}</p>
                 <p className="text-[11px] text-[#AAAAAA]" style={{ fontFamily: "'DM Sans', sans-serif" }}>{t("profile.notifs_desc")}</p>
               </div>
            </div>
            <button
              onClick={() => setNotificationsOn(!notificationsOn)}
              className={`relative w-12 h-6 rounded-full transition-all duration-300 ${notificationsOn ? "bg-[#1A7A3F]" : "bg-[#D0D0D0]"}`}
            >
              <motion.div
                layout
                transition={{ type: "spring", stiffness: 500, damping: 30 }}
                className="absolute top-0.5 w-5 h-5 rounded-full bg-white shadow-md"
                style={{ left: notificationsOn ? "calc(100% - 22px)" : "2px" }}
              />
            </button>
          </div>
          <button 
            onClick={() => setLanguage(language === "fr" ? "en" : "fr")}
            className="w-full px-5 py-4 flex items-center gap-3 hover:bg-[#FAFAFA] transition-colors"
          >
             <div className="p-2 rounded-xl bg-[#F5F5F5]">
               <Globe className="w-4 h-4 text-[#888888]" />
             </div>
             <div className="flex-1 text-left">
               <p className="text-[14px] font-semibold text-[#111111]" style={{ fontFamily: "'DM Sans', sans-serif" }}>{t("profile.language")}</p>
               <p className="text-[11px] text-[#AAAAAA]" style={{ fontFamily: "'DM Sans', sans-serif" }}>{t("profile.current_language")}</p>
             </div>
            <ChevronRight className="w-4 h-4 text-[#CCCCCC]" />
          </button>
        </div>

        {/* ── Logout ───────────────────────────────── */}
        <button
          onClick={handleLogout}
          className="w-full flex items-center justify-center gap-2.5 py-3.5 rounded-2xl border-2 border-[#CC0000]/20 bg-[#FFF0F0] text-[#CC0000] font-bold text-[14px] hover:bg-[#CC0000] hover:text-white transition-all duration-200 active:scale-[0.98]"
           style={{ fontFamily: "'DM Sans', sans-serif" }}
         >
           <LogOut className="w-4 h-4" />
           {t("nav.logout")}
         </button>
      </div>
    </HospitalLayout>
  );
}
