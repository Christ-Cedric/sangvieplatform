import React, { useState, useEffect } from "react";
import { Link, useLocation, useNavigate } from "react-router";
import { useAuth } from "../AuthContext";
import {
  Users, Droplet, Building2, Clock, CheckCircle2, XCircle, TrendingUp, Activity, Loader2,
  LayoutDashboard, Stethoscope, BarChart3, Settings, ShieldCheck, Bell, ChevronRight,
  Menu, X, MessageSquare, Home, MapPin, User, LogOut, Globe, Shield
} from "lucide-react";
import { useLanguage, useTranslation } from "../i18n";
import { motion, AnimatePresence } from "motion/react";
import { 
  getHospitalNotificationsApi, 
  markHospitalNotificationsAsReadApi, 
  getAdminNotificationsApi, 
  markAdminNotificationsAsReadApi 
} from "../api";

/**
 * Composant de déconnexion réutilisable dans les layouts
 */
function LogoutButton({ dark = false }: { dark?: boolean }) {
  const { logout } = useAuth();
  const navigate = useNavigate();

  const handleLogout = () => {
    logout();
    navigate("/home", { replace: true });
  };

  const { t } = useTranslation();

  return (
    <button
      onClick={handleLogout}
      className={`flex items-center gap-2.5 w-full px-4 py-3 rounded-xl transition-all duration-200 group mb-2 font-bold text-[13px] ${dark
        ? "bg-[#CC0000] text-white hover:bg-[#A30000] shadow-[0_4px_12px_rgba(204,0,0,0.3)]"
        : "bg-[#FFF0F0] text-[#CC0000] border border-[#CC0000]/20 hover:bg-[#CC0000] hover:text-white"
        }`}
      style={{ fontFamily: "'DM Sans', sans-serif" }}
    >
      <LogOut className="w-4 h-4 flex-shrink-0" />
      <span>{t("nav.logout")}</span>
    </button>
  );
}


/* ============================================================
   PUBLIC LAYOUT
   ============================================================ */
export function PublicLayout({ children }: { children: React.ReactNode }) {
  const { language, setLanguage } = useLanguage();
  const { t } = useTranslation();

  return (
    <div className="min-h-screen bg-white font-sans flex flex-col">
      {/* Navbar */}
      <header className="flex items-center justify-between px-6 py-4 bg-white/90 backdrop-blur-md border-b border-[#F0F0F0] sticky top-0 z-50">
        <Link to="/" className="flex items-center gap-2.5 group">
          <div className="bg-[#CC0000] p-1.5 rounded-lg shadow-sm group-hover:shadow-md transition-shadow">
            <Droplet className="text-white w-5 h-5 fill-white" />
          </div>
          <span
            className="text-xl font-bold text-[#0A0A0A] tracking-tight"
            style={{ fontFamily: "'DM Sans', sans-serif" }}
          >
            SangVie
          </span>
        </Link>

        <div className="flex gap-1 items-center bg-[#F5F5F5] rounded-full p-1">
          <button
            type="button"
            onClick={() => setLanguage("fr")}
            className={`text-xs font-semibold px-3 py-1.5 rounded-full transition-all ${language === "fr"
              ? "bg-white text-[#111111] shadow-sm"
              : "text-[#888888] hover:text-[#111111]"
              }`}
            style={{ fontFamily: "'DM Sans', sans-serif" }}
          >
            FR
          </button>
          <button
            type="button"
            onClick={() => setLanguage("en")}
            className={`text-xs font-semibold px-3 py-1.5 rounded-full transition-all ${language === "en"
              ? "bg-white text-[#111111] shadow-sm"
              : "text-[#888888] hover:text-[#111111]"
              }`}
            style={{ fontFamily: "'DM Sans', sans-serif" }}
          >
            EN
          </button>
        </div>
      </header>

      <main className="flex-1 flex flex-col w-full max-w-[1440px] mx-auto overflow-hidden">
        {children}
      </main>
    </div>
  );
}

/* ============================================================
   DONOR LAYOUT
   ============================================================ */
