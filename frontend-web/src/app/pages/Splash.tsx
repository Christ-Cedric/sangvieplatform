import React, { useEffect } from "react";
import { useNavigate } from "react-router";
import { motion } from "motion/react";
import { Droplet } from "lucide-react";
import { useTranslation } from "../i18n";

export function SplashPage() {
  const navigate = useNavigate();
  const { t } = useTranslation();

  useEffect(() => {
    const timer = setTimeout(() => {
      navigate("/home");
    }, 2800);
    return () => clearTimeout(timer);
  }, [navigate]);

  return (
    <div className="h-screen w-full bg-[#CC0000] flex flex-col items-center justify-center relative overflow-hidden">
      {/* Background circles */}
      <motion.div
        initial={{ scale: 0, opacity: 0 }}
        animate={{ scale: 1, opacity: 0.12 }}
        transition={{ duration: 2, ease: "easeOut" }}
        className="absolute w-[600px] h-[600px] rounded-full bg-white"
      />
      <motion.div
        initial={{ scale: 0, opacity: 0 }}
        animate={{ scale: 1, opacity: 0.08 }}
        transition={{ duration: 2.5, ease: "easeOut", delay: 0.2 }}
        className="absolute w-[900px] h-[900px] rounded-full bg-white"
      />

      {/* Center content */}
      <motion.div
        initial={{ scale: 0.7, opacity: 0, y: 20 }}
        animate={{ scale: 1, opacity: 1, y: 0 }}
        transition={{ duration: 0.8, ease: [0.34, 1.56, 0.64, 1] }}
        className="relative z-10 flex flex-col items-center"
      >
        {/* Icon with pulse */}
        <div className="relative mb-6">
          <motion.div
            animate={{ scale: [1, 1.15, 1] }}
            transition={{ repeat: Infinity, duration: 1.8, ease: "easeInOut" }}
            className="absolute inset-0 rounded-full bg-white/20"
          />
          <div className="relative bg-white/15 p-5 rounded-full border border-white/20">
            <motion.div
              animate={{ y: [0, -6, 0] }}
              transition={{ repeat: Infinity, duration: 1.6, ease: "easeInOut" }}
            >
              <Droplet className="text-white w-16 h-16 fill-white" />
            </motion.div>
          </div>
        </div>

        <motion.h1
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.3, duration: 0.6 }}
          className="text-[52px] font-bold text-white tracking-tight leading-none"
          style={{ fontFamily: "'DM Sans', sans-serif" }}
        >
          SangVie
        </motion.h1>

        <motion.p
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.6, duration: 0.6 }}
          className="text-white/70 text-[15px] mt-3 tracking-wide"
          style={{ fontFamily: "'DM Sans', sans-serif" }}
        >
          {t("splash.tagline")}
        </motion.p>

        {/* Loading bar */}
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.8 }}
          className="mt-10 w-32 h-[3px] bg-white/20 rounded-full overflow-hidden"
        >
          <motion.div
            initial={{ x: "-100%" }}
            animate={{ x: "100%" }}
            transition={{ duration: 2, ease: "easeInOut", delay: 0.8 }}
            className="h-full w-full bg-white rounded-full"
          />
        </motion.div>
      </motion.div>
    </div>
  );
}
