import React, { useState } from "react";
import { Link, useNavigate } from "react-router";
import { PublicLayout } from "../../components/layouts";
import { Button, Input } from "../../components/ui";
import { motion, AnimatePresence } from "motion/react";
import { useTranslation } from "../../i18n";
import { 
  Droplet, 
  Building2, 
  User, 
  Eye, 
  EyeOff, 
  ArrowRight, 
  CheckCircle2, 
  AlertCircle,
  ChevronRight,
  Phone,
  Mail,
  MapPin,
  FileText,
  Hash
} from "lucide-react";
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
    fullName: "",
    phone: "",
    email: "",
    password: "",
    confirmPassword: "",
    hospitalName: "",
    hospitalId: "",
    region: "",
    location: "",
  });

  const handleChange = (field: string, value: string) => {
    setFormData((prev) => ({ ...prev, [field]: value }));
    setError("");
  };

  const handleTypeChange = (type: UserType) => {
    setUserType(type);
    setFormData({ 
      fullName: "", 
      phone: "", 
      email: "", 
      password: "", 
      confirmPassword: "", 
      hospitalName: "", 
      hospitalId: "", 
      region: "", 
      location: "" 
    });
    setSelectedBloodGroup("");
    setError("");
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (isLoading) return;

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
        <div className="min-h-screen flex items-center justify-center p-4 bg-gradient-to-br from-[#F7F7F8] to-[#EFEFEF]">
          <motion.div 
            initial={{ scale: 0.9, opacity: 0, y: 20 }}
            animate={{ scale: 1, opacity: 1, y: 0 }}
            transition={{ type: "spring", duration: 0.6 }}
            className="w-full max-w-md bg-white/90 backdrop-blur-sm p-8 md:p-10 rounded-3xl shadow-2xl text-center border border-white/50"
          >
            <motion.div 
              initial={{ scale: 0 }}
              animate={{ scale: 1 }}
              transition={{ delay: 0.2, type: "spring" }}
              className="w-20 h-20 bg-green-50 rounded-full flex items-center justify-center mx-auto mb-6"
            >
              <CheckCircle2 className="w-10 h-10 text-green-600" />
            </motion.div>
            <h2 className="text-2xl md:text-3xl font-bold text-gray-900 mb-3">
              {t("auth.register.successTitle")}
            </h2>
            <p className="text-sm md:text-base text-gray-600 mb-8 leading-relaxed">
              {t("auth.register.successHospital", { name: formData.hospitalName })}
            </p>
            <Link to="/login">
              <Button className="w-full h-12 bg-red-600 hover:bg-red-700 text-white rounded-xl shadow-lg hover:shadow-xl transition-all">
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
      <div className="flex flex-col lg:flex-row min-h-screen bg-[#F7F7F8]">

        {/* Left Panel - Hero Section (Hidden on mobile) */}
        <div className="hidden lg:flex lg:w-[45%] xl:w-[40%] relative overflow-hidden bg-gradient-to-br from-red-600 to-red-700">
          {/* Background Image with Overlay */}
          <div className="absolute inset-0">
            <img 
              src={bloodBagImage} 
              alt="Blood donation" 
              className="w-full h-full object-cover opacity-20"
            />
            <div className="absolute inset-0 bg-gradient-to-br from-red-600/90 via-red-700/85 to-red-800/90" />
          </div>

          {/* Content */}
          <div className="relative z-10 flex flex-col justify-between w-full p-12 text-white">
            <div>
              <motion.div 
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                className="bg-white/10 backdrop-blur-sm p-3 rounded-2xl inline-flex mb-8 border border-white/20"
              >
                <Droplet className="w-8 h-8 text-white" />
              </motion.div>
              
              <motion.h2 
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.1 }}
                className="text-4xl xl:text-5xl font-bold leading-tight mb-6"
              >
                {t("landing.register.title").split('{br}').map((text, i) => (
                  <React.Fragment key={i}>
                    {text}
                    {i === 0 && <br />}
                  </React.Fragment>
                ))}
              </motion.h2>
              
              <motion.p 
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.2 }}
                className="text-white/80 text-base leading-relaxed max-w-md mb-12"
              >
                {t("landing.register.description")}
              </motion.p>
            </div>

            <motion.div 
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.3 }}
              className="space-y-4"
            >
              {[
                t("landing.register.benefit1"),
                t("landing.register.benefit2"),
                t("landing.register.benefit3"),
                t("landing.register.benefit4")
              ].map((benefit, i) => (
                <motion.div 
                  key={i}
                  initial={{ opacity: 0, x: -20 }}
                  animate={{ opacity: 1, x: 0 }}
                  transition={{ delay: 0.4 + i * 0.1 }}
                  className="flex items-center gap-3 group"
                >
                  <div className="w-6 h-6 rounded-full bg-white/20 border border-white/30 flex items-center justify-center flex-shrink-0 group-hover:bg-white/30 transition-colors">
                    <CheckCircle2 className="w-3.5 h-3.5 text-white" />
                  </div>
                  <p className="text-white/90 text-sm">{benefit}</p>
                </motion.div>
              ))}
            </motion.div>
          </div>
        </div>

        {/* Right Panel - Form */}
        <div className="flex-1 flex items-start justify-center p-4 md:p-6 lg:p-8 xl:p-12 bg-gradient-to-br from-[#F7F7F8] to-[#EFEFEF]">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5 }}
            className="w-full max-w-[480px] bg-white rounded-2xl md:rounded-3xl shadow-xl p-6 md:p-8 border border-gray-100"
          >
            {/* Header */}
            <div className="mb-6 md:mb-8">
              <h1 className="text-2xl md:text-3xl font-bold text-gray-900 mb-2">
                {t("auth.register.title")}
              </h1>
              <p className="text-sm md:text-base text-gray-500">
                {t("auth.register.subtitle")}
              </p>
            </div>

            {/* Type Selector */}
            <div className="grid grid-cols-2 gap-2 md:gap-3 mb-6 md:mb-8">
              {([
                { type: "donor" as const, label: t("auth.register.donorTab"), Icon: User },
                { type: "hospital" as const, label: t("auth.register.hospitalTab"), Icon: Building2 },
              ]).map(({ type, label, Icon }) => (
                <button
                  key={type}
                  type="button"
                  onClick={() => handleTypeChange(type)}
                  className={`
                    relative overflow-hidden group
                    flex items-center justify-center gap-2 
                    py-3 md:py-4 px-3 md:px-4 
                    rounded-xl md:rounded-2xl 
                    text-sm md:text-base font-semibold
                    transition-all duration-300
                    ${userType === type
                      ? "bg-red-600 text-white shadow-lg shadow-red-600/25"
                      : "bg-gray-50 text-gray-600 hover:bg-gray-100 border border-gray-200"
                    }
                  `}
                >
                  <Icon className={`w-4 h-4 md:w-5 md:h-5 transition-transform group-hover:scale-110 ${userType === type ? "text-white" : "text-gray-500"}`} />
                  <span className="relative z-10">{label}</span>
                  {userType === type && (
                    <motion.div
                      layoutId="activeTab"
                      className="absolute inset-0 bg-red-600"
                      initial={false}
                      transition={{ type: "spring", duration: 0.5 }}
                    />
                  )}
                </button>
              ))}
            </div>

            {/* Form */}
            <form onSubmit={handleSubmit} className="space-y-4 md:space-y-5">
              <AnimatePresence mode="wait">
                <motion.div
                  key={userType}
                  initial={{ opacity: 0, x: -20 }}
                  animate={{ opacity: 1, x: 0 }}
                  exit={{ opacity: 0, x: 20 }}
                  transition={{ duration: 0.2 }}
                  className="space-y-4 md:space-y-5"
                >
                  {userType === "hospital" ? (
                    <>
                      {/* Hospital Fields */}
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1.5">
                          {t("auth.register.hospitalName")}
                        </label>
                        <div className="relative">
                          <Building2 className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
                          <Input 
                            type="text" 
                            placeholder={t("auth.register.hospitalNamePlaceholder")} 
                            value={formData.hospitalName} 
                            onChange={(e) => handleChange("hospitalName", e.target.value)} 
                            required 
                            className="pl-10"
                          />
                        </div>
                      </div>

                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1.5">
                          {t("auth.register.hospitalId")}
                          <span className="ml-2 text-xs text-gray-400 font-normal">
                            {t("auth.register.hospitalIdHint")}
                          </span>
                        </label>
                        <div className="relative">
                          <Hash className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
                          <Input 
                            type="text" 
                            placeholder={t("auth.register.hospitalIdPlaceholder")} 
                            value={formData.hospitalId} 
                            onChange={(e) => handleChange("hospitalId", e.target.value)} 
                            required 
                            className="pl-10"
                          />
                        </div>
                      </div>

                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1.5">
                          {t("auth.register.phoneContact")}
                        </label>
                        <div className="relative">
                          <Phone className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
                          <Input 
                            type="tel" 
                            placeholder={t("auth.register.phonePlaceholder")} 
                            value={formData.phone} 
                            onChange={(e) => handleChange("phone", e.target.value)} 
                            required 
                            className="pl-10"
                          />
                        </div>
                      </div>

                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1.5">
                          {t("auth.register.hospitalEmail")}
                        </label>
                        <div className="relative">
                          <Mail className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
                          <Input 
                            type="email" 
                            placeholder={t("auth.register.hospitalEmailPlaceholder")} 
                            value={formData.email} 
                            onChange={(e) => handleChange("email", e.target.value)} 
                            required 
                            className="pl-10"
                          />
                        </div>
                      </div>
                    </>
                  ) : (
                    <>
                      {/* Donor Fields */}
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1.5">
                          {t("auth.register.fullName")}
                        </label>
                        <div className="relative">
                          <User className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
                          <Input 
                            type="text" 
                            placeholder={t("auth.register.fullNamePlaceholder")} 
                            value={formData.fullName} 
                            onChange={(e) => handleChange("fullName", e.target.value)} 
                            required 
                            className="pl-10"
                          />
                        </div>
                      </div>

                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1.5">
                          {t("auth.register.phone")}
                        </label>
                        <div className="relative">
                          <Phone className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
                          <Input 
                            type="tel" 
                            placeholder={t("auth.register.phonePlaceholder")} 
                            value={formData.phone} 
                            onChange={(e) => handleChange("phone", e.target.value)} 
                            required 
                            className="pl-10"
                          />
                        </div>
                      </div>

                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1.5">
                          {t("auth.register.email")}
                        </label>
                        <div className="relative">
                          <Mail className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
                          <Input 
                            type="email" 
                            placeholder={t("auth.register.emailPlaceholder")} 
                            value={formData.email} 
                            onChange={(e) => handleChange("email", e.target.value)} 
                            required 
                            className="pl-10"
                          />
                        </div>
                      </div>

                      {/* Blood Group */}
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-2">
                          {t("auth.register.bloodGroup")}
                        </label>
                        <div className="grid grid-cols-4 gap-2">
                          {BLOOD_GROUPS.map((group) => (
                            <button
                              key={group}
                              type="button"
                              onClick={() => setSelectedBloodGroup(group)}
                              className={`
                                h-10 md:h-12 rounded-lg md:rounded-xl
                                text-sm md:text-base font-bold
                                transition-all duration-300
                                ${selectedBloodGroup === group
                                  ? "bg-red-600 text-white shadow-lg shadow-red-600/25 scale-105"
                                  : "bg-gray-50 text-gray-700 border border-gray-200 hover:border-red-300 hover:bg-red-50"
                                }
                              `}
                            >
                              {group}
                            </button>
                          ))}
                        </div>
                      </div>
                    </>
                  )}

                  {/* Password Fields */}
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1.5">
                      {t("auth.register.password")}
                    </label>
                    <div className="relative">
                      <Input 
                        type={showPassword ? "text" : "password"} 
                        placeholder="••••••••" 
                        value={formData.password} 
                        onChange={(e) => handleChange("password", e.target.value)} 
                        required 
                        className="pr-10"
                      />
                      <button 
                        type="button" 
                        onClick={() => setShowPassword(!showPassword)} 
                        className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600"
                      >
                        {showPassword ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                      </button>
                    </div>
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1.5">
                      {t("auth.register.passwordConfirm")}
                    </label>
                    <Input 
                      type="password" 
                      placeholder="••••••••" 
                      value={formData.confirmPassword} 
                      onChange={(e) => handleChange("confirmPassword", e.target.value)} 
                      required 
                    />
                  </div>
                </motion.div>
              </AnimatePresence>

              {/* Hospital Notice */}
              {userType === "hospital" && (
                <motion.div
                  initial={{ opacity: 0, y: 10 }}
                  animate={{ opacity: 1, y: 0 }}
                  className="flex gap-3 bg-amber-50 border border-amber-200 rounded-xl p-3 md:p-4"
                >
                  <Building2 className="w-5 h-5 text-amber-600 flex-shrink-0 mt-0.5" />
                  <p className="text-xs md:text-sm text-amber-700 leading-relaxed">
                    {t("auth.register.hospitalNotice")}
                  </p>
                </motion.div>
              )}

              {/* Error Message */}
              <AnimatePresence>
                {error && (
                  <motion.div
                    initial={{ opacity: 0, height: 0 }}
                    animate={{ opacity: 1, height: "auto" }}
                    exit={{ opacity: 0, height: 0 }}
                    className="flex items-center gap-2 bg-red-50 border border-red-200 text-red-600 text-sm px-3 py-2.5 rounded-xl overflow-hidden"
                  >
                    <AlertCircle className="w-4 h-4 flex-shrink-0" />
                    {error}
                  </motion.div>
                )}
              </AnimatePresence>

              {/* Submit Button */}
              <button
                type="submit"
                disabled={isLoading}
                className="
                  w-full h-12 md:h-14 
                  bg-gradient-to-r from-red-600 to-red-700
                  text-white font-semibold text-sm md:text-base
                  rounded-xl md:rounded-2xl
                  shadow-lg shadow-red-600/30
                  hover:shadow-xl hover:shadow-red-600/40
                  hover:scale-[1.02] active:scale-[0.98]
                  transition-all duration-300
                  flex items-center justify-center gap-2
                  disabled:opacity-70 disabled:cursor-not-allowed
                  disabled:hover:scale-100
                  mt-4 md:mt-6
                "
              >
                {isLoading ? (
                  <svg className="animate-spin w-5 h-5" fill="none" viewBox="0 0 24 24">
                    <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" />
                    <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z" />
                  </svg>
                ) : (
                  <>
                    <span>{t("auth.register.submit")}</span>
                    <ArrowRight className="w-4 h-4 md:w-5 md:h-5" />
                  </>
                )}
              </button>
            </form>

            {/* Login Link */}
            <p className="mt-6 md:mt-8 text-center text-xs md:text-sm text-gray-500">
              {t("auth.register.already")}{" "}
              <Link 
                to="/login" 
                className="text-red-600 font-semibold hover:text-red-700 hover:underline inline-flex items-center gap-1 group"
              >
                {t("auth.register.login")}
                <ChevronRight className="w-3 h-3 group-hover:translate-x-0.5 transition-transform" />
              </Link>
            </p>
          </motion.div>
        </div>
      </div>
    </PublicLayout>
  );
}