export function DonorLayout({ children }: { children: React.ReactNode }) {
  const location = useLocation();
  const { user } = useAuth();
  const { t } = useTranslation();
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  const navItems = [
    { icon: Home, labelKey: "nav.donor.home", path: "/donor/home", label: "Accueil" },
    { icon: MessageSquare, labelKey: "nav.shared.messages", path: "/messages", label: "Messages" },
    { icon: MapPin, labelKey: "nav.donor.map", path: "/donor/map", label: "Carte" },
    { icon: Clock, labelKey: "nav.donor.history", path: "/donor/history", label: "Historique" },
    { icon: User, labelKey: "nav.donor.profile", path: "/donor/profile", label: "Profil" },
  ];

  return (
    <div className="min-h-screen bg-[#F7F7F8] flex flex-col md:flex-row relative">
      {/* Mobile Header */}
      <header className="md:hidden flex items-center justify-between px-5 py-3.5 bg-white border-b border-[#EBEBEB] sticky top-0 z-50 shadow-[0_1px_8px_rgba(0,0,0,0.06)]">
        <Link to="/donor/home" className="flex items-center gap-2 group">
          <div className="bg-[#CC0000] p-1 rounded-lg">
            <Droplet className="text-white w-4 h-4 fill-white" />
          </div>
          <span
            className="text-lg font-bold text-[#0A0A0A]"
            style={{ fontFamily: "'DM Sans', sans-serif" }}
          >
            SangVie
          </span>
        </Link>
        <div className="flex items-center gap-2">
          <button className="relative p-2 rounded-xl hover:bg-[#F5F5F5] transition-colors">
            <Bell className="w-5 h-5 text-[#444444]" />
            <span className="absolute top-1.5 right-1.5 w-2 h-2 bg-[#CC0000] rounded-full border-2 border-white" />
          </button>
          <div className="w-8 h-8 rounded-full bg-gradient-to-br from-[#CC0000] to-[#990000] flex items-center justify-center text-white text-xs font-bold">
            {user?.nom?.split(" ")?.map((n: string) => n[0])?.join("")?.slice(0, 2) || "U"}
          </div>
        </div>
      </header>

      {/* Desktop Sidebar */}
      <aside className="hidden md:flex flex-col w-[260px] bg-[#0A0A0A] border-r border-white/5 h-screen sticky top-0 shadow-2xl z-50">
        {/* Logo */}
        <div className="px-6 pt-6 pb-4">
          <Link to="/donor/home" className="flex items-center gap-3">
            <div className="bg-[#CC0000] p-1.5 rounded-lg shadow-[0_4px_12px_rgba(204,0,0,0.3)]">
              <Droplet className="text-white w-5 h-5 fill-white" />
            </div>
            <div>
              <span className="text-lg font-bold text-white leading-none block" style={{ fontFamily: "'DM Sans', sans-serif" }}>SangVie</span>
              <span className="text-[10px] text-[#CC0000] font-semibold tracking-widest uppercase mt-0.5 block" style={{ fontFamily: "'DM Sans', sans-serif" }}>{t("donor.space")}</span>
            </div>
          </Link>
        </div>

        <div className="mx-6 border-t border-white/10 mb-4" />

        {/* Nav */}
        <nav className="flex-1 px-3 flex flex-col gap-0.5 overflow-y-auto mt-2">
          {navItems.map((item) => {
            const isActive = location.pathname.startsWith(item.path);
            return (
              <Link
                key={item.path}
                to={item.path}
                className={`flex items-center gap-3 px-3 py-2.5 rounded-xl transition-all duration-150 group ${isActive
                  ? "bg-[#1E1E1E] text-white"
                  : "text-[#999999] hover:bg-[#1A1A1A] hover:text-white"
                  }`}
                style={{ fontFamily: "'DM Sans', sans-serif" }}
              >
                <div
                  className={`p-1.5 rounded-lg transition-colors ${isActive
                    ? "bg-[#CC0000] text-white"
                    : "bg-[#1A1A1A] text-[#666666] group-hover:text-white"
                    }`}
                >
                  <item.icon className="w-4 h-4" />
                </div>
                <span className={`text-sm font-medium ${isActive ? "font-semibold" : ""}`}>
                  {t(item.labelKey as any)}
                </span>
                {isActive && (
                  <div className="ml-auto w-1.5 h-1.5 rounded-full bg-[#CC0000]" />
                )}
              </Link>
            );
          })}
        </nav>

        {/* User + Logout section */}
        <div className="px-4 mb-6 mt-auto pt-6 border-t border-white/10 relative z-20">
          {/* User info */}
          <div className="flex items-center gap-3 p-3 rounded-xl bg-[#1A1A1A] border border-[#252525] mb-2">
            <div className="w-9 h-9 rounded-xl bg-gradient-to-br from-[#CC0000] to-[#990000] flex items-center justify-center text-white text-sm font-bold flex-shrink-0 shadow-lg">
              {user?.nom?.split(" ")?.map((n: string) => n[0])?.join("")?.slice(0, 2) || "U"}
            </div>
            <div className="flex-1 truncate">
              <p
                className="text-sm font-bold text-white truncate"
                style={{ fontFamily: "'DM Sans', sans-serif" }}
              >
                {user?.nom || t("nav.user.default")}
              </p>
              <p
                className="text-[10px] text-white/40 uppercase tracking-widest font-bold mt-0.5"
                style={{ fontFamily: "'DM Sans', sans-serif" }}
              >
                {t("donor.active")}
              </p>
            </div>
          </div>
          {/* Logout button */}
          <LogoutButton dark />
        </div>
      </aside>

      {/* Main Content */}
      <main className="flex-1 h-screen overflow-y-auto bg-[#F7F7F8] md:pb-0 w-full relative">
        {children}
      </main>

      {/* Mobile Bottom Navigation */}
      <nav className="md:hidden fixed bottom-0 left-0 right-0 bg-white border-t border-[#EBEBEB] flex justify-around z-50 shadow-[0_-4px_20px_rgba(0,0,0,0.08)] h-[64px] items-center px-2">
        {navItems.map((item) => {
          const isActive = location.pathname.startsWith(item.path);
          return (
            <Link
              key={item.path}
              to={item.path}
              className={`flex flex-col items-center gap-0.5 px-3 py-1.5 rounded-xl transition-all ${isActive ? "text-[#CC0000]" : "text-[#AAAAAA]"
                }`}
            >
              <div
                className={`p-1.5 rounded-xl transition-all ${isActive ? "bg-[#CC0000]/10" : ""
                  }`}
              >
                <item.icon className={`w-5 h-5 ${isActive ? "text-[#CC0000]" : ""}`} />
              </div>
              <span
                className={`text-[10px] font-semibold ${isActive ? "text-[#CC0000]" : ""}`}
                style={{ fontFamily: "'DM Sans', sans-serif" }}
              >
                {t(item.labelKey as any)}
              </span>
            </Link>
          );
        })}
      </nav>
    </div>
  );
}

