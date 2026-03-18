import React, { useState } from "react";
import { Link, useNavigate } from "react-router";
import { PublicLayout } from "../../components/layouts";
import { Button, Input, Typography } from "../../components/ui";
import { motion } from "motion/react";
import { useTranslation } from "../../i18n";

type Step = "request" | "sent";

export function ForgotPassword() {
  const [step, setStep] = useState<Step>("request");
  const [identifier, setIdentifier] = useState("");
  const navigate = useNavigate();
  const { t } = useTranslation();

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setStep("sent");
  };

  const handleBackToLogin = () => {
    navigate("/login");
  };

  return (
    <PublicLayout>
      <div className="flex-1 flex flex-col items-center justify-center px-4 py-12 md:py-20 bg-[#F7F7F8]">
        <div className="w-full max-w-md bg-white p-8 rounded-2xl border border-[#EBEBEB] shadow-[0_4px_24px_rgba(0,0,0,0.07)]">
          {step === "request" ? (
            <motion.div
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.3 }}
            >
              <div className="flex items-center justify-center w-14 h-14 bg-[#FFF0F0] rounded-2xl mx-auto mb-6">
                <svg className="w-7 h-7 text-[#CC0000]" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 7a2 2 0 012 2m4 0a6 6 0 01-7.743 5.743L11 17H9v2H7v2H4a1 1 0 01-1-1v-2.586a1 1 0 01.293-.707l5.964-5.964A6 6 0 1121 9z" />
                </svg>
              </div>
              <h1
                className="text-[24px] font-bold text-[#0A0A0A] text-center mb-2"
                style={{ fontFamily: "'DM Sans', sans-serif" }}
              >
                {t("auth.forgot.title")}
              </h1>
              <p
                className="text-[14px] text-[#888888] text-center mb-8 leading-relaxed"
                style={{ fontFamily: "'DM Sans', sans-serif" }}
              >
                {t("auth.forgot.subtitle")}
              </p>

              <form onSubmit={handleSubmit} className="space-y-4">
                <div>
                  <label
                    className="block text-sm font-semibold text-[#333333] mb-1.5"
                    style={{ fontFamily: "'DM Sans', sans-serif" }}
                  >
                    {t("auth.forgot.identifier")}
                  </label>
                  <Input
                    type="text"
                    placeholder={t("auth.forgot.identifier")}
                    value={identifier}
                    onChange={(e) => setIdentifier(e.target.value)}
                    required
                  />
                </div>
                <Button type="submit" className="w-full h-11">
                  {t("auth.forgot.submit")}
                </Button>
                <div className="text-center">
                  <Link
                    to="/login"
                    className="text-sm font-medium text-[#CC0000] hover:underline"
                    style={{ fontFamily: "'DM Sans', sans-serif" }}
                  >
                    {t("auth.forgot.backToLogin")}
                  </Link>
                </div>
              </form>
            </motion.div>
          ) : (
            <motion.div
              initial={{ opacity: 0, scale: 0.95 }}
              animate={{ opacity: 1, scale: 1 }}
              transition={{ duration: 0.4 }}
              className="text-center"
            >
              <motion.div
                initial={{ scale: 0 }}
                animate={{ scale: 1 }}
                transition={{ type: "spring", stiffness: 300, damping: 20 }}
                className="w-16 h-16 mx-auto mb-6 bg-[#E8F5E9] rounded-2xl flex items-center justify-center"
              >
                <svg className="w-8 h-8 text-[#1A7A3F]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M5 13l4 4L19 7" />
                </svg>
              </motion.div>
              <h1
                className="text-[24px] font-bold text-[#0A0A0A] text-center mb-2"
                style={{ fontFamily: "'DM Sans', sans-serif" }}
              >
                {t("auth.forgot.sentTitle")}
              </h1>
              <p
                className="text-[14px] text-[#888888] text-center mb-8 leading-relaxed"
                style={{ fontFamily: "'DM Sans', sans-serif" }}
              >
                {t("auth.forgot.sentDescription", { identifier })}
              </p>
              <Button onClick={handleBackToLogin} className="w-full h-11">
                {t("auth.forgot.backToLogin")}
              </Button>
              <div
                className="mt-5 text-sm text-[#888888]"
                style={{ fontFamily: "'DM Sans', sans-serif" }}
              >
                {t("auth.forgot.notReceived")}{" "}
                <button
                  onClick={() => setStep("request")}
                  className="text-[#CC0000] font-semibold hover:underline"
                >
                  {t("auth.forgot.resend")}
                </button>
              </div>
            </motion.div>
          )}
        </div>
      </div>
    </PublicLayout>
  );
}
