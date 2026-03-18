import React from "react";
import { Link } from "react-router";
import { Button, Typography } from "../components/ui";
import { PublicLayout } from "../components/layouts";
import { motion } from "motion/react";
import { useTranslation, useLanguage } from "../i18n";
import { Droplet, ArrowRight, Heart, Shield, Zap } from "lucide-react";
import homeImage from "../../../aman-chaturvedi-0ZZo5o00o80-unsplash.jpg";

const getStats = (t: any) => [
  { value: "8 900+", label: t("home.stats.active_donors") },
  { value: "42", label: t("home.stats.partner_hospitals") },
  { value: "1 240", label: t("home.stats.donations_month") },
];

const getFeatures = (t: any) => [
  {
    icon: Zap,
    color: "bg-[#FFF0F0]",
    iconColor: "text-[#CC0000]",
    title: t("home.features.alerts.title"),
    desc: t("home.features.alerts.desc"),
  },
  {
    icon: Heart,
    color: "bg-[#F0FFF4]",
    iconColor: "text-[#1A7A3F]",
    title: t("home.features.impact.title"),
    desc: t("home.features.impact.desc"),
  },
  {
    icon: Shield,
    color: "bg-[#FFF8F0]",
    iconColor: "text-[#D4720B]",
    title: t("home.features.certified.title"),
    desc: t("home.features.certified.desc"),
  },
];

