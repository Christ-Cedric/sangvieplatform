import React, { useState } from "react";
import { Link, useNavigate } from "react-router";
import { PublicLayout } from "../../components/layouts";
import { Button, Input } from "../../components/ui";
import { motion, AnimatePresence } from "motion/react";
import { useTranslation } from "../../i18n";
import { Droplet, Building2, User, Eye, EyeOff, ArrowRight, CheckCircle2, AlertCircle } from "lucide-react";
import { registerUserApi, registerHospitalApi } from "../../api";
import { useAuth, getRoleHome } from "../../AuthContext";
import bloodBagImage from "../../../blood-bag.png";

type UserType = "donor" | "hospital";
const BLOOD_GROUPS = ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"];

export function Register() {
  const navigate = useNavigate();
  const { t } = useTranslation();
  const { login } = useAuth();

  const [userType, setUserType] = useState<UserType>("donor");
  const [showPassword, setShowPassword] = useState(false);
  const [selectedBloodGroup, setSelectedBloodGroup] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const [isSuccess, setIsSuccess] = useState(false);
  const [error, setError] = useState("");

  const [formData, setFormData] = useState({
    fullName: "",      // nom + prenom (on split par le premier espace)
    phone: "",         // telephone (donor) / contact (hospital)
    email: "",
    password: "",
    confirmPassword: "",
    hospitalName: "",
    hospitalId: "",    // numeroAgrement
    region: "",
    location: "",      // localisation
  });

  const handleChange = (field: string, value: string) => {
    setFormData((prev) => ({ ...prev, [field]: value }));
    setError("");
  };

  const handleTypeChange = (type: UserType) => {
    setUserType(type);
    setFormData({ fullName: "", phone: "", email: "", password: "", confirmPassword: "", hospitalName: "", hospitalId: "", region: "", location: "" });
    setSelectedBloodGroup("");
    setError("");
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (isLoading) return;

    // Validation
    if (formData.password !== formData.confirmPassword) {
      setError(t("auth.register.error_password_match"));
      return;
    }
    if (formData.password.length < 6) {
      setError(t("auth.register.error_password_length"));
      return;
    }
    if (userType === "donor" && !selectedBloodGroup) {
      setError(t("auth.register.error_blood_group"));
      return;
    }

    setIsLoading(true);
    setError("");

    try {
      if (userType === "donor") {
        const nameParts = formData.fullName.trim().split(" ");
        const prenom = nameParts[0] ?? "";
        const nom = nameParts.slice(1).join(" ") || prenom;
        const data = await registerUserApi({
          nom,
          prenom,
          email: formData.email,
          motDePasse: formData.password,
          telephone: formData.phone.replace(/\s/g, ""),
          lieuResidence: formData.location || t("auth.register.not_provided"),
          groupeSanguin: selectedBloodGroup,
        });
        login(data);
        navigate(getRoleHome(data.role), { replace: true });
      } else {
        await registerHospitalApi({
          nom: formData.hospitalName,
          email: formData.email,
          motDePasse: formData.password,
          numeroAgrement: formData.hospitalId,
          contact: formData.phone.replace(/\s/g, ""),
          region: formData.region || t("auth.register.not_provided"),
          localisation: formData.location || t("auth.register.not_provided"),
        });
        setIsSuccess(true);
      }
    } catch (err: any) {
      setError(err.message ?? t("auth.login.error_default"));
    } finally {
      setIsLoading(false);
    }
  };

  if (isSuccess) {
    return (
      <PublicLayout>
        <div className="flex-1 flex items-center justify-center p-6 bg-[#F7F7F8]">
          <motion.div 
            initial={{ scale: 0.9, opacity: 0 }}
            animate={{ scale: 1, opacity: 1 }}
            className="w-full max-w-md bg-white p-8 rounded-3xl shadow-xl text-center border border-[#EBEBEB]"
          >
            <div className="w-20 h-20 bg-[#F0FFF4] rounded-full flex items-center justify-center mx-auto mb-6">
              <CheckCircle2 className="w-10 h-10 text-[#1A7A3F]" />
            </div>
            <h2 className="text-[24px] font-bold text-[#0A0A0A] mb-3" style={{ fontFamily: "'DM Sans', sans-serif" }}>
              {t("auth.register.successTitle")}
            </h2>
            <p className="text-[15px] text-[#666666] mb-8 leading-relaxed" style={{ fontFamily: "'DM Sans', sans-serif" }}>
              {t("auth.register.successHospital", { name: formData.hospitalName })}
            </p>
            <Link to="/login">
              <Button className="w-full h-12">
                {t("auth.register.backToLogin")}
              </Button>
            </Link>
          </motion.div>
        </div>
      </PublicLayout>
    );
  }

  return (
    <PublicLayout>
      <div className="flex-1 flex min-h-[calc(100vh-64px)]">

        {/* ── Left — image panel ─────────────────────── */}
        <div className="hidden lg:flex flex-col justify-between w-[40%] relative overflow-hidden p-12">
          <img src={bloodBagImage} alt="Poche de sang" className="absolute inset-0 w-full h-full object-cover" />
          <div className="absolute inset-0 bg-gradient-to-br from-black/75 via-[#CC0000]/50 to-black/80" />
          <div className="absolute inset-0 bg-gradient-to-t from-black/60 via-transparent to-black/20" />

          <div className="relative z-10">
            <div className="bg-[#CC0000] p-2 rounded-xl inline-flex mb-6 shadow-[0_4px_20px_rgba(204,0,0,0.5)]">
              <Droplet className="w-6 h-6 text-white fill-white" />
            </div>
            <h2 className="text-[38px] font-bold text-white leading-tight mb-4 drop-shadow-lg" style={{ fontFamily: "'DM Sans', sans-serif" }}>
              {t("landing.register.title").split('{br}').map((text, i) => (
                <React.Fragment key={i}>
                  {text}
                  {i === 0 && <br />}
                </React.Fragment>
              ))}
            </h2>
            <p className="text-white/80 text-[14px] leading-relaxed max-w-[280px]" style={{ fontFamily: "'DM Sans', sans-serif" }}>
              {t("landing.register.description")}
            </p>
          </div>

          <div className="relative z-10 space-y-3">
            {[ t("landing.register.benefit1"), t("landing.register.benefit2"), t("landing.register.benefit3"), t("landing.register.benefit4") ].map((benefit, i) => (
              <div key={i} className="flex items-center gap-3">
                <div className="w-5 h-5 rounded-full bg-white/20 border border-white/30 flex items-center justify-center flex-shrink-0">
                  <CheckCircle2 className="w-3 h-3 text-white" />
                </div>
                <p className="text-white/90 text-[13px]" style={{ fontFamily: "'DM Sans', sans-serif" }}>{benefit}</p>
              </div>
            ))}
          </div>
        </div>

        {/* ── Right — form ───────────────────────────── */}
        <div className="flex-1 flex items-start justify-center p-6 py-10 bg-[#F7F7F8] overflow-y-auto">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5 }}
            className="w-full max-w-[440px]"
          >
            {/* Header */}
            <div className="mb-7">
              <h1 className="text-[26px] font-bold text-[#0A0A0A] mb-1" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                {t("auth.register.title")}
              </h1>
              <p className="text-[14px] text-[#888888]" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                {t("auth.register.subtitle")}
              </p>
            </div>

            {/* Type selector */}
            <div className="flex gap-3 mb-7">
              {([
                { type: "donor" as const, label: t("auth.register.donorTab"), Icon: User },
                { type: "hospital" as const, label: t("auth.register.hospitalTab"), Icon: Building2 },
              ]).map(({ type, label, Icon }) => (
                <button
                  key={type}
                  type="button"
                  onClick={() => handleTypeChange(type)}
                  className={`flex-1 flex items-center justify-center gap-2 py-3 px-4 rounded-xl border-2 text-sm font-semibold transition-all ${
                    userType === type
                      ? "border-[#CC0000] bg-[#FFF0F0] text-[#CC0000]"
                      : "border-[#E0E0E0] bg-white text-[#888888] hover:border-[#CCCCCC]"
                  }`}
                  style={{ fontFamily: "'DM Sans', sans-serif" }}
                >
                  <Icon className="w-4 h-4" />
                  {label}
                </button>
              ))}
            </div>

            {/* Form */}
            <form onSubmit={handleSubmit} className="space-y-4">
              <AnimatePresence mode="wait">
                <motion.div
                  key={userType}
                  initial={{ opacity: 0, x: -8 }}
                  animate={{ opacity: 1, x: 0 }}
                  exit={{ opacity: 0, x: 8 }}
                  transition={{ duration: 0.18 }}
                  className="space-y-4"
                >
                  {userType === "hospital" ? (
                    <>
                      <div>
                        <label className="block text-sm font-semibold text-[#333333] mb-1.5" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                          {t("auth.register.hospitalName")}
                        </label>
                        <Input type="text" placeholder={t("auth.register.hospitalNamePlaceholder")} value={formData.hospitalName} onChange={(e) => handleChange("hospitalName", e.target.value)} required />
                      </div>
                      <div>
                        <label className="block text-sm font-semibold text-[#333333] mb-1.5" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                          {t("auth.register.hospitalId")}
                          <span className="ml-1 text-[11px] font-normal text-[#AAAAAA]">{t("auth.register.hospitalIdHint")}</span>
                        </label>
                        <Input type="text" placeholder={t("auth.register.hospitalIdPlaceholder")} value={formData.hospitalId} onChange={(e) => handleChange("hospitalId", e.target.value)} required />
                      </div>
                      <div>
                        <label className="block text-sm font-semibold text-[#333333] mb-1.5" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                          {t("auth.register.phoneContact")}
                        </label>
                        <Input type="tel" placeholder={t("auth.register.phonePlaceholder")} value={formData.phone} onChange={(e) => handleChange("phone", e.target.value)} required />
                      </div>
                      <div>
                        <label className="block text-sm font-semibold text-[#333333] mb-1.5" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                          {t("auth.register.hospitalEmail")}
                        </label>
                        <Input type="email" placeholder={t("auth.register.hospitalEmailPlaceholder")} value={formData.email} onChange={(e) => handleChange("email", e.target.value)} required />
                      </div>
                    </>
                  ) : (
                    <>
                      <div>
                        <label className="block text-sm font-semibold text-[#333333] mb-1.5" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                          {t("auth.register.fullName")}
                        </label>
                        <Input type="text" placeholder={t("auth.register.fullNamePlaceholder")} value={formData.fullName} onChange={(e) => handleChange("fullName", e.target.value)} required />
                      </div>
                      <div>
                        <label className="block text-sm font-semibold text-[#333333] mb-1.5" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                          {t("auth.register.phone")}
                        </label>
                        <Input type="tel" placeholder={t("auth.register.phonePlaceholder")} value={formData.phone} onChange={(e) => handleChange("phone", e.target.value)} required />
                      </div>
                      <div>
                        <label className="block text-sm font-semibold text-[#333333] mb-1.5" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                          {t("auth.register.email")}
                        </label>
                        <Input type="email" placeholder={t("auth.register.emailPlaceholder")} value={formData.email} onChange={(e) => handleChange("email", e.target.value)} required />
                      </div>

                      {/* Blood group */}
                      <div>
                        <label className="block text-sm font-semibold text-[#333333] mb-2" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                          {t("auth.register.bloodGroup")}
                        </label>
                        <div className="grid grid-cols-4 gap-2">
                          {BLOOD_GROUPS.map((group) => (
                            <button
                              key={group}
                              type="button"
                              onClick={() => setSelectedBloodGroup(group)}
                              className={`h-10 rounded-xl border-2 text-sm font-bold transition-all ${
                                selectedBloodGroup === group
                                  ? "border-[#CC0000] bg-[#CC0000] text-white shadow-[0_2px_8px_rgba(204,0,0,0.3)]"
                                  : "border-[#E0E0E0] bg-white text-[#333333] hover:border-[#CC0000]/50"
                              }`}
                              style={{ fontFamily: "'DM Sans', sans-serif" }}
                            >
                              {group}
                            </button>
                          ))}
                        </div>
                      </div>
                    </>
                  )}

                  {/* Password */}
                  <div>
                    <label className="block text-sm font-semibold text-[#333333] mb-1.5" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                      {t("auth.register.password")}
                    </label>
                    <div className="relative">
                      <Input type={showPassword ? "text" : "password"} placeholder={t("auth.register.passwordHint")} value={formData.password} onChange={(e) => handleChange("password", e.target.value)} required />
                      <button type="button" onClick={() => setShowPassword(!showPassword)} className="absolute right-3.5 top-1/2 -translate-y-1/2 text-[#BBBBBB] hover:text-[#888888]">
                        {showPassword ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                      </button>
                    </div>
                  </div>

                  <div>
                    <label className="block text-sm font-semibold text-[#333333] mb-1.5" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                      {t("auth.register.passwordConfirm")}
                    </label>
                    <Input type={showPassword ? "text" : "password"} placeholder={t("auth.register.placeholder_confirm_password")} value={formData.confirmPassword} onChange={(e) => handleChange("confirmPassword", e.target.value)} required />
                  </div>
                </motion.div>
              </AnimatePresence>

              {/* Hospital notice */}
              {userType === "hospital" && (
                <motion.div
                  initial={{ opacity: 0 }}
                  animate={{ opacity: 1 }}
                  className="flex gap-2.5 bg-[#FFF8F0] border border-[#D4720B]/20 rounded-xl p-3.5"
                >
                  <Building2 className="w-4 h-4 text-[#D4720B] flex-shrink-0 mt-0.5" />
                  <p className="text-[12px] text-[#D4720B] leading-relaxed" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                    {t("auth.register.hospitalNotice")}
                  </p>
                </motion.div>
              )}

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

              {/* Submit */}
              <button
                type="submit"
                disabled={isLoading}
                className="w-full h-12 bg-[#CC0000] text-white font-semibold text-[15px] rounded-xl shadow-[0_4px_14px_rgba(204,0,0,0.35)] hover:bg-[#B00000] hover:-translate-y-0.5 active:scale-[0.98] transition-all flex items-center justify-center gap-2 disabled:opacity-70 disabled:pointer-events-none mt-2"
                style={{ fontFamily: "'DM Sans', sans-serif" }}
              >
                {isLoading ? (
                  <svg className="animate-spin w-5 h-5" fill="none" viewBox="0 0 24 24">
                    <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" />
                    <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z" />
                  </svg>
                ) : (
                  <>{t("auth.register.submit")}<ArrowRight className="w-4 h-4" /></>
                )}
              </button>
            </form>

            <p className="mt-6 text-center text-[13px] text-[#888888]" style={{ fontFamily: "'DM Sans', sans-serif" }}>
              {t("auth.register.already")}{" "}
              <Link to="/login" className="text-[#CC0000] font-semibold hover:underline">{t("auth.register.login")}</Link>
            </p>
          </motion.div>
        </div>
      </div>
    </PublicLayout>
  );
}
