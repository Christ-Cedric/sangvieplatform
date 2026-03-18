import React, { useState, useEffect } from "react";
import { AdminLayout } from "../../components/layouts";
import { Card, Typography, Badge, Button, Input } from "../../components/ui";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogDescription, DialogFooter } from "../../components/ui/dialog";
import { Building2, Search, Filter, MapPin, CheckCircle2, XCircle, Loader2, Trash2, Clock, Phone, Mail, FileText, Calendar as CalendarIcon, ExternalLink } from "lucide-react";
import { getAllHospitalsApi, verifyHospitalApi, deleteAccountApi } from "../../api";
import { useTranslation } from "../../i18n";

export function AdminHospitals() {
  const { t } = useTranslation();
  const [hospitals, setHospitals] = useState<any[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState("");
  const [processingId, setProcessingId] = useState<string | null>(null);
  const [selectedHospital, setSelectedHospital] = useState<any>(null);

  useEffect(() => {
    fetchHospitals();
  }, []);

  const fetchHospitals = async () => {
    setIsLoading(true);
    try {
      const data = await getAllHospitalsApi();
      setHospitals(data);
    } catch (error) {
      console.error("Failed to fetch hospitals", error);
    } finally {
      setIsLoading(false);
    }
  };

  const handleVerify = async (id: string) => {
    setProcessingId(id);
    try {
      await verifyHospitalApi(id);
      setHospitals(hospitals.map(h => h._id === id ? { ...h, verified: true } : h));
    } catch (error) {
      alert(t("admin.hospital.error_verify"));
    } finally {
      setProcessingId(null);
    }
  };

  const handleDelete = async (id: string) => {
    if (!confirm(t("admin.hospitals.confirm_delete"))) return;
    setProcessingId(id);
    try {
      await deleteAccountApi(id, "Hospital");
      setHospitals(hospitals.filter(h => h._id !== id));
    } catch (error) {
      alert(t("admin.hospital.error_delete"));
    } finally {
      setProcessingId(null);
    }
  };

  const filteredHospitals = hospitals.filter((hospital) =>
    hospital.nom.toLowerCase().includes(searchQuery.toLowerCase()) ||
    hospital.region.toLowerCase().includes(searchQuery.toLowerCase())
  );

  return (
    <AdminLayout>
      <div className="p-4 md:p-8 max-w-6xl mx-auto">
        <Typography.H1 className="mb-6">{t("admin.hospitals.title")}</Typography.H1>

        {/* Search and Filters */}
        <div className="flex gap-3 mb-6">
          <div className="flex-1 relative">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-[#888888]" />
            <Input
              placeholder={t("admin.hospitals.search_placeholder")}
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="pl-10"
            />
          </div>
          <Button variant="secondary" onClick={fetchHospitals} disabled={isLoading}>
            {isLoading ? <Loader2 className="w-4 h-4 animate-spin" /> : <Filter className="w-4 h-4 mr-2" />}
            {t("admin.dashboard.refresh")}
          </Button>
        </div>

        {/* Stats Overview */}
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-8">
          <Card>
            <Typography.Small className="text-[#888888] mb-1">{t("admin.hospitals.total")}</Typography.Small>
            <Typography.H2 className="text-3xl">{hospitals.length}</Typography.H2>
          </Card>
          <Card>
            <Typography.Small className="text-[#888888] mb-1">{t("admin.hospitals.verified")}</Typography.Small>
            <Typography.H2 className="text-3xl text-[#1A7A3F]">
              {hospitals.filter((h) => h.verified).length}
            </Typography.H2>
          </Card>
          <Card>
            <Typography.Small className="text-[#888888] mb-1">{t("admin.hospitals.pending")}</Typography.Small>
            <Typography.H2 className="text-3xl text-[#D4720B]">
              {hospitals.filter((h) => !h.verified).length}
            </Typography.H2>
          </Card>
        </div>

        {/* Hospitals List */}
        <div className="space-y-4">
          {isLoading ? (
            <div className="py-20 flex flex-col items-center justify-center gap-4">
              <Loader2 className="w-10 h-10 text-[#CC0000] animate-spin" />
              <p className="text-[#888888]">{t("admin.hospitals.loading_list")}</p>
            </div>
          ) : filteredHospitals.length === 0 ? (
            <div className="py-20 text-center text-[#888888] italic">
              {t("admin.hospitals.none_found")}
            </div>
          ) : (
            filteredHospitals.map((hospital) => (
              <Card key={hospital._id} className="hover:shadow-md transition-shadow">
                <div className="flex items-start justify-between mb-4">
                  <div className="flex items-center gap-3">
                    <div className="w-12 h-12 rounded-xl bg-[#F5F5F7] flex items-center justify-center text-[#CC0000] font-bold">
                      {hospital.nom.substring(0, 2).toUpperCase()}
                    </div>
                    <div>
                      <Typography.H3 className="text-[16px] mb-1">{hospital.nom}</Typography.H3>
                      <div className="flex items-center text-[#888888] text-sm">
                        <MapPin className="w-3.5 h-3.5 mr-1" />
                        {hospital.region} · {hospital.localisation}
                      </div>
                    </div>
                  </div>
                  <Badge variant={hospital.verified ? "success" : "pending"}>
                    {hospital.verified ? (
                      <span className="flex items-center gap-1"><CheckCircle2 className="w-3 h-3" /> {t("profile.verified")}</span>
                    ) : (
                      <span className="flex items-center gap-1"><Clock className="w-3 h-3" /> {t("admin.hospitals.pending")}</span>
                    )}
                  </Badge>
                </div>

                <div className="grid grid-cols-2 sm:grid-cols-4 gap-4 mb-4 py-3 border-t border-b border-[#F0F0F0]">
                  <div>
                    <Typography.Small className="text-[#888888] mb-0.5">{t("profile.license")}</Typography.Small>
                    <Typography.Body className="font-semibold text-sm">{hospital.numeroAgrement}</Typography.Body>
                  </div>
                  <div>
                    <Typography.Small className="text-[#888888] mb-0.5">{t("profile.phone")}</Typography.Small>
                    <Typography.Body className="font-semibold text-sm">{hospital.contact}</Typography.Body>
                  </div>
                  <div>
                    <Typography.Small className="text-[#888888] mb-0.5">Email</Typography.Small>
                    <Typography.Body className="font-semibold text-sm truncate">{hospital.email}</Typography.Body>
                  </div>
                  <div>
                    <Typography.Small className="text-[#888888] mb-0.5">{t("admin.hospitals.registered_on")}</Typography.Small>
                    <Typography.Body className="font-semibold text-sm">
                      {new Date(hospital.createdAt).toLocaleDateString()}
                    </Typography.Body>
                  </div>
                </div>

                <div className="flex gap-2">
                  {!hospital.verified ? (
                    <>
                       <Button 
                        onClick={() => handleVerify(hospital._id)} 
                        disabled={processingId === hospital._id}
                        className="flex-1 h-9 text-xs"
                      >
                        {processingId === hospital._id ? <Loader2 className="w-3 h-3 animate-spin" /> : t("admin.hospitals.approve")}
                      </Button>
                       <Button 
                        variant="secondary" 
                        onClick={() => handleDelete(hospital._id)}
                        disabled={processingId === hospital._id}
                        className="flex-1 h-9 text-xs text-[#CC0000]"
                      >
                        {t("admin.hospital.actions.reject")}
                      </Button>
                    </>
                  ) : (
                    <>
                       <Button 
                        variant="secondary" 
                        size="sm" 
                        className="flex-1 h-9 text-xs"
                        onClick={() => setSelectedHospital(hospital)}
                      >
                        {t("admin.hospitals.details_btn")}
                      </Button>
                      <Button 
                        variant="secondary" 
                        size="sm" 
                        onClick={() => handleDelete(hospital._id)}
                        disabled={processingId === hospital._id}
                        className="flex-shrink-0 w-10 h-9 p-0 text-[#888888] hover:text-[#CC0000]"
                      >
                        <Trash2 className="w-4 h-4" />
                      </Button>
                    </>
                  )}
                </div>
              </Card>
            ))
          )}
        </div>
      </div>

      {/* Hospital Details Modal */}
      <Dialog open={!!selectedHospital} onOpenChange={(open) => !open && setSelectedHospital(null)}>
        <DialogContent className="max-w-2xl p-0 overflow-hidden rounded-3xl border-none shadow-2xl">
          {selectedHospital && (
            <div className="flex flex-col">
              {/* Header with gradient */}
              <div className="bg-gradient-to-br from-[#CC0000] to-[#990000] p-8 text-white relative">
                <div className="flex items-center gap-4">
                  <div className="w-16 h-16 rounded-2xl bg-white/20 backdrop-blur-md flex items-center justify-center text-white font-bold text-2xl shadow-inner">
                    {selectedHospital.nom.substring(0, 2).toUpperCase()}
                  </div>
                  <div>
                     <h2 className="text-2xl font-bold font-sans">{selectedHospital.nom}</h2>
                    <div className="flex items-center gap-2 mt-1 opacity-90">
                      <Badge variant={selectedHospital.verified ? "success" : "pending"} className="bg-white/20 border-white/30 text-white">
                        {selectedHospital.verified ? t("profile.verified") : t("admin.hospitals.pending")}
                      </Badge>
                      <span className="text-xs font-medium">{t("admin.hospitals.registered_on")} {new Date(selectedHospital.createdAt).toLocaleDateString()}</span>
                    </div>
                  </div>
                </div>
              </div>

              {/* Content */}
               <div className="p-8 bg-white grid grid-cols-1 md:grid-cols-2 gap-8">
                <div className="space-y-6">
                  <div>
                    <label className="text-[10px] font-bold text-[#AAAAAA] uppercase tracking-widest block mb-2">{t("admin.hospitals.modal.contact_info")}</label>
                    <div className="space-y-3">
                      <div className="flex items-center gap-3 text-sm text-[#333333]">
                        <div className="w-8 h-8 rounded-lg bg-[#F5F5F7] flex items-center justify-center text-[#CC0000]">
                          <Phone className="w-4 h-4" />
                        </div>
                        <span className="font-semibold">{selectedHospital.contact}</span>
                      </div>
                      <div className="flex items-center gap-3 text-sm text-[#333333]">
                        <div className="w-8 h-8 rounded-lg bg-[#F5F5F7] flex items-center justify-center text-[#CC0000]">
                          <Mail className="w-4 h-4" />
                        </div>
                        <span className="font-semibold">{selectedHospital.email}</span>
                      </div>
                    </div>
                  </div>

                   <div>
                    <label className="text-[10px] font-bold text-[#AAAAAA] uppercase tracking-widest block mb-2">{t("admin.hospital.details.location")}</label>
                    <div className="flex items-start gap-3 text-sm text-[#333333]">
                      <div className="w-8 h-8 rounded-lg bg-[#F5F5F7] flex items-center justify-center text-[#CC0000] flex-shrink-0">
                        <MapPin className="w-4 h-4" />
                      </div>
                      <div>
                        <p className="font-semibold">{selectedHospital.region}</p>
                        <p className="text-[#888888]">{selectedHospital.localisation}</p>
                      </div>
                    </div>
                  </div>
                </div>

                 <div className="space-y-6">
                  <div>
                    <label className="text-[10px] font-bold text-[#AAAAAA] uppercase tracking-widest block mb-2">{t("admin.hospitals.modal.admin_docs")}</label>
                    <div className="p-4 rounded-2xl bg-[#F9F9FB] border border-[#F0F0F2]">
                      <div className="flex items-center gap-3 mb-3">
                        <div className="w-10 h-10 rounded-xl bg-white shadow-sm flex items-center justify-center text-[#CC0000]">
                          <FileText className="w-5 h-5" />
                        </div>
                        <div>
                          <p className="text-xs font-bold text-[#111111]">{t("admin.hospitals.modal.license_label")}</p>
                          <p className="text-sm font-mono text-[#555555]">{selectedHospital.numeroAgrement}</p>
                        </div>
                      </div>
                      <Button variant="secondary" size="sm" className="w-full text-[11px] h-8 bg-white hover:bg-[#F5F5F7]">
                        <ExternalLink className="w-3 h-3 mr-2" />
                        {t("admin.hospitals.modal.view_pdf")}
                      </Button>
                    </div>
                  </div>

                   {!selectedHospital.verified && (
                    <div className="p-4 rounded-2xl bg-[#FFF8F0] border border-[#FFE8CC]">
                      <p className="text-[11px] font-bold text-[#D4720B] mb-2">{t("admin.hospitals.modal.action_required")}</p>
                      <p className="text-[12px] text-[#A35200] leading-relaxed mb-4">
                        {t("admin.hospitals.modal.validation_desc")}
                      </p>
                      <div className="flex gap-2">
                         <Button 
                          className="flex-1 h-9 text-xs" 
                          onClick={() => {
                            handleVerify(selectedHospital._id);
                            setSelectedHospital(null);
                          }}
                        >
                          {t("admin.hospital.actions.validate")}
                        </Button>
                         <Button 
                          variant="secondary" 
                          className="flex-1 h-9 text-xs text-[#CC0000]"
                          onClick={() => {
                            handleDelete(selectedHospital._id);
                            setSelectedHospital(null);
                          }}
                        >
                          {t("admin.hospital.actions.reject")}
                        </Button>
                      </div>
                    </div>
                  )}
                </div>
              </div>

               {/* Footer */}
              <div className="p-6 border-t border-[#F0F0F0] bg-[#FAFAFA] flex justify-end">
                <Button variant="secondary" onClick={() => setSelectedHospital(null)} className="rounded-xl px-8"> {t("admin.hospital.actions.close")} </Button>
              </div>
            </div>
          )}
        </DialogContent>
      </Dialog>
    </AdminLayout>
  );
}
