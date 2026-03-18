import React, { useState, useEffect } from "react";
import { HospitalLayout } from "../../components/layouts";
import { Card, Badge, Button, Input } from "../../components/ui";
import { Plus, Users, Droplet, ArrowUpRight, CheckCircle, Clock, TrendingUp, X, Loader2, Phone, ShieldCheck } from "lucide-react";
import { motion, AnimatePresence } from "motion/react";
import { useAuth } from "../../AuthContext";
import {
  getMyRequestsApi,
  createRequestApi,
  getHospitalStatsApi,
  getRequestResponsesApi,
  confirmDonationApi,
  type BloodRequest
} from "../../api";
import { useTranslation, useLanguage } from "../../i18n";

const BLOOD_GROUPS = ["A+", "A-", "B+", "B-", "O+", "O-", "AB+", "AB-"];

/** Formate la date relative */
function formatTime(dateStr: string, t: any) {
  const date = new Date(dateStr);
  const now = new Date();
  const diffMin = Math.floor((now.getTime() - date.getTime()) / 60000);
  if (diffMin < 60) return t("dashboard.time.ago", { count: diffMin.toString(), unit: t("dashboard.time.min") });
  const diffHours = Math.floor(diffMin / 60);
  if (diffHours < 24) return t("dashboard.time.ago", { count: diffHours.toString(), unit: t("dashboard.time.hour") });
  return date.toLocaleDateString();
}