export function HomePage() {
  const { language } = useLanguage();
  const { t } = useTranslation();

  return (
    <PublicLayout>
      {/* ── HERO ───────────────────────────────────────────── */}
      <section className="relative flex flex-col items-center justify-center min-h-[calc(100vh-64px)] px-6 py-16 text-center overflow-hidden">
        {/* Background image */}
        <motion.div
          initial={{ scale: 1.08, opacity: 0 }}
          animate={{ scale: 1, opacity: 0.18 }}
          transition={{ duration: 1.8, ease: "easeOut" }}
          className="absolute inset-0 z-0 bg-cover bg-center bg-no-repeat"
          style={{ backgroundImage: `url(${homeImage})` }}
        />

        {/* Gradient overlay */}
        <div className="absolute inset-0 z-0 bg-gradient-to-br from-white via-white/95 to-white/85" />

        {/* Ambient blobs */}
        <motion.div
          animate={{ y: [0, -24, 0], x: [0, 8, 0] }}
          transition={{ duration: 7, repeat: Infinity, ease: "easeInOut" }}
          className="absolute top-[8%] right-[6%] w-[320px] h-[320px] rounded-full bg-[#CC0000]/8 blur-[80px] z-0 pointer-events-none"
        />
        <motion.div
          animate={{ y: [0, 20, 0], x: [0, -10, 0] }}
          transition={{ duration: 9, repeat: Infinity, ease: "easeInOut", delay: 2 }}
          className="absolute bottom-[10%] left-[3%] w-[280px] h-[280px] rounded-full bg-[#1A7A3F]/6 blur-[80px] z-0 pointer-events-none"
        />

        {/* Main content */}
        <motion.div
          initial={{ y: 32, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          transition={{ duration: 0.8, delay: 0.2, ease: "easeOut" }}
          className="relative z-10 max-w-[720px] w-full"
        >
          {/* Pill badge */}
          <motion.div
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.1 }}
            className="inline-flex items-center gap-2 bg-[#FFF0F0] border border-[#CC0000]/20 rounded-full px-4 py-1.5 mb-8"
          >
            <Droplet className="w-3.5 h-3.5 text-[#CC0000] fill-[#CC0000]" />
            <span
              className="text-[12px] font-semibold text-[#CC0000] tracking-wide uppercase"
              style={{ fontFamily: "'DM Sans', sans-serif" }}
            >
              {t("home.hero.pill")}
            </span>
          </motion.div>

          <Typography.H1 className="mb-6 text-[38px] md:text-[58px] lg:text-[64px]">
            {t("home.hero.title", {
              span: (
                <span className="text-[#CC0000] relative inline-block">
                  {t("home.hero.title_span")}
                  <svg
                    className="absolute -bottom-1 left-0 w-full"
                    height="6"
                    viewBox="0 0 100 6"
                    preserveAspectRatio="none"
                  >
                    <path
                      d="M0,4 Q25,0 50,4 Q75,8 100,4"
                      stroke="#CC0000"
                      strokeOpacity="0.4"
                      strokeWidth="2"
                      fill="none"
                    />
                  </svg>
                </span>
              )
            } as any)}
          </Typography.H1>

          <Typography.Body className="mb-10 max-w-[560px] mx-auto text-[16px] md:text-[18px] leading-loose text-[#555555]">
            {t("home.hero.body")}
          </Typography.Body>

          {/* CTAs */}
          <motion.div
            initial={{ y: 20, opacity: 0 }}
            animate={{ y: 0, opacity: 1 }}
            transition={{ duration: 0.6, delay: 0.5 }}
            className="flex flex-col sm:flex-row gap-3 justify-center"
          >
            <Link to="/register">
              <Button size="lg" className="w-full sm:w-auto min-w-[200px] text-[16px]">
                {t("home.hero.cta_donor")}
                <ArrowRight className="w-4 h-4" />
              </Button>
            </Link>
            <Link to="/login">
              <Button
                variant="secondary"
                size="lg"
                className="w-full sm:w-auto min-w-[200px] text-[16px]"
              >
                {t("home.hero.cta_login")}
              </Button>
            </Link>
          </motion.div>

          {/* Micro-copy */}
          <motion.p
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ duration: 0.6, delay: 0.9 }}
            className="mt-6 text-[13px] text-[#AAAAAA]"
            style={{ fontFamily: "'DM Sans', sans-serif" }}
          >
            {t("home.hero.micro")}
          </motion.p>
        </motion.div>

        {/* Stats strip */}
        <motion.div
          initial={{ opacity: 0, y: 24 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.7, duration: 0.8 }}
          className="relative z-10 mt-16 grid grid-cols-3 gap-4 md:gap-8 w-full max-w-[560px] mx-auto"
        >
          {getStats(t).map((stat, i) => (
            <div key={i} className="text-center">
              <p
                className="text-[24px] md:text-[32px] font-bold text-[#0A0A0A] leading-none"
                style={{ fontFamily: "'DM Sans', sans-serif" }}
              >
                {stat.value}
              </p>
              <p
                className="text-[11px] md:text-[12px] text-[#888888] mt-1 font-medium"
                style={{ fontFamily: "'DM Sans', sans-serif" }}
              >
                {stat.label}
              </p>
            </div>
          ))}
        </motion.div>
      </section>

      {/* ── FEATURES ──────────────────────────────────────── */}
      <section className="bg-[#F7F7F8] border-t border-[#EBEBEB] py-20 px-6">
        <div className="max-w-[1000px] mx-auto">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.6 }}
            className="text-center mb-14"
          >
            <Typography.H2 className="text-[28px] md:text-[36px] mb-3">
              {t("home.features.title")}
            </Typography.H2>
            <Typography.Body className="max-w-[480px] mx-auto text-[15px]">
              {t("home.features.sub")}
            </Typography.Body>
          </motion.div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            {getFeatures(t).map((f, i) => (
              <motion.div
                key={i}
                initial={{ opacity: 0, y: 24 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ delay: i * 0.12, duration: 0.6 }}
                className="bg-white rounded-2xl p-6 border border-[#EBEBEB] shadow-[0_1px_8px_rgba(0,0,0,0.05)] hover:shadow-[0_6px_24px_rgba(0,0,0,0.09)] hover:-translate-y-1 transition-all duration-300 cursor-default"
              >
                <div className={`inline-flex p-3 rounded-xl ${f.color} mb-4`}>
                  <f.icon className={`w-5 h-5 ${f.iconColor}`} />
                </div>
                <h3
                  className="text-[15px] font-semibold text-[#111111] mb-2"
                  style={{ fontFamily: "'DM Sans', sans-serif" }}
                >
                  {f.title}
                </h3>
                <p
                  className="text-[13px] text-[#666666] leading-relaxed"
                  style={{ fontFamily: "'DM Sans', sans-serif" }}
                >
                  {f.desc}
                </p>
              </motion.div>
            ))}
          </div>
        </div>
      </section>

      {/* ── CTA BOTTOM ────────────────────────────────────── */}
      <section className="bg-[#CC0000] py-16 px-6 text-center">
        <motion.div
          initial={{ opacity: 0, scale: 0.97 }}
          whileInView={{ opacity: 1, scale: 1 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6 }}
          className="max-w-[600px] mx-auto"
        >
          <Droplet className="w-10 h-10 text-white/80 fill-white/80 mx-auto mb-5" />
          <h2
            className="text-[28px] md:text-[36px] font-bold text-white mb-4 leading-tight"
            style={{ fontFamily: "'DM Sans', sans-serif" }}
          >
            {t("home.bottom_cta.title")}
          </h2>
          <p
            className="text-white/75 text-[15px] mb-8 leading-relaxed"
            style={{ fontFamily: "'DM Sans', sans-serif" }}
          >
            {t("home.bottom_cta.desc")}
          </p>
          <Link to="/register">
            <button
              className="inline-flex items-center gap-2 bg-white text-[#CC0000] font-bold text-[15px] px-8 py-3.5 rounded-xl shadow-[0_4px_20px_rgba(0,0,0,0.2)] hover:shadow-[0_6px_28px_rgba(0,0,0,0.3)] hover:-translate-y-0.5 active:scale-[0.97] transition-all duration-200"
              style={{ fontFamily: "'DM Sans', sans-serif" }}
            >
              {t("home.bottom_cta.button")}
              <ArrowRight className="w-4 h-4" />
            </button>
          </Link>
        </motion.div>
      </section>
    </PublicLayout>
  );
}
