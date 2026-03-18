import React, { useState, useEffect } from "react";
import { AdminLayout } from "../../components/layouts";
import { Badge, Input, Button, Card, Typography } from "../../components/ui";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogDescription, DialogFooter } from "../../components/ui/dialog";
import { User, Search, Droplet, Calendar, TrendingUp, Heart, Filter, MoreVertical, Loader2, XCircle, Phone, MapPin, AtSign, Activity, History } from "lucide-react";
import { motion } from "motion/react";
import { getAllUsersApi, deleteAccountApi } from "../../api";
import { useTranslation } from "../../i18n";

const BLOOD_COLORS: Record<string, string> = {
  "O+": "#CC0000", "O-": "#990000",
  "A+": "#D4720B", "A-": "#B05A08",
  "B+": "#5B5BD6", "B-": "#4040A0",
  "AB+": "#1A7A3F", "AB-": "#145F30",
};

export function AdminUsers() {
  const { t } = useTranslation();
  const [users, setUsers] = useState<any[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState("");
  const [filterStatus, setFilterStatus] = useState<"all" | "active" | "inactive">("all");
  const [selectedUser, setSelectedUser] = useState<any>(null);

  React.useEffect(() => {
    fetchUsers();
  }, []);

  const fetchUsers = async () => {
    setIsLoading(true);
    try {
      const data = await getAllUsersApi();
      setUsers(data);
    } catch (error) {
      console.error(error);
    } finally {
      setIsLoading(false);
    }
  };

  const handleDelete = async (id: string) => {
    if (!confirm(t("admin.users.confirm_delete"))) return;
    try {
      await deleteAccountApi(id, "User");
      setUsers(users.filter(u => u._id !== id));
    } catch (error) {
      alert(t("profile.error_save"));
    }
  };

  const filtered = users.filter((u) => {
    const name = u.nom || "";
    const phone = u.telephone || "";
    const matchSearch = name.toLowerCase().includes(searchQuery.toLowerCase()) || phone.includes(searchQuery);
    const status = u.statutDonneur === "actif" ? "active" : "inactive";
    const matchStatus = filterStatus === "all" || status === filterStatus;
    return matchSearch && matchStatus;
  });

  const totalDonations = users.reduce((s, u) => s + (u.donationsCount || 0), 0);

  return (
    <AdminLayout>
      <div className="max-w-5xl mx-auto">

        {/* ── Header ──────────────────────────────── */}
        <div className="mb-8">
          <p className="text-[11px] font-semibold text-[#AAAAAA] uppercase tracking-widest mb-1" style={{ fontFamily: "'DM Sans', sans-serif" }}>
            {t("nav.admin.role")}
          </p>
          <h1 className="text-[26px] font-bold text-[#0A0A0A]" style={{ fontFamily: "'DM Sans', sans-serif" }}>
            {t("admin.users.title")}
          </h1>
        </div>

        {/* ── KPI row ──────────────────────────────── */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
          {[
            { label: t("admin.users.total"), value: users.length.toString(), icon: User, bg: "bg-[#F5F5FF]", color: "text-[#5B5BD6]" },
            { label: t("admin.users.active"), value: users.filter(u => u.statutDonneur === "actif").length.toString(), icon: TrendingUp, bg: "bg-[#F0FFF4]", color: "text-[#1A7A3F]" },
            { label: t("admin.users.donations"), value: totalDonations.toString(), icon: Heart, bg: "bg-[#FFF0F0]", color: "text-[#CC0000]" },
          ].map((s, i) => (
            <motion.div
              key={i}
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: i * 0.07 }}
              className="bg-white rounded-2xl border border-[#EBEBEB] p-4 shadow-[0_1px_8px_rgba(0,0,0,0.05)]"
            >
              <div className={`inline-flex p-2 rounded-xl ${s.bg} mb-2`}>
                <s.icon className={`w-4 h-4 ${s.color}`} />
              </div>
              <p className="text-[24px] font-bold text-[#0A0A0A]" style={{ fontFamily: "'DM Sans', sans-serif" }}>{s.value}</p>
              <p className="text-[12px] text-[#AAAAAA]" style={{ fontFamily: "'DM Sans', sans-serif" }}>{s.label}</p>
            </motion.div>
          ))}
        </div>

        {/* ── Search + Filters ─────────────────────── */}
        <div className="flex gap-3 mb-5">
          <div className="flex-1 relative">
            <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-[#AAAAAA]" />
            <Input
              placeholder={t("admin.users.search_placeholder")}
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="pl-10"
            />
          </div>
          <div className="flex bg-[#F0F0F0] rounded-xl p-1 gap-1">
            {(["all", "active", "inactive"] as const).map((f) => (
              <button
                key={f}
                onClick={() => setFilterStatus(f)}
                className={`px-3 py-1.5 rounded-lg text-[12px] font-semibold transition-all ${
                  filterStatus === f ? "bg-white text-[#0A0A0A] shadow-sm" : "text-[#888888]"
                }`}
                style={{ fontFamily: "'DM Sans', sans-serif" }}
              >
                {f === "all" ? t("admin.users.filter_all") : f === "active" ? t("admin.users.filter_active") : t("admin.users.filter_inactive")}
              </button>
            ))}
          </div>
        </div>

        {/* ── Users Table ─────────────────────────── */}
        <div className="bg-white rounded-2xl border border-[#EBEBEB] overflow-hidden shadow-[0_1px_8px_rgba(0,0,0,0.05)]">
          <div className="px-6 py-4 border-b border-[#F0F0F0] flex items-center justify-between">
            <p className="text-[13px] font-semibold text-[#AAAAAA]" style={{ fontFamily: "'DM Sans', sans-serif" }}>
              {t("admin.users.found_count", { count: filtered.length.toString() })}
            </p>
            <button className="flex items-center gap-1.5 text-[12px] font-semibold text-[#555555] bg-[#F5F5F5] px-3 py-1.5 rounded-xl hover:bg-[#E8E8E8] transition-all" style={{ fontFamily: "'DM Sans', sans-serif" }}>
              <Filter className="w-3.5 h-3.5" />
              {t("admin.users.advanced_filters")}
            </button>
          </div>

          <div className="divide-y divide-[#F8F8F8]">
            {isLoading ? (
              <div className="p-12 flex flex-col items-center justify-center gap-3">
                <Loader2 className="w-8 h-8 text-[#CC0000] animate-spin" />
                <p className="text-sm text-[#AAAAAA]">{t("admin.users.loading_list")}</p>
              </div>
            ) : filtered.length === 0 ? (
              <div className="p-12 text-center text-[#AAAAAA] text-sm italic">
                {t("admin.users.none_found")}
              </div>
            ) : (
              filtered.map((user, idx) => (
                <motion.div
                  key={user._id}
                  initial={{ opacity: 0, x: -8 }}
                  animate={{ opacity: 1, x: 0 }}
                  transition={{ delay: idx * 0.05 }}
                  className="flex items-center gap-4 px-6 py-4 hover:bg-[#FAFAFA] transition-colors group"
                >
                  {/* Avatar */}
                  <div className="w-10 h-10 rounded-full bg-gradient-to-br from-[#CC0000] to-[#990000] flex items-center justify-center text-white text-[13px] font-bold flex-shrink-0">
                    {(user.nom || "U").split(" ").map((n: any) => n[0]).join("").slice(0, 2)}
                  </div>

                  {/* Name + phone */}
                  <div className="flex-1 min-w-0">
                    <p className="text-[14px] font-bold text-[#0A0A0A]" style={{ fontFamily: "'DM Sans', sans-serif" }}>{user.nom}</p>
                    <p className="text-[12px] text-[#AAAAAA]" style={{ fontFamily: "'DM Sans', sans-serif" }}>{user.telephone}</p>
                  </div>

                  {/* Blood group badge */}
                  <div
                    className="w-9 h-9 rounded-xl flex items-center justify-center text-white font-bold text-[12px] flex-shrink-0"
                    style={{ backgroundColor: BLOOD_COLORS[user.groupeSanguin] ?? "#CC0000", fontFamily: "'DM Sans', sans-serif" }}
                  >
                    {user.groupeSanguin}
                  </div>

                  {/* Stats */}
                  <div className="hidden md:flex items-center gap-4">
                    <div className="flex items-center gap-1.5">
                      <Droplet className="w-3.5 h-3.5 text-[#CC0000]" />
                      <span className="text-[13px] font-semibold text-[#333333]" style={{ fontFamily: "'DM Sans', sans-serif" }}>
                        {t("admin.users.donation_count", { count: (user.donationsCount || 0).toString() })}
                      </span>
                    </div>
                  </div>

                   <Badge variant={user.statutDonneur === "actif" ? "success" : "inactive"}>
                    {user.statutDonneur === "actif" ? t("admin.users.status_active") : t("admin.users.status_inactive")}
                  </Badge>

                  {/* Actions */}
                  <div className="flex items-center gap-1 opacity-0 group-hover:opacity-100 transition-all">
                    <button 
                      onClick={() => setSelectedUser(user)}
                      className="w-8 h-8 rounded-xl flex items-center justify-center text-[#888888] hover:bg-[#F5F5F7] hover:text-[#111111]"
                      title="Détails"
                    >
                      <MoreVertical className="w-4 h-4" />
                    </button>
                    <button 
                      onClick={() => handleDelete(user._id)}
                      className="w-8 h-8 rounded-xl flex items-center justify-center text-[#CCCCCC] hover:bg-[#FFF0F0] hover:text-[#CC0000]"
                      title="Supprimer"
                    >
                      <XCircle className="w-4 h-4" />
                    </button>
                  </div>
                </motion.div>
              ))
            )}
          </div>
        </div>
      </div>

      {/* Donor Details Modal */}
      <Dialog open={!!selectedUser} onOpenChange={(open) => !open && setSelectedUser(null)}>
        <DialogContent className="max-w-xl p-0 overflow-hidden rounded-3xl border-none shadow-2xl">
          {selectedUser && (
            <div className="flex flex-col">
              {/* Header */}
              <div className="bg-gradient-to-br from-[#111111] to-[#333333] p-8 text-white relative">
                <div className="flex items-center gap-5">
                  <div 
                    className="w-20 h-20 rounded-2xl flex items-center justify-center text-white text-2xl font-bold shadow-lg"
                    style={{ backgroundColor: BLOOD_COLORS[selectedUser.groupeSanguin] ?? "#CC0000" }}
                  >
                    {selectedUser.groupeSanguin}
                  </div>
                  <div>
                    <h2 className="text-2xl font-bold font-sans">{selectedUser.nom} {selectedUser.prenom}</h2>
                    <div className="flex items-center gap-2 mt-1.5">
                      <Badge variant={selectedUser.statutDonneur === "actif" ? "success" : "inactive"} className="bg-white/10 border-white/20 text-white">
                        {selectedUser.statutDonneur === "actif" ? t("admin.users.modal.donor_active") : t("admin.users.status_inactive")}
                      </Badge>
                      <span className="text-xs text-white/60 font-medium">{t("admin.users.modal.member_since", { date: new Date(selectedUser.createdAt).toLocaleDateString() })}</span>
                    </div>
                  </div>
                </div>
              </div>

              {/* Stats Bar */}
              <div className="grid grid-cols-3 border-b border-[#F0F0F0]">
                <div className="p-4 text-center border-r border-[#F0F0F0]">
                  <p className="text-[10px] font-bold text-[#AAAAAA] uppercase tracking-wider mb-1">{t("admin.stats.donations")}</p>
                  <p className="text-xl font-bold text-[#CC0000]">{selectedUser.donationsCount || 0}</p>
                </div>
                <div className="p-4 text-center border-r border-[#F0F0F0]">
                  <p className="text-[10px] font-bold text-[#AAAAAA] uppercase tracking-wider mb-1">{t("admin.users.modal.rank")}</p>
                  <p className="text-xl font-bold text-[#111111]">Or</p>
                </div>
                <div className="p-4 text-center">
                  <p className="text-[10px] font-bold text-[#AAAAAA] uppercase tracking-wider mb-1">{t("profile.lives_saved")}</p>
                  <p className="text-xl font-bold text-[#1A7A3F]">{(selectedUser.donationsCount || 0) * 3}</p>
                </div>
              </div>

              {/* Body */}
              <div className="p-8 bg-white space-y-6">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div className="space-y-4">
                    <label className="text-[10px] font-bold text-[#AAAAAA] uppercase tracking-widest block">{t("admin.hospital.details.contact")}</label>
                    <div className="space-y-3">
                      <div className="flex items-center gap-3 text-sm">
                        <Phone className="w-4 h-4 text-[#888888]" />
                        <span className="font-semibold">{selectedUser.telephone}</span>
                      </div>
                      <div className="flex items-center gap-3 text-sm">
                        <AtSign className="w-4 h-4 text-[#888888]" />
                        <span className="font-semibold">{selectedUser.email}</span>
                      </div>
                    </div>
                  </div>

                  <div className="space-y-4">
                    <label className="text-[10px] font-bold text-[#AAAAAA] uppercase tracking-widest block">{t("admin.hospital.details.location")}</label>
                    <div className="flex items-start gap-3 text-sm">
                      <MapPin className="w-4 h-4 text-[#888888] flex-shrink-0 mt-0.5" />
                      <div>
                        <p className="font-semibold">{selectedUser.lieuResidence}</p>
                        <p className="text-xs text-[#888888]">Burkina Faso</p>
                      </div>
                    </div>
                  </div>
                </div>

                 <div className="pt-4 border-t border-[#F5F5F5]">
                  <label className="text-[10px] font-bold text-[#AAAAAA] uppercase tracking-widest block mb-4">{t("admin.users.modal.recent_activity")}</label>
                  <div className="space-y-3">
                    <div className="flex items-center justify-between p-3 rounded-xl bg-[#F9F9FB] border border-[#F0F0F2]">
                      <div className="flex items-center gap-3">
                        <div className="w-8 h-8 rounded-lg bg-white shadow-sm flex items-center justify-center text-[#1A7A3F]">
                          <Activity className="w-4 h-4" />
                        </div>
                        <p className="text-sm font-semibold text-[#333333]">{t("admin.users.modal.last_donation")}</p>
                      </div>
                      <p className="text-xs font-medium text-[#888888]">{t("admin.users.modal.last_donation_time")}</p>
                    </div>
                    <Button variant="secondary" className="w-full text-xs h-9 bg-white border-[#E0E0E0] hover:bg-[#F5F5F7]">
                      <History className="w-3.5 h-3.5 mr-2" />
                      {t("admin.users.modal.view_history")}
                    </Button>
                  </div>
                </div>
              </div>

              {/* Footer */}
              <div className="p-6 border-t border-[#F0F0F0] bg-[#FAFAFA] flex items-center justify-between">
                <Button 
                  variant="secondary" 
                  className="text-[#CC0000] border-[#CC0000]/10 bg-[#CC0000]/5 hover:bg-[#CC0000] hover:text-white"
                  onClick={() => {
                    handleDelete(selectedUser._id);
                    setSelectedUser(null);
                  }}
                >
                  {t("admin.users.modal.delete_account")}
                </Button>
                <Button variant="secondary" onClick={() => setSelectedUser(null)} className="rounded-xl px-8"> {t("admin.hospital.actions.close")} </Button>
              </div>
            </div>
          )}
        </DialogContent>
      </Dialog>
    </AdminLayout>
  );
}
