import React, { useState, useEffect } from "react";
import { HospitalLayout } from "../../components/layouts";
import { TrendingUp, Users, Droplet, Calendar, Activity, ArrowUpRight, Loader2, Clock } from "lucide-react";
import { motion } from "motion/react";
import { getHospitalStatsApi } from "../../api";
import { useTranslation } from "../../i18n";

interface StatItem {
  label: string;
  value: string | number;
  change: string;
  icon: any;
  bg: string;
  iconColor: string;
  accent: string;
}

/** Formate la date relative */
function formatTime(dateStr: string, t: any) {
  const date = new Date(dateStr);
  const now = new Date();
  const diffMin = Math.floor((now.getTime() - date.getTime()) / 60000);
  if (diffMin < 1) return t("donor.home.time.now");
  if (diffMin < 60) return t("dashboard.time.ago", { count: diffMin.toString(), unit: t("dashboard.time.min") });
  const diffHours = Math.floor(diffMin / 60);
  if (diffHours < 24) return t("dashboard.time.ago", { count: diffHours.toString(), unit: t("dashboard.time.hour") });
  return date.toLocaleDateString();
}

export function HospitalStats() {
  const { t } = useTranslation();
  const [period, setPeriod] = useState<"week" | "month" | "year">("month");
  const [isLoading, setIsLoading] = useState(true);
  const [statsData, setStatsData] = useState<any>(null);

  useEffect(() => {
    fetchStats();
  }, []);

  const fetchStats = async () => {
    setIsLoading(true);
    try {
      const data = await getHospitalStatsApi();
      setStatsData(data);
    } catch (error) {
      console.error("Failed to fetch stats", error);
    } finally {
      setIsLoading(false);
    }
  };

  if (isLoading) {
    return (
      <HospitalLayout>
        <div className="flex h-[60vh] items-center justify-center">
          <Loader2 className="w-8 h-8 animate-spin text-[#CC0000]" />
        </div>
      </HospitalLayout>
    );
  }

  const kpiStats: StatItem[] = [
    { 
      label: t("stats.kpi.total_requests"), 
      value: statsData?.totalRequests || 0, 
      change: "+0%", 
      icon: Activity, 
      bg: "bg-[#FFF0F0]", 
      iconColor: "text-[#CC0000]", 
      accent: "#CC0000" 
    },
    { 
      label: t("stats.kpi.unique_donors"), 
      value: statsData?.uniqueDonors || 0, 
      change: "+0%", 
      icon: Users, 
      bg: "bg-[#F0FFF4]", 
      iconColor: "text-[#1A7A3F]", 
      accent: "#1A7A3F" 
    },
    { 
      label: t("stats.kpi.pockets_collected"), 
      value: statsData?.confirmedDonations || 0, 
      change: "+0%", 
      icon: Droplet, 
      bg: "bg-[#F5F5FF]", 
      iconColor: "text-[#5B5BD6]", 
      accent: "#5B5BD6" 
    },
    { 
      label: t("stats.kpi.response_rate"), 
      value: `${statsData?.responseRate || 0}%`, 
      change: "+0%", 
      icon: TrendingUp, 
      bg: "bg-[#FFF8F0]", 
      iconColor: "text-[#D4720B]", 
      accent: "#D4720B" 
    },
  ];

  const maxDonations = Math.max(...(statsData?.monthlyData?.map((d: any) => d.donations) || [1]), 5);

  return (
    <HospitalLayout>
      <div className="max-w-6xl mx-auto">

        {/* ── Header ──────────────────────────────── */}
        <div className="flex items-center justify-between mb-8">
          <div>
            <p className="text-[11px] font-semibold text-[#AAAAAA] uppercase tracking-widest mb-1" style={{ fontFamily: "'DM Sans', sans-serif" }}>
              {t("stats.sub")}
            </p>
            <h1 className="text-[26px] font-bold text-[#0A0A0A]" style={{ fontFamily: "'DM Sans', sans-serif" }}>
              {t("stats.title")}
            </h1>
          </div>
          {/* Period selector */}
          <div className="flex bg-[#F0F0F0] rounded-xl p-1 gap-1">
            {(["week", "month", "year"] as const).map((p) => (
              <button
                key={p}
                onClick={() => setPeriod(p)}
                className={`px-3 py-1.5 rounded-lg text-[12px] font-semibold transition-all ${
                  period === p ? "bg-white text-[#0A0A0A] shadow-sm" : "text-[#888888] hover:text-[#555555]"
                }`}
                style={{ fontFamily: "'DM Sans', sans-serif" }}
              >
                {p === "week" ? t("stats.periods.week") : p === "month" ? t("stats.periods.month") : t("stats.periods.year")}
              </button>
            ))}
          </div>
        </div>

        {/* ── KPI Cards ───────────────────────────── */}
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
          {kpiStats.map((stat, i) => (
            <motion.div
              key={stat.label}
              initial={{ opacity: 0, y: 12 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: i * 0.07 }}
              className="bg-white rounded-2xl border border-[#EBEBEB] p-5 shadow-[0_1px_8px_rgba(0,0,0,0.05)] hover:shadow-[0_6px_24px_rgba(0,0,0,0.09)] transition-all hover:-translate-y-0.5"
            >
              <div className="flex items-center justify-between mb-3">
                <div className={`p-2 rounded-xl ${stat.bg}`}>
                  <stat.icon className={`w-5 h-5 ${stat.iconColor}`} />
                </div>
                <span className="flex items-center gap-0.5 text-[11px] font-bold text-[#1A7A3F] bg-[#F0FFF4] px-2 py-0.5 rounded-full" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                  <ArrowUpRight className="w-3 h-3" />
                  {stat.change}
                </span>
              </div>
              <p className="text-[28px] font-bold text-[#0A0A0A] leading-none mb-1" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                {stat.value}
              </p>
              <p className="text-[12px] text-[#AAAAAA]" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                {stat.label}
              </p>
            </motion.div>
          ))}
        </div>

        {/* ── Charts row ─────────────────────────── */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-6">

          {/* Bar chart — monthly */}
          <div className="lg:col-span-2 bg-white rounded-2xl border border-[#EBEBEB] p-6 shadow-[0_1px_8px_rgba(0,0,0,0.05)]">
            <div className="flex items-center justify-between mb-6">
              <div>
                <h2 className="text-[15px] font-bold text-[#0A0A0A]" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                  {t("stats.charts.evolution")}
                </h2>
                <p className="text-[12px] text-[#AAAAAA]" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                  {t("stats.charts.evolution_sub")}
                </p>
              </div>
              <Calendar className="w-4 h-4 text-[#CCCCCC]" />
            </div>

            {/* Chart */}
            <div className="flex items-end justify-between gap-2 h-40">
              {statsData?.monthlyData?.map((data: any, i: number) => {
                const pct = (data.donations / maxDonations) * 100;
                return (
                  <div key={data.month} className="flex-1 flex flex-col items-center gap-2">
                    <span className="text-[11px] font-bold text-[#333333]" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                      {data.donations}
                    </span>
                    <div className="w-full relative flex items-end bg-[#F5F5F5] rounded-lg" style={{ height: "100px" }}>
                      <motion.div
                        initial={{ height: 0 }}
                        animate={{ height: `${pct || 2}%` }}
                        transition={{ delay: 0.3 + i * 0.08, duration: 0.5, ease: "easeOut" }}
                        className="w-full rounded-lg"
                        style={{ background: `linear-gradient(180deg, #CC0000, #990000)` }}
                      />
                    </div>
                    <span className="text-[11px] text-[#AAAAAA]" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                      {data.month}
                    </span>
                  </div>
                );
              })}
            </div>
          </div>

          {/* Blood group distribution */}
          <div className="bg-white rounded-2xl border border-[#EBEBEB] p-6 shadow-[0_1px_8px_rgba(0,0,0,0.05)]">
            <h2 className="text-[15px] font-bold text-[#0A0A0A] mb-1" style={{ fontFamily: "'DM Sans', sans-serif" }}>
              {t("stats.charts.distribution")}
            </h2>
            <p className="text-[12px] text-[#AAAAAA] mb-5" style={{ fontFamily: "'DM Sans', sans-serif" }}>
              {t("stats.charts.distribution_sub")}
            </p>
            <div className="space-y-3">
              {statsData?.bloodGroupData?.length > 0 ? (
                statsData.bloodGroupData.map((bg: any, i: number) => (
                  <div key={bg.group}>
                    <div className="flex justify-between mb-1">
                      <span className="text-[13px] font-bold text-[#333333]" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                        {bg.group}
                      </span>
                      <span className="text-[12px] text-[#AAAAAA]" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                        {t("stats.activity.donations_count", { count: bg.count.toString() })} · <strong>{bg.percentage}%</strong>
                      </span>
                    </div>
                    <div className="w-full bg-[#F5F5F5] rounded-full h-2 overflow-hidden">
                      <motion.div
                        initial={{ width: 0 }}
                        animate={{ width: `${bg.percentage}%` }}
                        transition={{ delay: 0.4 + i * 0.06, duration: 0.6, ease: "easeOut" }}
                        className="h-full rounded-full bg-[#CC0000]"
                      />
                    </div>
                  </div>
                ))
              ) : (
                <div className="text-center py-10 text-[#AAAAAA] text-xs">
                  {t("stats.charts.empty")}
                </div>
              )}
            </div>
          </div>
        </div>

        {/* ── Activity log ────────────────────────── */}
        <div className="bg-white rounded-2xl border border-[#EBEBEB] shadow-[0_1px_8px_rgba(0,0,0,0.05)] overflow-hidden">
          <div className="px-6 py-5 border-b border-[#F0F0F0] flex items-center justify-between">
            <h2 className="text-[15px] font-bold text-[#0A0A0A]" style={{ fontFamily: "'DM Sans', sans-serif" }}>
              {t("stats.activity.title")}
            </h2>
          </div>
          <div className="divide-y divide-[#F8F8F8]">
            {statsData?.activityLog?.length > 0 ? (
              statsData.activityLog.map((act: any, i: number) => (
                <motion.div
                  key={i}
                  initial={{ opacity: 0, x: -8 }}
                  animate={{ opacity: 1, x: 0 }}
                  transition={{ delay: 0.5 + i * 0.06 }}
                  className="flex items-center gap-4 px-6 py-4"
                >
                  <div className={`w-2.5 h-2.5 rounded-full flex-shrink-0 ${act.dot}`} />
                  <div className="flex-1 min-w-0">
                    <p className="text-[13px] font-semibold text-[#111111]" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                      {act.action}
                    </p>
                    <p className="text-[11px] text-[#AAAAAA]" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                      {act.detail}
                    </p>
                  </div>
                  <span className="text-[11px] text-[#CCCCCC] flex-shrink-0 flex items-center gap-1" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                    <Clock className="w-3 h-3" />
                    {formatTime(act.time, t)}
                  </span>
                </motion.div>
              ))
            ) : (
              <div className="p-8 text-center text-[#AAAAAA] text-sm">
                {t("stats.activity.empty")}
              </div>
            )}
          </div>
        </div>
      </div>
    </HospitalLayout>
  );
}
