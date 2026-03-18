import React, { useState } from "react";
import { Link, useNavigate } from "react-router";
import { PublicLayout } from "../../components/layouts";
import { useTranslation } from "../../i18n";
import { Droplet, Eye, EyeOff, ArrowRight, Phone, Mail, AlertCircle } from "lucide-react";
import { motion, AnimatePresence } from "motion/react";
import { loginApi } from "../../api";
import { useAuth, getRoleHome } from "../../AuthContext";

// ── Types helpers ─────────────────────────────────────────────────────────────

// ── Composant ─────────────────────────────────────────────────────────────────

export function UnifiedLogin() {
  const [identifier, setIdentifier] = useState("");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const navigate = useNavigate();
  const { t } = useTranslation();
  const { login } = useAuth();

  const isPhone = /^\+?[\d\s]+$/.test(identifier) && identifier.length > 0;
  const isEmail = identifier.includes("@");

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    if (isLoading) return;
    setError("");
    setIsLoading(true);

    try {
      // Normalisation : on nettoie les espaces pour les numéros de téléphone potentiels
      // mais on garde le format tel quel si c'est un email ou username
      const cleanId = identifier.trim();
      const data = await loginApi({ 
        identifier: cleanId, 
        motDePasse: password 
      });
      
      login(data);                          // Sauvegarde JWT + user en localStorage
      navigate(getRoleHome(data.role), { replace: true });
    } catch (err: any) {
      setError(err.message ?? t("auth.login.error_default"));
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <PublicLayout>
      <div className="flex-1 flex min-h-[calc(100vh-64px)]">

        {/* ── Left panel — branding ─────────────────── */}
        <div className="hidden lg:flex flex-col justify-between w-[45%] bg-[#CC0000] p-12 relative overflow-hidden">
          <div className="absolute -top-24 -right-24 w-[400px] h-[400px] rounded-full bg-white/5" />
          <div className="absolute -bottom-16 -left-16 w-[300px] h-[300px] rounded-full bg-black/10" />

          <div className="relative z-10">
            <Droplet className="w-10 h-10 text-white fill-white mb-6" />
            <h2 className="text-[40px] font-bold text-white leading-tight mb-4" style={{ fontFamily: "'DM Sans', sans-serif" }}>
              {t("landing.welcome.title").split('{br}').map((text, i) => (
                <React.Fragment key={i}>
                  {text}
                  {i === 0 && <br />}
                </React.Fragment>
              ))}
            </h2>
            <p className="text-white/70 text-[15px] leading-relaxed max-w-[300px]" style={{ fontFamily: "'DM Sans', sans-serif" }}>
              {t("landing.welcome.description")}
            </p>
          </div>

          <div className="relative z-10 grid grid-cols-2 gap-4">
            {[
              { value: "8 900+", label: t("landing.stats.activeDonors") },
              { value: "1 240",  label: t("landing.stats.donationsMonth") },
              { value: "42",     label: t("landing.stats.partnerHospitals") },
              { value: "89%",    label: t("landing.stats.responseRate") },
            ].map((s, i) => (
              <div key={i} className="bg-white/10 rounded-xl p-4 border border-white/10">
                <p className="text-[22px] font-bold text-white" style={{ fontFamily: "'DM Sans', sans-serif" }}>{s.value}</p>
                <p className="text-white/60 text-[12px] font-medium" style={{ fontFamily: "'DM Sans', sans-serif" }}>{s.label}</p>
              </div>
            ))}
          </div>
        </div>

        {/* ── Right panel — form ────────────────────── */}
        <div className="flex-1 flex items-center justify-center p-6 py-10 bg-[#F7F7F8]">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5 }}
            className="w-full max-w-[420px]"
          >
            {/* Header */}
            <div className="mb-8">
              <h1 className="text-[28px] font-bold text-[#0A0A0A] mb-1" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                {t("auth.login.title")}
              </h1>
              <p className="text-[14px] text-[#888888]" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                {t("auth.login.subtitle")}
              </p>
            </div>

            {/* Form */}
            <form onSubmit={handleLogin} className="space-y-4">
              {/* Identifier */}
              <div>
                <label className="block text-sm font-semibold text-[#333333] mb-1.5" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                  {t("auth.login.identifier")}
                </label>
                <div className="relative">
                  <div className="absolute left-3.5 top-1/2 -translate-y-1/2 text-[#BBBBBB]">
                    {isPhone ? <Phone className="w-4 h-4" /> : isEmail ? <Mail className="w-4 h-4" /> : (
                      <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                      </svg>
                    )}
                  </div>
                  <input
                    type="text"
                    placeholder={t("auth.login.identifier_placeholder")}
                    value={identifier}
                    onChange={(e) => { setIdentifier(e.target.value); setError(""); }}
                    required
                    autoComplete="username"
                    className={`w-full h-11 pl-10 pr-4 rounded-xl border text-sm text-[#111111] placeholder:text-[#BDBDBD] bg-white transition-all focus:outline-none focus:ring-4 ${
                      error ? "border-[#FF0000] focus:border-[#FF0000] focus:ring-[#FF0000]/10" : "border-[#E0E0E0] focus:border-[#CC0000] focus:ring-[#CC0000]/10"
                    }`}
                    style={{ fontFamily: "'DM Sans', sans-serif" }}
                  />
                </div>
              </div>

              {/* Password */}
              <div>
                <label className="block text-sm font-semibold text-[#333333] mb-1.5" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                  {t("auth.login.password")}
                </label>
                <div className="relative">
                  <input
                    type={showPassword ? "text" : "password"}
                    placeholder={t("auth.login.password_placeholder")}
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    required
                    autoComplete="current-password"
                    className="w-full h-11 pl-4 pr-10 rounded-xl border border-[#E0E0E0] text-sm text-[#111111] placeholder:text-[#BDBDBD] bg-white transition-all focus:outline-none focus:border-[#CC0000] focus:ring-4 focus:ring-[#CC0000]/10"
                    style={{ fontFamily: "'DM Sans', sans-serif" }}
                  />
                  <button
                    type="button"
                    onClick={() => setShowPassword(!showPassword)}
                    className="absolute right-3.5 top-1/2 -translate-y-1/2 text-[#BBBBBB] hover:text-[#888888] transition-colors"
                  >
                    {showPassword ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                  </button>
                </div>
              </div>

              {/* Error */}
              <AnimatePresence>
                {error && (
                  <motion.div
                    initial={{ opacity: 0, height: 0 }}
                    animate={{ opacity: 1, height: "auto" }}
                    exit={{ opacity: 0, height: 0 }}
                    className="flex items-center gap-2 bg-[#FFF0F0] border border-[#FF0000]/20 text-[#CC0000] text-[13px] px-3 py-2.5 rounded-xl overflow-hidden"
                    style={{ fontFamily: "'DM Sans', sans-serif" }}
                  >
                    <AlertCircle className="w-4 h-4 flex-shrink-0" />
                    {error}
                  </motion.div>
                )}
              </AnimatePresence>

              {/* Forgot */}
              <div className="flex justify-end">
                <Link to="/forgot-password" className="text-[13px] font-medium text-[#CC0000] hover:underline" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                  {t("auth.login.forgot")}
                </Link>
              </div>

              {/* Submit */}
              <button
                type="submit"
                disabled={isLoading}
                className="w-full h-12 bg-[#CC0000] text-white font-semibold text-[15px] rounded-xl shadow-[0_4px_14px_rgba(204,0,0,0.35)] hover:bg-[#B00000] hover:-translate-y-0.5 active:scale-[0.98] transition-all flex items-center justify-center gap-2 disabled:opacity-70 disabled:pointer-events-none"
                style={{ fontFamily: "'DM Sans', sans-serif" }}
              >
                {isLoading ? (
                  <svg className="animate-spin w-5 h-5 text-white" fill="none" viewBox="0 0 24 24">
                    <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" />
                    <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z" />
                  </svg>
                ) : (
                  <>{t("auth.login.submit")}<ArrowRight className="w-4 h-4" /></>
                )}
              </button>
            </form>

            <p className="mt-6 text-center text-[13px] text-[#888888]" style={{ fontFamily: "'DM Sans', sans-serif" }}>
              {t("auth.login.noAccount")}{" "}
              <Link to="/register" className="text-[#CC0000] font-semibold hover:underline">
                {t("auth.login.createAccount")}
              </Link>
            </p>
          </motion.div>
        </div>
      </div>
    </PublicLayout>
  );
}
