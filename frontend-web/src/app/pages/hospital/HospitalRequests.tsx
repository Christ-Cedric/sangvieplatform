import React, { useState, useEffect } from "react";
import { Link } from "react-router";
import { HospitalLayout } from "../../components/layouts";
import { Badge, Button, Input } from "../../components/ui";
import { Plus, X, Droplet, Users, AlertTriangle, Clock, CheckCircle2, Loader2, Phone, ChevronRight, XCircle, ShieldCheck, MessageSquare } from "lucide-react";
import { motion, AnimatePresence } from "motion/react";
import { toast } from "sonner";
import { 
  getMyRequestsApi, 
  createRequestApi, 
  updateRequestStatusApi, 
  getRequestResponsesApi,
  confirmDonationApi,
  type BloodRequest 
} from "../../api";
import { useTranslation } from "../../i18n";

const BLOOD_GROUPS = ["A+", "A-", "B+", "B-", "O+", "O-", "AB+", "AB-"];

const getUrgencyConfig = (t: any) => ({
  critique: { label: t("donor.home.urgency.vital"), bg: "bg-[#CC0000]", light: "bg-[#FFF0F0]", border: "border-[#CC0000]/30", text: "text-[#CC0000]" },
  urgent: { label: t("dashboard.urgency.urgent"), bg: "bg-[#D4720B]", light: "bg-[#FFF8F0]", border: "border-[#D4720B]/30", text: "text-[#D4720B]" },
  normal: { label: t("dashboard.urgency.normal"), bg: "bg-[#555555]", light: "bg-[#F5F5F5]", border: "border-[#EBEBEB]", text: "text-[#555555]" },
});