export function HospitalDashboard() {
  const { user } = useAuth();
  const { t } = useTranslation();
  const { language } = useLanguage();
  const [requests, setRequests] = useState<BloodRequest[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [isModalOpen, setIsModalOpen] = useState(false);

  // Responses modal
  const [selectedRequestForDetails, setSelectedRequestForDetails] = useState<BloodRequest | null>(null);
  const [responses, setResponses] = useState<any[]>([]);
  const [isLoadingResponses, setIsLoadingResponses] = useState(false);

  // Form fields
  const [bloodGroup, setBloodGroup] = useState("");
  const [quantity, setQuantity] = useState("1");
  const [urgency, setUrgency] = useState<"normal" | "urgent" | "critique">("normal");
  const [description, setDescription] = useState("");

  const [realStats, setRealStats] = useState<any>(null);

  useEffect(() => {
    fetchMyRequests();
    fetchStats();
  }, []);

  const fetchStats = async () => {
    try {
      const data = await getHospitalStatsApi();
      setRealStats(data);
    } catch (e) {
      console.error(e);
    }
  };

  const fetchMyRequests = async () => {
    setIsLoading(true);
    try {
      const data = await getMyRequestsApi();
      setRequests(data.sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime()));
    } catch (error) {
      console.error("Failed to fetch requests", error);
    } finally {
      setIsLoading(false);
    }
  };

  const [successMessage, setSuccessMessage] = useState("");

  const handleCreateRequest = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!bloodGroup || !quantity) return;

    setIsSubmitting(true);
    try {
      await createRequestApi({
        groupeSanguin: bloodGroup,
        quantitePoches: parseInt(quantity),
        niveauUrgence: urgency,
        description,
      });
      setIsModalOpen(false);
      setSuccessMessage(t("modal.request.success"));
      setTimeout(() => setSuccessMessage(""), 5000);

      // Reset form
      setBloodGroup("");
      setQuantity("1");
      setUrgency("normal");
      setDescription("");

      // Refresh list and stats
      fetchMyRequests();
      fetchStats();
    } catch (error: any) {
      console.error("Error creating request:", error);
      alert(error.message ?? "Erreur lors de la création de la demande.");
    } finally {
      setIsSubmitting(false);
    }
  };

  const openResponses = async (req: BloodRequest) => {
    setSelectedRequestForDetails(req);
    setResponses([]);
    setIsLoadingResponses(true);
    try {
      const data = await getRequestResponsesApi(req._id);
      setResponses(data);
    } catch (err) {
      console.error(err);
    } finally {
      setIsLoadingResponses(false);
    }
  };

  const handleConfirmDonation = async (donationId: string) => {
    try {
      await confirmDonationApi(donationId);
      setSuccessMessage(t("modal.responses.success_confirm"));
      setTimeout(() => setSuccessMessage(""), 5000);

      // Refresh responses list
      if (selectedRequestForDetails) {
        const data = await getRequestResponsesApi(selectedRequestForDetails._id);
        setResponses(data);
      }
      fetchStats();
    } catch (err: any) {
      alert(err.message || "Erreur lors de la confirmation");
    }
  };

  const stats = [
    {
      label: t("dashboard.stats.active_requests"),
      value: requests.filter(r => r.statut === "en_attente").length.toString(),
      sub: t("dashboard.stats.active_requests_sub"),
      icon: Clock,
      bg: "bg-[#FFF8F0]",
      iconColor: "text-[#D4720B]",
      accent: "#D4720B",
    },
    {
      label: t("dashboard.stats.total_requests"),
      value: realStats?.totalRequests?.toString() || requests.length.toString(),
      sub: t("dashboard.stats.total_requests_sub"),
      icon: TrendingUp,
      bg: "bg-[#F5F5FF]",
      iconColor: "text-[#5B5BD6]",
      accent: "#5B5BD6",
    },
    {
      label: t("dashboard.stats.donations_received"),
      value: realStats?.confirmedDonations?.toString() || "0",
      sub: t("dashboard.stats.donations_received_sub"),
      icon: Droplet,
      bg: "bg-[#F0FFF4]",
      iconColor: "text-[#1A7A3F]",
      accent: "#1A7A3F",
    },
    {
      label: t("dashboard.stats.linked_donors"),
      value: realStats?.uniqueDonors?.toString() || "0",
      sub: t("dashboard.stats.linked_donors_sub"),
      icon: Users,
      bg: "bg-[#FFF0F0]",
      iconColor: "text-[#CC0000]",
      accent: "#CC0000",
    },
  ];

  return (
    <HospitalLayout>
      {/* ── Header ──────────────────────────────────── */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mb-8">
        <div>
          <p className="text-[12px] font-semibold text-[#AAAAAA] uppercase tracking-widest mb-1" style={{ fontFamily: "'DM Sans', sans-serif" }}>
            {t("dashboard.title")}
          </p>
          <h1 className="text-[28px] md:text-[34px] font-bold text-[#0A0A0A] leading-tight" style={{ fontFamily: "'DM Sans', sans-serif" }}>
            {t("dashboard.welcome", { name: user?.nom || t("hospital.default_name") })}
          </h1>
          <p className="text-[14px] text-[#888888] mt-1" style={{ fontFamily: "'DM Sans', sans-serif" }}>
            {t("dashboard.active_requests_count", { count: requests.filter(r => r.statut === "en_attente").length.toString() })} · {new Date().toLocaleDateString(language === 'fr' ? 'fr-FR' : 'en-US', { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' })}
          </p>
        </div>
        <Button onClick={() => setIsModalOpen(true)} className="hidden sm:flex items-center gap-2">
          <Plus className="w-4 h-4" />
          {t("dashboard.new_request")}
        </Button>
      </div>

      {/* ── Stats Grid ──────────────────────────────── */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
        {stats.map((stat, i) => (
          <motion.div
            key={i}
            initial={{ opacity: 0, y: 12 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: i * 0.07, duration: 0.4 }}
          >
            <Card className="flex flex-col gap-3 hover:shadow-[0_6px_24px_rgba(0,0,0,0.09)] transition-all duration-200 hover:-translate-y-0.5 min-h-[140px]">
              <div className="flex items-center justify-between">
                <div className={`p-2 rounded-xl ${stat.bg}`}>
                  <stat.icon className={`w-5 h-5 ${stat.iconColor}`} />
                </div>
                <ArrowUpRight className="w-3.5 h-3.5 text-[#CCCCCC]" />
              </div>
              <div>
                <p className="text-[12px] text-[#AAAAAA] font-medium mb-0.5" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                  {stat.label}
                </p>
                <p className="text-[28px] font-bold text-[#0A0A0A] leading-none" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                  {stat.value}
                </p>
                <p className="text-[11px] mt-1" style={{ fontFamily: "'DM Sans', sans-serif", color: stat.accent }}>
                  {stat.sub}
                </p>
              </div>
            </Card>
          </motion.div>
        ))}
      </div>

      {/* ── Recent Requests Table ───────────────────── */}
      <div className="bg-white rounded-2xl border border-[#EBEBEB] overflow-hidden shadow-[0_1px_8px_rgba(0,0,0,0.05)]">
        <div className="px-6 py-5 border-b border-[#F0F0F0] flex items-center justify-between">
          <div>
            <h2 className="text-[16px] font-bold text-[#0A0A0A]" style={{ fontFamily: "'DM Sans', sans-serif" }}>
              {t("dashboard.recent_requests.title")}
            </h2>
            <p className="text-[12px] text-[#AAAAAA] mt-0.5" style={{ fontFamily: "'DM Sans', sans-serif" }}>
              {t("dashboard.recent_requests.sub")}
            </p>
          </div>
          <Button variant="ghost" size="sm" onClick={fetchMyRequests} className="text-[#CC0000] font-semibold text-[13px]">
            {isLoading ? <Loader2 className="w-4 h-4 animate-spin" /> : t("dashboard.recent_requests.refresh")}
          </Button>
        </div>

        <div className="overflow-x-auto">
          {isLoading && (
            <div className="p-20 flex flex-col items-center justify-center gap-4">
              <Loader2 className="w-8 h-8 text-[#CC0000] animate-spin" />
              <p className="text-[#888888] text-sm">Chargement de l'historique...</p>
            </div>
          )}

          {!isLoading && requests.length === 0 && (
            <div className="p-20 text-center text-[#888888]">
              {t("dashboard.recent_requests.empty")}
            </div>
          )}

          {!isLoading && requests.length > 0 && (
            <table className="w-full" style={{ fontFamily: "'DM Sans', sans-serif" }}>
              <thead>
                <tr className="border-b border-[#F0F0F0]">
                  {[t("dashboard.table.group"), t("dashboard.table.quantity"), t("dashboard.table.urgency"), t("dashboard.table.status"), t("dashboard.table.date"), ""].map((h, i) => (
                    <th key={i} className={`px-5 py-3.5 text-[11px] font-semibold text-[#AAAAAA] uppercase tracking-wider ${i === 5 ? "text-right" : "text-left"}`}>
                      {h}
                    </th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {requests.slice(0, 5).map((req) => (
                  <tr key={req._id} className="border-b border-[#F8F8F8] hover:bg-[#FAFAFA] transition-colors">
                    <td className="px-5 py-4">
                      <div className={`w-10 h-10 rounded-xl flex items-center justify-center text-white font-bold text-[13px] ${req.niveauUrgence === "critique" ? "bg-[#CC0000]" : req.niveauUrgence === "urgent" ? "bg-[#D4720B]" : "bg-[#1A7A3F]"
                        }`}>
                        {req.groupeSanguin}
                      </div>
                    </td>
                    <td className="px-5 py-4 text-[14px] font-semibold text-[#111111]">
                      {t("dashboard.table.pockets", { count: req.quantitePoches.toString(), s: req.quantitePoches > 1 ? "s" : "" })}
                    </td>
                    <td className="px-5 py-4">
                      <Badge variant={req.niveauUrgence === "critique" ? "critical" : req.niveauUrgence === "urgent" ? "moderate" : "active"}>
                        {req.niveauUrgence === "critique" ? t("dashboard.urgency.critical") : req.niveauUrgence === "urgent" ? t("dashboard.urgency.urgent") : t("dashboard.urgency.normal")}
                      </Badge>
                    </td>
                    <td className="px-5 py-4">
                      <Badge variant={req.statut === "en_attente" ? "pending" : req.statut === "satisfait" ? "success" : "critical"}>
                        {req.statut === "en_attente" ? t("dashboard.status.pending") : req.statut === "satisfait" ? t("dashboard.status.satisfied") : t("dashboard.status.cancelled")}
                      </Badge>
                    </td>
                    <td className="px-5 py-4 text-[13px] text-[#AAAAAA]">{formatTime(req.createdAt, t)}</td>
                    <td className="px-5 py-4 text-right">
                      <button
                        onClick={() => openResponses(req)}
                        className="text-[13px] font-semibold text-[#CC0000] hover:text-[#990000] transition-colors"
                      >
                        {t("dashboard.table.details")} →
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </div>
      </div>

      {/* ── FAB Mobile ──────────────────────────────── */}
      <button
        onClick={() => setIsModalOpen(true)}
        className="sm:hidden fixed bottom-20 right-4 w-14 h-14 rounded-2xl bg-[#CC0000] shadow-[0_8px_24px_rgba(204,0,0,0.4)] flex items-center justify-center z-50 hover:bg-[#B00000] active:scale-95 transition-all text-white"
      >
        <Plus className="w-6 h-6" />
      </button>

      {/* ── Modal Nouvelle Demande ───────────────────── */}
      <AnimatePresence>
        {isModalOpen && (
          <div className="fixed inset-0 z-[100] flex items-end md:items-center justify-center p-0 md:p-4">
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="absolute inset-0 bg-black/50 backdrop-blur-sm"
              onClick={() => setIsModalOpen(false)}
            />
            <motion.div
              initial={{ y: "100%", opacity: 0 }}
              animate={{ y: 0, opacity: 1 }}
              exit={{ y: "100%", opacity: 0 }}
              transition={{ type: "spring", damping: 28, stiffness: 220 }}
              className="relative z-10 bg-white w-full max-w-lg rounded-t-3xl md:rounded-3xl shadow-2xl flex flex-col max-h-[95vh] overflow-hidden"
            >
              {/* Handle */}
              <div className="flex justify-center pt-3 pb-0 md:hidden">
                <div className="w-10 h-1 rounded-full bg-[#E0E0E0]" />
              </div>

              {/* Header */}
              <div className="flex items-center justify-between px-6 py-4 border-b border-[#F0F0F0]">
                <div>
                  <h2 className="text-[18px] font-bold text-[#0A0A0A]" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                    {t("modal.request.title")}
                  </h2>
                  <p className="text-[12px] text-[#AAAAAA] mt-0.5" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                    {t("modal.request.sub")}
                  </p>
                </div>
                <button
                  onClick={() => setIsModalOpen(false)}
                  className="p-2 rounded-xl bg-[#F5F5F5] hover:bg-[#E8E8E8] transition-colors"
                >
                  <X className="w-4 h-4 text-[#555555]" />
                </button>
              </div>

              {/* Form */}
              <form onSubmit={handleCreateRequest} className="flex-1 overflow-y-auto">
                <div className="p-6 space-y-6">
                  {/* Blood group */}
                  <div>
                    <label className="block text-[13px] font-bold text-[#333333] mb-3 uppercase tracking-wide" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                      {t("modal.request.blood_group")}
                    </label>
                    <div className="grid grid-cols-4 gap-2">
                      {BLOOD_GROUPS.map((g) => (
                        <button
                          key={g}
                          type="button"
                          onClick={() => setBloodGroup(g)}
                          className={`h-11 rounded-xl border-2 font-bold text-[14px] transition-all duration-150 active:scale-95 ${bloodGroup === g
                              ? "bg-[#CC0000] border-[#CC0000] text-white shadow-[0_2px_8px_rgba(204,0,0,0.3)]"
                              : "bg-white border-[#E0E0E0] text-[#333333] hover:border-[#CC0000]/50 hover:text-[#CC0000]"
                            }`}
                          style={{ fontFamily: "'DM Sans', sans-serif" }}
                        >
                          {g}
                        </button>
                      ))}
                    </div>
                  </div>

                  {/* Quantity */}
                  <div>
                    <label className="block text-[13px] font-bold text-[#333333] mb-2 uppercase tracking-wide" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                      {t("modal.request.quantity")}
                    </label>
                    <Input
                      type="number"
                      min="1"
                      max="50"
                      value={quantity}
                      onChange={(e) => setQuantity(e.target.value)}
                      required
                    />
                  </div>

                  {/* Urgency */}
                  <div>
                    <label className="block text-[13px] font-bold text-[#333333] mb-3 uppercase tracking-wide" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                      {t("modal.request.urgency")}
                    </label>
                    <div className="flex flex-col gap-2">
                      {[
                        { value: "critique", label: t("dashboard.urgency.critical"), sub: t("modal.request.urgency.critical_sub"), color: "#CC0000", bg: "bg-[#FFF0F0]" },
                        { value: "urgent", label: t("dashboard.urgency.urgent"), sub: t("modal.request.urgency.urgent_sub"), color: "#D4720B", bg: "bg-[#FFF8F0]" },
                        { value: "normal", label: t("dashboard.urgency.normal"), sub: t("modal.request.urgency.normal_sub"), color: "#1A7A3F", bg: "bg-[#F0FFF4]" },
                      ].map((level) => (
                        <button
                          key={level.value}
                          type="button"
                          onClick={() => setUrgency(level.value as any)}
                          className={`p-3.5 rounded-xl border-2 flex items-center justify-between text-left transition-all duration-150 ${urgency === level.value
                              ? `${level.bg} border-[${level.color}]`
                              : "bg-white border-[#EBEBEB] hover:border-[#DDDDDD]"
                            }`}
                          style={{ borderColor: urgency === level.value ? level.color : undefined }}
                        >
                          <div>
                            <p className="font-bold text-[14px] text-[#111111]" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                              {level.label}
                            </p>
                            <p className="text-[12px] text-[#888888] mt-0.5" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                              {level.sub}
                            </p>
                          </div>
                          <div
                            className={`w-5 h-5 rounded-full border-2 flex items-center justify-center transition-all ${urgency === level.value ? "border-current" : "border-[#D0D0D0]"
                              }`}
                            style={{ borderColor: urgency === level.value ? level.color : undefined }}
                          >
                            {urgency === level.value && (
                              <div className="w-2.5 h-2.5 rounded-full" style={{ backgroundColor: level.color }} />
                            )}
                          </div>
                        </button>
                      ))}
                    </div>
                  </div>

                  {/* Description */}
                  <div>
                    <label className="block text-[13px] font-bold text-[#333333] mb-2 uppercase tracking-wide" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                      {t("modal.request.description")}{" "}
                      <span className="text-[#BBBBBB] font-normal normal-case">{t("modal.request.description_optional")}</span>
                    </label>
                    <textarea
                      value={description}
                      onChange={(e) => setDescription(e.target.value)}
                      className="w-full h-24 rounded-xl border border-[#E0E0E0] bg-[#FAFAFA] p-3.5 text-[14px] text-[#111111] placeholder:text-[#BDBDBD] resize-none focus:outline-none focus:border-[#CC0000] focus:bg-white focus:ring-4 focus:ring-[#CC0000]/10 transition-all"
                      placeholder={t("modal.request.description_placeholder")}
                      style={{ fontFamily: "'DM Sans', sans-serif" }}
                    />
                  </div>
                </div>

                {/* Footer */}
                <div className="sticky bottom-0 px-6 py-4 border-t border-[#F0F0F0] bg-white flex gap-3">
                  <Button
                    variant="secondary"
                    className="flex-1"
                    type="button"
                    disabled={isSubmitting}
                    onClick={() => setIsModalOpen(false)}
                  >
                    {t("modal.request.cancel")}
                  </Button>
                  <Button type="submit" className="flex-1" disabled={isSubmitting}>
                    {isSubmitting ? <Loader2 className="w-4 h-4 animate-spin mx-auto" /> : t("modal.request.submit")}
                  </Button>
                </div>
              </form>
            </motion.div>
          </div>
        )}
      </AnimatePresence>

      {/* ── Modal Détails Réponses ─────────────────── */}
      <AnimatePresence>
        {selectedRequestForDetails && (
          <div className="fixed inset-0 z-[110] flex items-end md:items-center justify-center p-0 md:p-4">
            <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }} className="absolute inset-0 bg-black/60 backdrop-blur-sm" onClick={() => setSelectedRequestForDetails(null)} />
            <motion.div initial={{ y: "100%" }} animate={{ y: 0 }} exit={{ y: "100%" }} className="relative z-10 bg-white w-full max-w-md rounded-t-3xl md:rounded-3xl p-0 flex flex-col shadow-2xl overflow-hidden max-h-[80vh]">
              <div className="px-6 py-5 border-b border-[#F0F0F0] flex items-center justify-between">
                <div>
                  <h2 className="text-[17px] font-extrabold text-[#0A0A0A]">{t("modal.responses.title")}</h2>
                  <p className="text-[11px] text-[#AAAAAA]">{t("modal.responses.sub", { group: selectedRequestForDetails.groupeSanguin, count: responses.length.toString() })}</p>
                </div>
                <button onClick={() => setSelectedRequestForDetails(null)} className="p-2 rounded-xl bg-[#F5F5F5] hover:bg-[#EBEBEB]">
                  <X className="w-4 h-4 text-[#555555]" />
                </button>
              </div>

              <div className="flex-1 overflow-y-auto p-4 space-y-3 min-h-[250px]">
                {isLoadingResponses && (
                  <div className="flex flex-col items-center justify-center py-12 gap-3">
                    <Loader2 className="w-8 h-8 text-[#CC0000] animate-spin" />
                    <p className="text-xs text-[#AAAAAA]">{t("modal.responses.loading")}</p>
                  </div>
                )}

                {!isLoadingResponses && responses.length === 0 && (
                  <div className="flex flex-col items-center justify-center py-12 text-center opacity-40">
                    <Users className="w-12 h-12 mb-3" />
                    <p className="text-sm font-medium">{t("modal.responses.empty")}</p>
                  </div>
                )}

                {!isLoadingResponses && responses.map((res, i) => (
                  <motion.div
                    key={res._id}
                    initial={{ opacity: 0, scale: 0.95 }}
                    animate={{ opacity: 1, scale: 1 }}
                    transition={{ delay: i * 0.04 }}
                    className="p-4 bg-[#FBFBFB] rounded-2xl border border-[#EBEBEB] flex items-center justify-between"
                  >
                    <div className="flex items-center gap-3">
                      <div className="w-10 h-10 rounded-full bg-[#CC0000] text-white flex items-center justify-center font-bold text-xs uppercase shadow-md shadow-[#CC0000]/20">
                        {res.userId.nom[0]}{res.userId.prenom[0]}
                      </div>
                      <div>
                        <p className="text-[13px] font-bold text-[#111111]">{res.userId.nom} {res.userId.prenom}</p>
                        <p className="text-[11px] text-[#AAAAAA] flex items-center gap-1">
                          <Phone className="w-3 h-3" /> {res.userId.telephone}
                        </p>
                      </div>
                    </div>

                    <div className="flex items-center gap-2">
                      {res.statut === "confirme" ? (
                        <div className="flex items-center gap-1 bg-[#F0FFF4] text-[#1A7A3F] px-2 py-1 rounded-lg text-[10px] font-bold border border-[#1A7A3F]/20">
                          <ShieldCheck className="w-3 h-3" />
                          {t("modal.responses.confirmed")}
                        </div>
                      ) : (
                        <button
                          onClick={() => handleConfirmDonation(res._id)}
                          className="p-2 rounded-xl bg-white border border-[#1A7A3F] text-[#1A7A3F] shadow-sm hover:bg-[#F0FFF4] transition-colors"
                          title={t("modal.responses.confirm_tooltip")}
                        >
                          <CheckCircle className="w-4 h-4" />
                        </button>
                      )}
                      <a href={`tel:${res.userId.telephone}`} className="p-2 rounded-xl bg-white border border-[#EBEBEB] text-[#555555] shadow-sm hover:bg-[#F5F5F5] transition-colors">
                        <Phone className="w-4 h-4" />
                      </a>
                    </div>
                  </motion.div>
                ))}
              </div>

              <div className="p-4 bg-[#FAFAFA] border-t border-[#F0F0F0]">
                <Button onClick={() => setSelectedRequestForDetails(null)} className="w-full bg-[#0A0A0A]">{t("modal.responses.close")}</Button>
              </div>
            </motion.div>
          </div>
        )}
      </AnimatePresence>

      {/* Success Toast */}
      <AnimatePresence>
        {successMessage && (
          <motion.div
            initial={{ opacity: 0, y: 50, x: "-50%" }}
            animate={{ opacity: 1, y: 0, x: "-50%" }}
            exit={{ opacity: 0, scale: 0.95, x: "-50%" }}
            className="fixed bottom-24 left-1/2 z-[200] w-[90%] max-w-sm"
          >
            <div className="bg-[#1A7A3F] text-white p-4 rounded-2xl shadow-xl flex items-center gap-3">
              <CheckCircle
                className="w-6 h-6 flex-shrink-0"
              />
              <p className="text-[13px] font-medium leading-tight">
                {successMessage}
              </p>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </HospitalLayout>
  );
}