/** Notification Center for Hospitals */
function HospitalNotifications() {
  const [notifications, setNotifications] = useState<any[]>([]);
  const [isOpen, setIsOpen] = useState(false);
  const navigate = useNavigate();
  const { t } = useTranslation();
  const { language } = useLanguage();

  const fetchNotifs = async () => {
    try {
      const data = await getHospitalNotificationsApi();
      setNotifications(data);
    } catch (e) {
      console.error(e);
    }
  };

  useEffect(() => {
    fetchNotifs();
    const timer = setInterval(fetchNotifs, 15000);
    return () => clearInterval(timer);
  }, []);

  const unreadCount = notifications.filter(n => !n.lue).length;

  const handleOpen = async () => {
    if (!isOpen && unreadCount > 0) {
      try {
        await markHospitalNotificationsAsReadApi();
        setNotifications(notifications.map(n => ({ ...n, lue: true })));
      } catch (e) {
        console.error(e);
      }
    }
    setIsOpen(!isOpen);
  };

  const handleNotifClick = (n: any) => {
    setIsOpen(false);
    const msg = n.message.toLowerCase();
    if (n.type === 'reponse_demande' || msg.includes('répondu')) {
      navigate('/messages');
    } else if (msg.includes('rapport') || msg.includes('statistique') || msg.includes('stats')) {
      navigate('/hospital/stats');
    } else if (msg.includes('demande') || msg.includes('urgent')) {
      navigate('/hospital/requests');
    } else if (msg.includes('profil') || msg.includes('validé')) {
      navigate('/hospital/profile');
    }
  };

  return (
    <div className="relative">
      <button
        onClick={handleOpen}
        className="relative p-2 rounded-xl hover:bg-[#F5F5F5] transition-colors"
      >
        <Bell className="w-5 h-5 text-[#444444]" />
        {unreadCount > 0 && (
          <span className="absolute -top-0.5 -right-0.5 w-4.5 h-4.5 bg-[#CC0000] rounded-full border-2 border-white text-[9px] text-white font-bold flex items-center justify-center shadow-sm">
            {unreadCount}
          </span>
        )}
      </button>

      <AnimatePresence>
        {isOpen && (
          <>
            <div className="fixed inset-0 z-[100]" onClick={() => setIsOpen(false)} />
            <motion.div
              initial={{ opacity: 0, y: 15, scale: 0.95 }}
              animate={{ opacity: 1, y: 0, scale: 1 }}
              exit={{ opacity: 0, y: 15, scale: 0.95 }}
              className="absolute right-0 mt-4 w-85 bg-white rounded-2xl shadow-[0_10px_40px_rgba(0,0,0,0.15)] border border-[#EBEBEB] z-[110] overflow-hidden"
            >
              <div className="px-5 py-3 border-b border-[#F0F0F0] bg-[#FAFAFA] flex items-center justify-between">
                <span className="text-[13px] font-bold text-[#111111]">{t("notif.title")}</span>
                <span className="text-[10px] font-bold text-[#CC0000] bg-[#FFF0F0] px-2 py-0.5 rounded-full">
                  {t("notif.total", { count: notifications.length.toString() })}
                </span>
              </div>
              <div className="max-h-[350px] overflow-y-auto">
                {notifications.length === 0 ? (
                  <div className="p-10 text-center">
                    <Bell className="w-8 h-8 text-[#DDDDDD] mx-auto mb-2" />
                    <p className="text-xs text-[#AAAAAA]">{t("notif.none")}</p>
                  </div>
                ) : (
                  notifications.map((n) => (
                    <div
                      key={n._id}
                      onClick={() => handleNotifClick(n)}
                      className="p-5 border-b border-[#F8F8F8] hover:bg-[#F9F9F9] transition-colors group/item cursor-pointer"
                    >
                      <div className="flex gap-3">
                        {!n.lue && <div className="w-2 h-2 rounded-full bg-[#CC0000] mt-1.5 flex-shrink-0" />}
                        <div className="flex-1">
                          <p className="text-[13px] text-[#333333] leading-relaxed font-medium group-hover/item:text-[#111111]">{n.message}</p>
                          <p className="text-[10px] text-[#AAAAAA] mt-2 font-medium flex items-center gap-1.5">
                            <Clock className="w-3 h-3" />
                            {new Date(n.createdAt).toLocaleDateString()} {t("shared.at")} {new Date(n.createdAt).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                          </p>
                        </div>
                      </div>
                    </div>
                  ))
                )}
              </div>
              <div className="p-3 bg-[#FBFBFB] text-center border-t border-[#F0F0F0]">
                <button onClick={() => setIsOpen(false)} className="text-[11px] font-bold text-[#888888] hover:text-[#555555]">{t("notif.close")}</button>
              </div>
            </motion.div>
          </>
        )}
      </AnimatePresence>
    </div>
  );
}

/** Notification Center for Admins */
function AdminNotifications() {
  const [notifications, setNotifications] = useState<any[]>([]);
  const [isOpen, setIsOpen] = useState(false);
  const navigate = useNavigate();
  const { t } = useTranslation();

  const fetchNotifs = async () => {
    try {
      const data = await getAdminNotificationsApi();
      setNotifications(data);
    } catch (e) {
      console.error(e);
    }
  };

  useEffect(() => {
    fetchNotifs();
    const timer = setInterval(fetchNotifs, 15000);
    return () => clearInterval(timer);
  }, []);

  const unreadCount = notifications.filter(n => !n.lue).length;

  const handleOpen = async () => {
    if (!isOpen && unreadCount > 0) {
      try {
        await markAdminNotificationsAsReadApi();
        setNotifications(notifications.map(n => ({ ...n, lue: true })));
      } catch (e) {
        console.error(e);
      }
    }
    setIsOpen(!isOpen);
  };

  const handleNotifClick = (n: any) => {
    setIsOpen(false);
    const msg = n.message.toLowerCase();
    if (msg.includes('rapport') || msg.includes('statistique') || msg.includes('stats')) {
      navigate('/admin/reports');
    } else if (msg.includes('hôpital') || msg.includes('inscription') || msg.includes('attente')) {
      navigate('/admin/dashboard');
    } else if (msg.includes('donneur') || msg.includes('utilisateur')) {
      navigate('/admin/users');
    }
  };

  return (
    <div className="relative">
      <button
        onClick={handleOpen}
        className="relative p-2 rounded-xl hover:bg-[#F5F5F7] transition-colors"
      >
        <Bell className="w-5 h-5 text-[#444444]" />
        {unreadCount > 0 && (
          <span className="absolute -top-0.5 -right-0.5 w-4.5 h-4.5 bg-[#CC0000] rounded-full border-2 border-white text-[9px] text-white font-bold flex items-center justify-center shadow-sm">
            {unreadCount}
          </span>
        )}
      </button>

      <AnimatePresence>
        {isOpen && (
          <>
            <div className="fixed inset-0 z-[100]" onClick={() => setIsOpen(false)} />
            <motion.div
              initial={{ opacity: 0, y: 15, scale: 0.95 }}
              animate={{ opacity: 1, y: 0, scale: 1 }}
              exit={{ opacity: 0, y: 15, scale: 0.95 }}
              className="absolute right-0 mt-4 w-85 bg-white rounded-2xl shadow-[0_10px_40px_rgba(0,0,0,0.15)] border border-[#EBEBEB] z-[110] overflow-hidden"
            >
              <div className="px-5 py-3 border-b border-[#F0F0F0] bg-[#FAFAFA] flex items-center justify-between">
                <span className="text-[13px] font-bold text-[#111111]">{t("notif.title") || "Notifications"}</span>
                <span className="text-[10px] font-bold text-[#CC0000] bg-[#FFF0F0] px-2 py-0.5 rounded-full">
                  {notifications.length}
                </span>
              </div>
              <div className="max-h-[350px] overflow-y-auto">
                {notifications.length === 0 ? (
                  <div className="p-10 text-center">
                    <Bell className="w-8 h-8 text-[#DDDDDD] mx-auto mb-2" />
                    <p className="text-xs text-[#AAAAAA]">{t("notif.none") || "Aucune notification"}</p>
                  </div>
                ) : (
                  notifications.map((n) => (
                    <div
                      key={n._id}
                      onClick={() => handleNotifClick(n)}
                      className="p-5 border-b border-[#F8F8F8] hover:bg-[#F9F9F9] transition-colors group/item cursor-pointer"
                    >
                      <div className="flex gap-3">
                        {!n.lue && <div className="w-2 h-2 rounded-full bg-[#CC0000] mt-1.5 flex-shrink-0" />}
                        <div className="flex-1">
                          <p className="text-[13px] text-[#333333] leading-relaxed font-medium group-hover/item:text-[#111111]">{n.message}</p>
                          <p className="text-[10px] text-[#AAAAAA] mt-2 font-medium flex items-center gap-1.5">
                            <Clock className="w-3 h-3" />
                            {new Date(n.createdAt).toLocaleDateString()}
                          </p>
                        </div>
                      </div>
                    </div>
                  ))
                )}
              </div>
              <div className="p-3 bg-[#FBFBFB] text-center border-t border-[#F0F0F0]">
                <button onClick={() => setIsOpen(false)} className="text-[11px] font-bold text-[#888888] hover:text-[#555555]">{t("notif.close") || "Fermer"}</button>
              </div>
            </motion.div>
          </>
        )}
      </AnimatePresence>
    </div>
  );
}


/* ============================================================
   HOSPITAL LAYOUT
   ============================================================ */
export function HospitalLayout({ children }: { children: React.ReactNode }) {
  const location = useLocation();
  const { user } = useAuth();
  const { t } = useTranslation();

  const navItems = [
    { icon: LayoutDashboard, labelKey: "nav.hospital.dashboard", path: "/hospital/dashboard" },
    { icon: MessageSquare, labelKey: "nav.shared.messages", path: "/messages" },
    { icon: Stethoscope, labelKey: "nav.hospital.requests", path: "/hospital/requests" },
    { icon: BarChart3, labelKey: "nav.hospital.stats", path: "/hospital/stats" },
    { icon: MapPin, labelKey: "nav.hospital.map", path: "/hospital/map" },
    { icon: Settings, labelKey: "nav.hospital.profile", path: "/hospital/profile" },
  ];

  return (
    <div className="min-h-screen bg-[#F7F7F8] flex flex-col lg:flex-row max-w-[1440px] mx-auto">
      {/* Desktop Sidebar */}
      <aside className="hidden lg:flex flex-col w-[240px] bg-white border-r border-[#EBEBEB] h-screen sticky top-0">
        {/* Logo */}
        <div className="px-6 pt-6 pb-2">
          <Link to="/hospital/dashboard" className="flex items-center gap-2.5">
            <div className="bg-[#CC0000] p-1.5 rounded-lg shadow-sm">
              <Droplet className="text-white w-5 h-5 fill-white" />
            </div>
            <div>
              <span
                className="text-xl font-bold text-[#0A0A0A] leading-none block"
                style={{ fontFamily: "'DM Sans', sans-serif" }}
              >
                SangVie
              </span>
              <span
                className="text-[10px] text-[#888888] font-medium tracking-wide"
                style={{ fontFamily: "'DM Sans', sans-serif" }}
              >
                {t("shared.pro")}
              </span>
            </div>
          </Link>
        </div>

        {/* Verified badge + Notifs */}
        <div className="px-6 py-3 flex items-center justify-between">
          <span className="inline-flex items-center gap-1.5 text-[11px] font-semibold text-[#1A7A3F] bg-[#E8F5EE] px-2.5 py-1 rounded-full border border-[#1A7A3F]/20 tracking-wide">
            <ShieldCheck className="w-3 h-3" />
            {t("hospital.verified_badge")}
          </span>
          <HospitalNotifications />
        </div>

        {/* Nav */}
        <nav className="flex-1 px-3 flex flex-col gap-0.5 mt-2">
          {navItems.map((item) => {
            const isActive = location.pathname.startsWith(item.path);
            return (
              <Link
                key={item.path}
                to={item.path}
                className={`flex items-center gap-3 px-3 py-2.5 rounded-xl transition-all duration-150 group ${isActive
                  ? "bg-[#CC0000] text-white shadow-[0_4px_12px_rgba(204,0,0,0.25)]"
                  : "text-[#555555] hover:bg-[#F7F7F8] hover:text-[#111111]"
                  }`}
                style={{ fontFamily: "'DM Sans', sans-serif" }}
              >
                <item.icon
                  className={`w-4.5 h-4.5 flex-shrink-0 ${isActive ? "text-white" : "text-[#888888] group-hover:text-[#555555]"}`}
                  style={{ width: "18px", height: "18px" }}
                />
                <span className="text-sm font-medium">{t(item.labelKey as any)}</span>
              </Link>
            );
          })}
        </nav>

        {/* Hospital info + Logout */}
        <div className="border-t border-[#EBEBEB] mx-3 pt-3 mb-3">
          {/* Hospital info */}
          <div className="px-2.5 py-2 mb-2">
            <p
              className="text-sm font-semibold text-[#111111] truncate"
              style={{ fontFamily: "'DM Sans', sans-serif" }}
            >
              {user?.nom || t("hospital.default_name")}
            </p>
            <p
              className="text-xs text-[#888888] truncate mt-0.5"
              style={{ fontFamily: "'DM Sans', sans-serif" }}
            >
              {t("hospital.verified_desc")}
            </p>
          </div>
          {/* Logout button */}
          <LogoutButton />
        </div>
      </aside>

      {/* Main */}
      <main className="flex-1 h-screen overflow-y-auto bg-[#F7F7F8] flex flex-col overflow-x-hidden relative">
        <header className="lg:hidden flex items-center justify-between px-5 py-3.5 bg-white border-b border-[#EBEBEB] sticky top-0 z-50 shadow-[0_1px_8px_rgba(0,0,0,0.06)]">
          <Link to="/hospital/dashboard" className="flex items-center gap-2">
            <div className="bg-[#CC0000] p-1 rounded-lg">
              <Droplet className="text-white w-4 h-4 fill-white" />
            </div>
            <span
              className="text-lg font-bold text-[#0A0A0A]"
              style={{ fontFamily: "'DM Sans', sans-serif" }}
            >
              SangVie Pro
            </span>
          </Link>

          <HospitalNotifications />
        </header>

        <div className="p-4 md:p-6 lg:p-8 flex-1 pb-20 lg:pb-8">{children}</div>

        {/* Mobile Bottom Nav */}
        <nav className="lg:hidden fixed bottom-0 left-0 right-0 bg-white border-t border-[#EBEBEB] flex justify-around z-50 shadow-[0_-4px_20px_rgba(0,0,0,0.08)] h-[64px] items-center px-2">
          {navItems.slice(0, 4).map((item) => {
            const isActive = location.pathname.startsWith(item.path);
            return (
              <Link
                key={item.path}
                to={item.path}
                className={`flex flex-col items-center gap-0.5 px-3 py-1.5 rounded-xl transition-all ${isActive ? "text-[#CC0000]" : "text-[#AAAAAA]"
                  }`}
              >
                <div className={`p-1.5 rounded-xl ${isActive ? "bg-[#CC0000]/10" : ""}`}>
                  <item.icon className="w-5 h-5" />
                </div>
                <span
                  className="text-[10px] font-semibold"
                  style={{ fontFamily: "'DM Sans', sans-serif" }}
                >
                  {t(item.labelKey as any)}
                </span>
              </Link>
            );
          })}
        </nav>
      </main>
    </div>
  );
}

/* ============================================================
   ADMIN LAYOUT
   ============================================================ */

const ADMIN_NAV_ITEMS = [
  { icon: LayoutDashboard, labelKey: "nav.admin.dashboard", path: "/admin/dashboard" },
  { icon: Stethoscope, labelKey: "nav.admin.hospitals", path: "/admin/hospitals" },
  { icon: User, labelKey: "nav.admin.users", path: "/admin/users" },
  { icon: BarChart3, labelKey: "nav.admin.reports", path: "/admin/reports" },
];

function AdminSidebarContent({ onLinkClick, user, location, t }: any) {
  return (
    <>
      {/* Logo */}
      <div className="px-6 pt-6 pb-4">
        <Link to="/admin/dashboard" className="flex items-center gap-3" onClick={onLinkClick}>
          <div className="bg-[#CC0000] p-1.5 rounded-lg shadow-[0_4px_12px_rgba(204,0,0,0.3)]">
            <ShieldCheck className="w-5 h-5 text-white" />
          </div>
          <div>
            <span className="text-lg font-bold text-white leading-none block" style={{ fontFamily: "'DM Sans', sans-serif" }}>SangVie</span>
            <span className="text-[10px] text-[#CC0000] font-semibold tracking-widest" style={{ fontFamily: "'DM Sans', sans-serif" }}>ADMIN</span>
          </div>
        </Link>
      </div>

      <div className="mx-6 border-t border-white/10 mb-4" />

      {/* Nav */}
      <nav className="flex-1 px-3 flex flex-col gap-0.5 overflow-y-auto pt-2">
        {ADMIN_NAV_ITEMS.map((item) => {
          const isActive = location.pathname.startsWith(item.path);
          return (
            <Link
              key={item.path}
              to={item.path}
              onClick={onLinkClick}
              className={`flex items-center gap-3 px-3 py-2.5 rounded-xl transition-all duration-150 group ${isActive ? "bg-[#1E1E1E] text-white" : "text-[#999999] hover:bg-[#1A1A1A] hover:text-white"
                }`}
              style={{ fontFamily: "'DM Sans', sans-serif" }}
            >
              <item.icon
                className={`flex-shrink-0 ${isActive ? "text-[#CC0000]" : "text-[#666666] group-hover:text-[#999999]"}`}
                style={{ width: "18px", height: "18px" }}
              />
              <span className="text-sm font-medium">{t(item.labelKey as any)}</span>
              {isActive && <div className="ml-auto w-1.5 h-1.5 rounded-full bg-[#CC0000]" />}
            </Link>
          );
        })}
      </nav>

      {/* Admin user + Logout */}
      <div className="px-4 mb-6 mt-auto pt-6 border-t border-white/10 relative z-20">
        <div className="flex items-center gap-3 p-3 rounded-xl bg-[#1A1A1A] border border-[#252525] mb-2">
          <div className="w-9 h-9 rounded-xl bg-gradient-to-br from-[#CC0000] to-[#990000] flex items-center justify-center text-white text-sm font-bold flex-shrink-0 shadow-lg">
            {user?.nom?.split(" ")?.map((n: string) => n[0])?.join("")?.slice(0, 2) || "A"}
          </div>
          <div className="flex-1 truncate">
            <p className="text-sm font-bold text-white truncate" style={{ fontFamily: "'DM Sans', sans-serif" }}>{user?.nom || "Admin"}</p>
            <p className="text-[10px] text-white/40 uppercase tracking-widest font-bold mt-0.5" style={{ fontFamily: "'DM Sans', sans-serif" }}>{t("nav.admin.role")}</p>
          </div>
        </div>
        <LogoutButton dark />
      </div>
    </>
  );
}

export function AdminLayout({ children }: { children: React.ReactNode }) {
  const location = useLocation();
  const { user } = useAuth();
  const { t } = useTranslation();
  const [isSidebarOpen, setIsSidebarOpen] = useState(false);

  return (
    <div className="min-h-screen bg-[#F7F7F8] flex flex-col md:flex-row max-w-[1440px] mx-auto relative overflow-x-hidden">

      {/* Mobile Header */}
      <header className="md:hidden bg-white border-b border-[#EBEBEB] px-5 py-3 flex items-center justify-between sticky top-0 z-40 shadow-sm">
        <Link to="/admin/dashboard" className="flex items-center gap-2">
          <div className="bg-[#CC0000] p-1.5 rounded-lg">
            <ShieldCheck className="w-4 h-4 text-white" />
          </div>
          <span className="text-lg font-bold text-[#0A0A0A]">SangVie</span>
        </Link>
        <button onClick={() => setIsSidebarOpen(true)} className="p-2 rounded-xl bg-[#F5F5F7] text-[#444444]">
          <Menu className="w-5 h-5" />
        </button>
      </header>

      {/* Mobile Sidebar (Drawer) */}
      <AnimatePresence>
        {isSidebarOpen && (
          <>
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              onClick={() => setIsSidebarOpen(false)}
              className="fixed inset-0 bg-black/60 z-[100] md:hidden backdrop-blur-sm"
            />
            <motion.aside
              initial={{ x: "-100%" }}
              animate={{ x: 0 }}
              exit={{ x: "-100%" }}
              transition={{ type: "spring", damping: 25, stiffness: 200 }}
              className="fixed inset-y-0 left-0 w-[240px] bg-[#111111] z-[101] flex flex-col md:hidden"
            >
              <div className="flex justify-end p-4">
                <button onClick={() => setIsSidebarOpen(false)} className="text-[#666666] p-1">
                  <X className="w-6 h-6" />
                </button>
              </div>
            <AdminSidebarContent 
              onLinkClick={() => setIsSidebarOpen(false)} 
              user={user} 
              location={location} 
              t={t} 
            />
          </motion.aside>
        </>
      )}
    </AnimatePresence>

      {/* Desktop Sidebar */}
      <aside className="hidden md:flex flex-col w-[260px] bg-[#0A0A0A] border-r border-white/5 h-screen sticky top-0 shadow-2xl z-50">
        <AdminSidebarContent user={user} location={location} t={t} />
      </aside>

      {/* Main */}
      <main className="flex-1 h-screen overflow-y-auto bg-[#F7F7F8] relative">
        {/* Desktop Top bar */}
        <div className="hidden md:flex bg-white border-b border-[#EBEBEB] px-8 py-4 items-center justify-between sticky top-0 z-10 shadow-[0_1px_6px_rgba(0,0,0,0.04)]">
          <div>
            <p className="text-xs text-[#888888] font-medium uppercase tracking-wider" style={{ fontFamily: "'DM Sans', sans-serif" }}>{t("nav.admin.title")}</p>
            <p className="text-sm font-semibold text-[#111111]" style={{ fontFamily: "'DM Sans', sans-serif" }}>{t("nav.admin.view")}</p>
          </div>
          <div className="flex items-center gap-3">
            <AdminNotifications />
          </div>
        </div>
        <div className="p-4 md:p-8">{children}</div>
      </main>
    </div>
  );
}