export function HospitalRequests() {
  const { t } = useTranslation();
  const [requests, setRequests] = useState<BloodRequest[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [showNewRequest, setShowNewRequest] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [successMessage, setSuccessMessage] = useState("");
  
  // New request form
  const [form, setForm] = useState({ 
    bloodGroup: "O+", 
    quantity: "1", 
    urgency: "urgent" as any, 
    description: "" 
  });

  // Responses modal
  const [selectedRequest, setSelectedRequest] = useState<BloodRequest | null>(null);
  const [responses, setResponses] = useState<any[]>([]);
  const [isLoadingResponses, setIsLoadingResponses] = useState(false);

  useEffect(() => {
    fetchRequests();
  }, []);

  const fetchRequests = async () => {
    setIsLoading(true);
    try {
      const data = await getMyRequestsApi();
      setRequests(data);
    } catch (err) {
      // toast.error(t("hospital.requests.loading_error"));
    } finally {
      setIsLoading(false);
    }
  };

  const handleCreate = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsSubmitting(true);
    try {
      await createRequestApi({
        groupeSanguin: form.bloodGroup,
        quantitePoches: parseInt(form.quantity),
        niveauUrgence: form.urgency,
        description: form.description
      });
      setShowNewRequest(false);
      setForm({ bloodGroup: "O+", quantity: "1", urgency: "urgent", description: "" });
      setSuccessMessage(t("hospital.requests.success.published"));
      setTimeout(() => setSuccessMessage(""), 4000);
      fetchRequests();
    } catch (error: any) {
      alert(error.message || t("hospital.requests.error_create"));
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleUpdateStatus = async (id: string, statut: "satisfait" | "annule") => {
    try {
      await updateRequestStatusApi(id, statut);
      setSuccessMessage(statut === "satisfait" ? t("hospital.requests.success.closed") : t("hospital.requests.success.cancelled"));
      setTimeout(() => setSuccessMessage(""), 4000);
      fetchRequests();
    } catch (error) {
      // console.error(error);
    }
  };

  const openResponses = async (req: BloodRequest) => {
    setSelectedRequest(req);
    setResponses([]);
    setIsLoadingResponses(true);
    try {
      const data = await getRequestResponsesApi(req._id);
      setResponses(data);
    } catch (error) {
      // console.error(error);
    } finally {
      setIsLoadingResponses(false);
    }
  };

  const handleConfirmDonation = async (donationId: string) => {
    try {
      await confirmDonationApi(donationId);
      toast.success(t("hospital.requests.success.donation_confirmed"));
      
      // Refresh responses
      if (selectedRequest) {
        const data = await getRequestResponsesApi(selectedRequest._id);
        setResponses(data);
      }
      fetchRequests();
    } catch (err: any) {
      toast.error(err.message || t("hospital.requests.error_confirm"));
    }
  };

  const active = requests.filter((r) => r.statut === "en_attente");
  const closed = requests.filter((r) => r.statut !== "en_attente");

  return (
    <HospitalLayout>
      <div className="max-w-4xl mx-auto">
        {/* ── Header ──────────────────────────────── */}
        <div className="flex items-center justify-between mb-8">
          <div>
            <p className="text-[11px] font-semibold text-[#AAAAAA] uppercase tracking-widest mb-1" style={{ fontFamily: "'DM Sans', sans-serif" }}>
              {t("hospital.requests.sub")}
            </p>
            <h1 className="text-[26px] font-bold text-[#0A0A0A]" style={{ fontFamily: "'DM Sans', sans-serif" }}>
              {t("hospital.requests.title")}
            </h1>
          </div>
          <Button onClick={() => setShowNewRequest(true)} className="flex items-center gap-2">
            <Plus className="w-4 h-4" />
            {t("hospital.requests.new_btn")}
          </Button>
        </div>

        {/* ── Loading state ───────────────────────── */}
        {isLoading && (
          <div className="py-20 flex flex-col items-center justify-center gap-4">
            <Loader2 className="w-8 h-8 text-[#CC0000] animate-spin" />
            <p className="text-[#888888] text-sm">{t("hospital.requests.loading")}</p>
          </div>
        )}

        {/* ── Active requests ─────────────────────── */}
        {!isLoading && (
          <div className="mb-12">
            <div className="flex items-center gap-2 mb-4">
              <div className="w-2 h-2 rounded-full bg-[#CC0000] animate-pulse" />
              <h2 className="text-[15px] font-bold text-[#0A0A0A]" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                {t("hospital.requests.active_title")}
              </h2>
              <span className="ml-1 text-[12px] font-bold text-white bg-[#CC0000] w-5 h-5 rounded-full flex items-center justify-center" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                {active.length}
              </span>
            </div>

            {active.length === 0 && (
              <div className="py-12 bg-white rounded-3xl border border-dashed border-[#E0E0E0] text-center">
                <p className="text-[#AAAAAA] text-sm">{t("hospital.requests.empty")}</p>
              </div>
            )}

            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              {active.map((req, idx) => {
                const cfg = getUrgencyConfig(t)[req.niveauUrgence] || getUrgencyConfig(t).normal;
                return (
                  <motion.div
                    key={req._id}
                    initial={{ opacity: 0, scale: 0.98 }}
                    animate={{ opacity: 1, scale: 1 }}
                    transition={{ delay: idx * 0.05 }}
                    className={`bg-white rounded-2xl border overflow-hidden shadow-[0_1px_8px_rgba(0,0,0,0.05)] flex flex-col ${cfg.border}`}
                  >
                    <div className={`h-1.5 ${cfg.bg}`} />
                    <div className="p-5 flex-1">
                      <div className="flex items-start justify-between mb-4">
                        <div className="flex items-center gap-3">
                          <div className={`w-12 h-12 rounded-xl ${cfg.bg} flex items-center justify-center text-white font-bold text-[14px]`}>
                            {req.groupeSanguin}
                          </div>
                          <div>
                            <p className="text-[14px] font-bold text-[#0A0A0A] leading-tight line-clamp-1">
                              {req.description || t("hospital.requests.default_desc")}
                            </p>
                            <p className="text-[11px] text-[#AAAAAA] mt-1 flex items-center gap-1">
                              <Clock className="w-3 h-3" />
                              {new Date(req.createdAt).toLocaleDateString()}
                            </p>
                          </div>
                        </div>
                        <Badge variant={req.niveauUrgence === "critique" ? "critical" : req.niveauUrgence === "urgent" ? "moderate" : "active"}>
                          {cfg.label}
                        </Badge>
                      </div>

                      <div className="grid grid-cols-2 gap-2 mb-4">
                        <div className={`rounded-xl p-3 ${cfg.light} flex items-center gap-2`}>
                          <Droplet className={`w-4 h-4 ${cfg.text}`} />
                          <div>
                            <p className="text-[9px] font-bold text-[#AAAAAA] uppercase">{t("hospital.requests.quantity_label")}</p>
                            <p className={`text-[13px] font-bold ${cfg.text}`}>{t("hospital.requests.poches", { count: req.quantitePoches.toString() })}</p>
                          </div>
                        </div>
                        <div className="rounded-xl p-3 bg-[#F0FFF4] flex items-center gap-2 border border-[#1A7A3F]/10">
                          <Users className="w-4 h-4 text-[#1A7A3F]" />
                          <div>
                            <p className="text-[9px] font-bold text-[#AAAAAA] uppercase">{t("hospital.requests.type_label")}</p>
                            <p className="text-[13px] font-bold text-[#1A7A3F]">{t("hospital.requests.type_value")}</p>
                          </div>
                        </div>
                      </div>

                      <div className="flex gap-2">
                        <button 
                          onClick={() => openResponses(req)}
                          className="flex-1 py-2 rounded-xl bg-[#0A0A0A] text-white text-[12px] font-bold hover:bg-[#222222] transition-colors"
                        >
                          {t("hospital.requests.view_responses")}
                        </button>
                        <div className="flex gap-2">
                          <button 
                            onClick={() => handleUpdateStatus(req._id, "satisfait")}
                            className="p-2 rounded-xl border border-[#EBEBEB] text-[#1A7A3F] hover:bg-[#F0FFF4] transition-colors"
                            title={t("hospital.requests.tooltip_satisfy")}
                          >
                            <CheckCircle2 className="w-4 h-4" />
                          </button>
                          <button 
                            onClick={() => handleUpdateStatus(req._id, "annule")}
                            className="p-2 rounded-xl border border-[#EBEBEB] text-[#CC0000] hover:bg-[#FFF0F0] transition-colors"
                            title={t("hospital.requests.tooltip_cancel")}
                          >
                            <XCircle className="w-4 h-4" />
                          </button>
                        </div>
                      </div>
                    </div>
                  </motion.div>
                );
              })}
            </div>
          </div>
        )}

        {/* ── History ─────────────────────────────── */}
        {!isLoading && closed.length > 0 && (
          <div>
            <div className="flex items-center gap-2 mb-4">
              <CheckCircle2 className="w-4 h-4 text-[#1A7A3F]" />
              <h2 className="text-[15px] font-bold text-[#0A0A0A]" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                {t("hospital.requests.history_title")}
              </h2>
            </div>
            <div className="space-y-2">
              {closed.slice(0, 5).map((req) => (
                <div key={req._id} className="bg-white rounded-xl border border-[#F0F0F0] p-4 flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <div className="w-10 h-10 rounded-lg bg-[#F5F5F5] flex items-center justify-center font-bold text-[#555555]">
                       {req.groupeSanguin}
                    </div>
                    <div>
                      <p className="text-[13px] font-bold text-[#333333] line-clamp-1">{req.description || t("hospital.requests.default_desc")}</p>
                      <p className="text-[11px] text-[#AAAAAA]">{new Date(req.createdAt).toLocaleDateString()}</p>
                    </div>
                  </div>
                  <Badge variant={req.statut === "satisfait" ? "success" : "critical"}>
                    {req.statut === "satisfait" ? t("hospital.requests.status_satisfied") : t("hospital.requests.status_cancelled")}
                  </Badge>
                </div>
              ))}
            </div>
          </div>
        )}
      </div>

      {/* ── New Request Modal ───────────────────── */}
      <AnimatePresence>
        {showNewRequest && (
          <div className="fixed inset-0 z-[200] flex items-end md:items-center justify-center p-0 md:p-4">
            <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }} className="absolute inset-0 bg-black/60 backdrop-blur-sm" onClick={() => setShowNewRequest(false)} />
            <motion.div initial={{ y: "100%" }} animate={{ y: 0 }} exit={{ y: "100%" }} className="relative z-10 bg-white w-full max-w-lg rounded-t-3xl md:rounded-3xl p-6 md:p-8 flex flex-col shadow-2xl overflow-hidden max-h-[95vh]">
              <div className="flex items-center justify-between mb-8">
                <div>
                  <h2 className="text-[20px] font-extrabold text-[#0A0A0A]">{t("hospital.requests.modal.new_title")}</h2>
                  <p className="text-[12px] text-[#AAAAAA] mt-0.5">{t("hospital.requests.modal.new_sub")}</p>
                </div>
                <button onClick={() => setShowNewRequest(false)} className="p-2.5 rounded-2xl bg-[#F5F5F5] hover:bg-[#EBEBEB]">
                  <X className="w-5 h-5 text-[#555555]" />
                </button>
              </div>

              <form onSubmit={handleCreate} className="space-y-6 overflow-y-auto">
                <div>
                  <label className="block text-[12px] font-bold text-[#333333] uppercase mb-3">{t("hospital.requests.form.blood_group")}</label>
                  <div className="grid grid-cols-4 gap-2">
                    {BLOOD_GROUPS.map((g) => (
                      <button key={g} type="button" onClick={() => setForm({...form, bloodGroup: g})} className={`h-11 rounded-2xl border-2 font-bold transition-all ${form.bloodGroup === g ? "bg-[#CC0000] border-[#CC0000] text-white" : "border-[#EBEBEB] hover:border-[#CC0000]/30"}`}>
                        {g}
                      </button>
                    ))}
                  </div>
                </div>

                 <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-[12px] font-bold text-[#333333] uppercase mb-3">{t("hospital.requests.form.quantity")}</label>
                    <Input type="number" min="1" value={form.quantity} onChange={(e) => setForm({...form, quantity: e.target.value})} required className="h-12" />
                  </div>
                  <div>
                    <label className="block text-[12px] font-bold text-[#333333] uppercase mb-3">{t("hospital.requests.form.urgency")}</label>
                    <select value={form.urgency} onChange={(e) => setForm({...form, urgency: e.target.value})} className="w-full h-12 rounded-2xl border-2 border-[#EBEBEB] px-3 font-bold text-[14px] focus:outline-none focus:border-[#CC0000]">
                      <option value="critique">{t("dashboard.urgency.critical")}</option>
                      <option value="urgent">{t("dashboard.urgency.urgent")}</option>
                      <option value="normal">{t("dashboard.urgency.normal")}</option>
                    </select>
                  </div>
                </div>

                 <div>
                  <label className="block text-[12px] font-bold text-[#333333] uppercase mb-3">{t("hospital.requests.form.description")}</label>
                  <textarea value={form.description} onChange={(e) => setForm({...form, description: e.target.value})} required className="w-full h-24 rounded-2xl border-2 border-[#EBEBEB] p-4 text-sm focus:outline-none focus:border-[#CC0000] resize-none" placeholder={t("hospital.requests.form.placeholder")} />
                </div>

                 <Button type="submit" className="w-full h-14 rounded-2xl text-[16px] font-bold bg-[#CC0000]" disabled={isSubmitting}>
                  {isSubmitting ? <Loader2 className="w-5 h-5 animate-spin mx-auto" /> : t("hospital.requests.form.submit")}
                </Button>
              </form>
            </motion.div>
          </div>
        )}
      </AnimatePresence>

      {/* ── Responses Modal ────────────────────── */}
      <AnimatePresence>
        {selectedRequest && (
          <div className="fixed inset-0 z-[200] flex items-end md:items-center justify-center p-0 md:p-4">
            <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }} className="absolute inset-0 bg-black/60 backdrop-blur-sm" onClick={() => setSelectedRequest(null)} />
            <motion.div initial={{ y: "100%" }} animate={{ y: 0 }} exit={{ y: "100%" }} className="relative z-10 bg-white w-full max-w-lg rounded-t-3xl md:rounded-3xl p-0 flex flex-col shadow-2xl overflow-hidden max-h-[85vh]">
              <div className="px-6 py-5 border-b border-[#F0F0F0] flex items-center justify-between bg-[#FBFBFB]">
                <div>
                  <h2 className="text-[17px] font-extrabold text-[#0A0A0A]">{t("hospital.requests.modal.responses_title", { count: responses.length.toString() })}</h2>
                  <p className="text-[11px] text-[#AAAAAA]">{t("hospital.requests.modal.responses_sub", { group: selectedRequest.groupeSanguin })}</p>
                </div>
                <button onClick={() => setSelectedRequest(null)} className="p-2 rounded-xl bg-white border border-[#EBEBEB]">
                  <X className="w-4 h-4 text-[#555555]" />
                </button>
              </div>

              <div className="flex-1 overflow-y-auto p-4 space-y-3 min-h-[300px]">
                {isLoadingResponses && (
                  <div className="flex flex-col items-center justify-center py-12 gap-3">
                    <Loader2 className="w-8 h-8 text-[#CC0000] animate-spin" />
                    <p className="text-xs text-[#AAAAAA]">{t("hospital.requests.modal.responses_loading")}</p>
                  </div>
                )}
                
                {!isLoadingResponses && responses.length === 0 && (
                  <div className="flex flex-col items-center justify-center py-12 text-center opacity-40">
                    <Users className="w-12 h-12 mb-3" />
                    <p className="text-sm font-medium">{t("hospital.requests.modal.responses_empty")}</p>
                  </div>
                )}

                {!isLoadingResponses && responses.map((res, i) => (
                  <motion.div 
                    key={res._id} 
                    initial={{ opacity: 0, x: -10 }} 
                    animate={{ opacity: 1, x: 0 }} 
                    transition={{ delay: i * 0.05 }}
                    className="p-4 bg-white rounded-2xl border border-[#EBEBEB] flex items-center justify-between"
                  >
                    <div className="flex items-center gap-3">
                      <div className="w-10 h-10 rounded-full bg-[#CC0000]/10 flex items-center justify-center text-[#CC0000] font-bold text-xs">
                        {res.userId.nom[0]}{res.userId.prenom[0]}
                      </div>
                      <div>
                        <p className="text-[13px] font-bold text-[#111111]">{res.userId.nom} {res.userId.prenom}</p>
                        <p className="text-[11px] text-[#AAAAAA] flex items-center gap-1">
                          <Phone className="w-3 h-3" /> {res.userId.telephone}
                        </p>
                        {res.message && (
                          <p className="text-[11px] text-[#CC0000] italic mt-1 bg-[#FFF0F0] px-2 py-0.5 rounded-lg border border-[#CC0000]/10">
                             "{res.message}"
                          </p>
                        )}
                      </div>
                    </div>
                    
                    <div className="flex items-center gap-2">
                       <Link 
                         to="/messages" 
                         className="p-2 rounded-xl bg-white border border-[#EBEBEB] text-[#555555] shadow-sm hover:bg-[#F5F5F5] transition-colors"
                         title={t("messages.title")}
                       >
                         <MessageSquare className="w-4 h-4" />
                       </Link>
                       {res.statut === "confirme" ? (
                         <div className="flex items-center gap-1 bg-[#F0FFF4] text-[#1A7A3F] px-2.5 py-1 rounded-lg text-[10px] font-bold border border-[#1A7A3F]/20">
                            <ShieldCheck className="w-3 h-3" />
                            {t("hospital.requests.modal.responses_confirmed")}
                         </div>
                       ) : (
                         <button 
                           onClick={() => handleConfirmDonation(res._id)}
                           className="p-2 rounded-xl bg-white border border-[#1A7A3F] text-[#1A7A3F] shadow-sm hover:bg-[#F0FFF4] transition-colors"
                           title={t("modal.responses.confirm_tooltip")}
                         >
                           <CheckCircle2 className="w-4 h-4" />
                         </button>
                       )}
                      <a href={`tel:${res.userId.telephone}`} className="p-2 rounded-xl bg-white border border-[#EBEBEB] text-[#555555] shadow-sm hover:bg-[#F5F5F5] transition-colors">
                        <Phone className="w-4 h-4" />
                      </a>
                    </div>
                  </motion.div>
                ))}
              </div>

              <div className="p-4 border-t border-[#F0F0F0]">
                 <Button onClick={() => setSelectedRequest(null)} className="w-full h-11 rounded-xl bg-[#0A0A0A]">{t("modal.responses.close")}</Button>
              </div>
            </motion.div>
          </div>
        )}
      </AnimatePresence>

      {/* ── Toasts ─────────────────────────────── */}
      <AnimatePresence>
        {successMessage && (
          <motion.div initial={{ opacity: 0, y: 50, x: "-50%" }} animate={{ opacity: 1, y: 0, x: "-50%" }} exit={{ opacity: 0, scale: 0.95, x: "-50%" }} className="fixed bottom-10 left-1/2 z-[300] w-[90%] max-w-xs">
            <div className="bg-[#1A7A3F] text-white p-4 rounded-2xl shadow-xl flex items-center gap-3">
              <CheckCircle2 className="w-5 h-5 flex-shrink-0" />
              <p className="text-xs font-bold">{successMessage}</p>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </HospitalLayout>
  );
}
