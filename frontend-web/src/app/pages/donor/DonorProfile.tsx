import React, { useState, useEffect } from "react";
import { useNavigate } from "react-router";
import { DonorLayout } from "../../components/layouts";
import { Button, Input } from "../../components/ui";
import {
  Phone, MapPin, Droplet, Calendar, LogOut,
  Bell, Globe, Pencil, Check, ChevronRight, Heart, Loader2, User as UserIcon, X
} from "lucide-react";
import { motion, AnimatePresence } from "motion/react";
import { useAuth } from "../../AuthContext";
import { updateUserProfileApi, getMyDonationsApi } from "../../api";
import { useTranslation, useLanguage } from "../../i18n";

export function DonorProfile() {
  const navigate = useNavigate();
  const { user, logout } = useAuth();
  const { t } = useTranslation();
  const { language, setLanguage } = useLanguage();
  const [isEditing, setIsEditing] = useState(false);
  const [isSaving, setIsSaving] = useState(false);
  const [notificationsOn, setNotificationsOn] = useState(true);
  const [stats, setStats] = useState({ totalDons: 0, livesSaved: 0 });

  // État local du formulaire
  const [formData, setFormData] = useState({
    nom: user?.nom || "",
    prenom: user?.prenom || "",
    telephone: user?.telephone || "",
    lieuResidence: user?.lieuResidence || "",
  });

  useEffect(() => {
    fetchStats();
  }, []);

  // Synchroniser formData avec user quand le contexte change ou se charge
  useEffect(() => {
    if (user) {
      setFormData({
        nom: user.nom || "",
        prenom: user.prenom || "",
        telephone: user.telephone || "",
        lieuResidence: user.lieuResidence || "",
      });
    }
  }, [user]);

  const fetchStats = async () => {
    try {
      const donations = await getMyDonationsApi();
      const completed = donations.filter((d: any) => d.statut === 'complete');
      setStats({
        totalDons: completed.length,
        livesSaved: completed.length * 3
      });
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
      await updateUserProfileApi(formData);
      setIsEditing(false);
      // Facultatif : rafraîchir le contexte de l'utilisateur si nécessaire
      // Pour l'instant on fait confiance à l'update local
    } catch (err: any) {
      alert(err.message || t("profile.error_save"));
    } finally {
      setIsSaving(false);
    }
  };

  const ProfileField = ({
    icon: Icon,
    label,
    field,
    value,
    editable = true,
  }: {
    icon: any;
    label: string;
    field?: keyof typeof formData;
    value: string;
    editable?: boolean;
  }) => (
    <div className="flex items-start gap-3 py-3.5 border-b border-[#F5F5F5] last:border-0">
      <div className="p-2 rounded-xl bg-[#F5F5F5] flex-shrink-0 mt-0.5">
        <Icon className="w-4 h-4 text-[#888888]" />
      </div>
      <div className="flex-1 min-w-0">
        <p className="text-[11px] font-semibold text-[#AAAAAA] uppercase tracking-wide mb-1" style={{ fontFamily: "'DM Sans', sans-serif" }}>
          {label}
        </p>
        {isEditing && editable && field ? (
          <Input
            value={value}
            onChange={(e) => setFormData({ ...formData, [field]: e.target.value })}
            className="h-9 text-[14px]"
          />
        ) : (
          <p className="text-[14px] font-semibold text-[#111111]" style={{ fontFamily: "'DM Sans', sans-serif" }}>
            {value}
          </p>
        )}
      </div>
    </div>
  );

  return (
    <DonorLayout>
      <div className="p-4 md:p-6 max-w-xl mx-auto pb-28 md:pb-8">

        {/* ── Profile Hero Card ─────────────────────── */}
        <motion.div
          initial={{ opacity: 0, y: -10 }}
          animate={{ opacity: 1, y: 0 }}
          className="bg-gradient-to-br from-[#0A0A0A] to-[#1A1A1A] rounded-2xl p-6 mb-5 relative overflow-hidden"
        >
          <div className="absolute -right-8 -top-8 w-28 h-28 rounded-full bg-[#CC0000]/15" />
          <div className="absolute -left-4 -bottom-6 w-20 h-20 rounded-full bg-white/5" />

          <div className="relative z-10 flex items-center gap-4">
            <div className="w-16 h-16 rounded-2xl bg-gradient-to-br from-[#CC0000] to-[#990000] flex items-center justify-center shadow-lg flex-shrink-0">
              <span className="text-white font-bold text-[22px]" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                {(formData.prenom[0] || "") + (formData.nom[0] || "")}
              </span>
            </div>
            <div className="flex-1 min-w-0">
              <p className="text-white font-bold text-[18px] truncate" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                {formData.prenom} {formData.nom}
              </p>
              <div className="flex items-center gap-2 mt-1.5">
                <div className="flex items-center gap-1.5 bg-[#CC0000]/20 border border-[#CC0000]/30 rounded-full px-2.5 py-1">
                  <Droplet className="w-3 h-3 text-[#FF6666] fill-[#FF6666]" />
                  <span className="text-[12px] font-bold text-[#FF6666]" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                    {user?.groupeSanguin || "??"}
                  </span>
                </div>
                <span className="text-white/40 text-[12px]" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                  {t("profile.hemotype")}
                </span>
              </div>
            </div>
          </div>

          {/* Mini stats */}
          <div className="relative z-10 grid grid-cols-2 gap-3 mt-5">
            <div className="bg-white/8 rounded-xl p-3 border border-white/10">
              <p className="text-[20px] font-bold text-white" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                {stats.totalDons}
              </p>
              <p className="text-[11px] text-white/50 font-medium" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                {t("profile.donations_done")}
              </p>
            </div>
            <div className="bg-white/8 rounded-xl p-3 border border-white/10">
              <div className="flex items-center gap-1">
                <p className="text-[20px] font-bold text-white" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                  {stats.livesSaved}
                </p>
                <Heart className="w-4 h-4 text-[#CC0000] fill-[#CC0000]" />
              </div>
              <p className="text-[11px] text-white/50 font-medium" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                {t("profile.lives_saved")}
              </p>
            </div>
          </div>
        </motion.div>

        {/* ── Personal Info Card ───────────────────── */}
        <div className="bg-white rounded-2xl border border-[#EBEBEB] mb-4 overflow-hidden shadow-[0_1px_8px_rgba(0,0,0,0.05)]">
          <div className="flex items-center justify-between px-5 py-4 border-b border-[#F5F5F5]">
            <h2 className="text-[15px] font-bold text-[#0A0A0A]" style={{ fontFamily: "'DM Sans', sans-serif" }}>
              {t("profile.personal_info")}
            </h2>
            <button
              onClick={() => isEditing ? setIsEditing(false) : setIsEditing(true)}
              className={`flex items-center gap-1.5 text-[12px] font-bold px-3 py-1.5 rounded-xl transition-all ${
                isEditing
                  ? "bg-[#CC0000]/10 text-[#CC0000]"
                  : "bg-[#F5F5F5] text-[#555555] hover:bg-[#EBEBEB]"
              }`}
              style={{ fontFamily: "'DM Sans', sans-serif" }}
            >
              {isEditing ? <><X className="w-3.5 h-3.5" /> {t("profile.cancel")}</> : <><Pencil className="w-3.5 h-3.5" /> {t("profile.edit")}</>}
            </button>
          </div>

          <div className="px-5">
            <ProfileField icon={UserIcon} label={t("profile.firstname")} field="prenom" value={formData.prenom} />
            <ProfileField icon={UserIcon} label={t("profile.lastname")} field="nom" value={formData.nom} />
            <ProfileField icon={Phone} label={t("profile.phone")} field="telephone" value={formData.telephone} />
            <ProfileField icon={MapPin} label={t("profile.residence")} field="lieuResidence" value={formData.lieuResidence} />
            <ProfileField icon={Droplet} label={t("profile.blood_group")} value={user?.groupeSanguin || "—"} editable={false} />
            <ProfileField icon={Calendar} label={t("profile.reg_date")} value={user?.createdAt ? new Date(user.createdAt).toLocaleDateString('fr-FR') : "—"} editable={false} />
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

        {/* ── Settings Card ────────────────────────── */}
        <div className="bg-white rounded-2xl border border-[#EBEBEB] mb-4 overflow-hidden shadow-[0_1px_8px_rgba(0,0,0,0.05)]">
          <div className="px-5 py-4 border-b border-[#F5F5F5]">
            <h2 className="text-[15px] font-bold text-[#0A0A0A]" style={{ fontFamily: "'DM Sans', sans-serif" }}>
              {t("profile.settings")}
            </h2>
          </div>

          {/* Notifications */}
          <div className="px-5 py-4 flex items-center justify-between border-b border-[#F5F5F5]">
            <div className="flex items-center gap-3">
              <div className="p-2 rounded-xl bg-[#F5F5F5]">
                <Bell className="w-4 h-4 text-[#888888]" />
              </div>
              <div>
                <p className="text-[14px] font-semibold text-[#111111]" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                  {t("profile.notifs")}
                </p>
                <p className="text-[11px] text-[#AAAAAA]" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                  {t("profile.notifs_desc")}
                </p>
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

          {/* Language */}
          <button 
            onClick={() => setLanguage(language === "fr" ? "en" : "fr")}
            className="w-full px-5 py-4 flex items-center gap-3 hover:bg-[#FAFAFA] transition-colors"
          >
            <div className="p-2 rounded-xl bg-[#F5F5F5]">
              <Globe className="w-4 h-4 text-[#888888]" />
            </div>
            <div className="flex-1 text-left">
              <p className="text-[14px] font-semibold text-[#111111]" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                {t("profile.language")}
              </p>
              <p className="text-[11px] text-[#AAAAAA]" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                {t("profile.current_language")}
              </p>
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
    </DonorLayout>
  );
}
