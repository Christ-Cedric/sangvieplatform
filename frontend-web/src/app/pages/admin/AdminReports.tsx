import React from "react";
import { AdminLayout } from "../../components/layouts";
import { Card, Typography, Button } from "../../components/ui";
import { Download, TrendingUp, TrendingDown, Users, Building2, Droplet, Calendar, Loader2, RefreshCw } from "lucide-react";
import { getAdminReportsApi } from "../../api";
import jsPDF from "jspdf";
import autoTable from "jspdf-autotable";
import { useTranslation } from "../../i18n";

export function AdminReports() {
  const { t } = useTranslation();
  const [data, setData] = React.useState<any>(null);
  const [isLoading, setIsLoading] = React.useState(true);

  React.useEffect(() => {
    fetchReports();
  }, []);

  const fetchReports = async () => {
    setIsLoading(true);
    try {
      const res = await getAdminReportsApi();
      setData(res);
    } catch (error) {
      console.error(error);
    } finally {
      setIsLoading(false);
    }
  };

  const handleExportPDF = () => {
    if (!data) return;

    const doc = new jsPDF();
    const dateStr = new Date().toLocaleDateString("fr-FR");

    // Titre
    doc.setFontSize(22);
    doc.setTextColor(204, 0, 0); // #CC0000
    doc.text(t("admin.reports.pdf.title"), 14, 20);

    doc.setFontSize(11);
    doc.setTextColor(100);
    doc.text(`${t("admin.reports.pdf.generated_at")}${dateStr}`, 14, 28);

    // Section Stats Globales
    doc.setFontSize(14);
    doc.setTextColor(0);
    doc.text(t("admin.reports.pdf.global_stats"), 14, 40);

    const totalDonations = data.regionalData.reduce((acc: number, r: any) => acc + r.donations, 0);
    const totalDonors = data.regionalData.reduce((acc: number, r: any) => acc + r.donors, 0);
    const totalHospitals = data.regionalData.reduce((acc: number, r: any) => acc + r.hospitals, 0);

    autoTable(doc, {
      startY: 45,
      head: [[t("admin.reports.pdf.indicator"), t("admin.reports.pdf.value")]],
      body: [
        [t("admin.stats.donations") + " (" + t("admin.dashboard.this_month") + ")", (data.currentMonthDonations || 0).toLocaleString()],
        [t("admin.users.total") + " (" + t("admin.users.active") + ")", (data.activeDonorsCount || 0).toLocaleString()],
        [t("admin.hospitals.total") + " (" + t("hospital.stats.partners") + ")", (data.regionalData.reduce((acc: number, r: any) => acc + r.hospitals, 0) || 0).toString()],
        [t("admin.reports.satisfaction"), `${data.satisfactionRate}%`],
      ],
      theme: "striped",
      headStyles: { fillColor: [204, 0, 0] },
    });

    // Section Détails par Région
    const finalY = (doc as any).lastAutoTable.finalY + 15;
    doc.text(t("admin.reports.regional_details"), 14, finalY);

    autoTable(doc, {
      startY: finalY + 5,
      head: [[t("admin.reports.table.region"), t("admin.reports.table.hospitals"), t("admin.reports.table.donors"), t("admin.reports.table.donations"), t("admin.reports.table.growth")]],
      body: data.regionalData.map((r: any) => [
        r.region,
        r.hospitals,
        r.donors,
        r.donations,
        `${r.growth}%`,
      ]),
      theme: "grid",
      headStyles: { fillColor: [26, 122, 63] }, // Vert pour l'équilibre
    });

    doc.save(`rapport_sangvie_${new Date().toISOString().split("T")[0]}.pdf`);
  };

  if (isLoading || !data) {
    return (
      <AdminLayout>
        <div className="flex flex-col items-center justify-center min-h-[400px] gap-4">
          <Loader2 className="w-10 h-10 text-[#CC0000] animate-spin" />
          <p className="text-[#888888] font-medium">{t("admin.reports.analyzing")}</p>
        </div>
      </AdminLayout>
    );
  }

  const { regionalData, monthlyTrends } = data;
  const totalDonations = regionalData.reduce((acc: number, r: any) => acc + r.donations, 0);
  const totalDonors = regionalData.reduce((acc: number, r: any) => acc + r.donors, 0);
  const totalHospitals = regionalData.reduce((acc: number, r: any) => acc + r.hospitals, 0);
  const avgGrowth = regionalData.length > 0 
    ? (regionalData.reduce((acc: number, r: any) => acc + r.growth, 0) / regionalData.length).toFixed(1)
    : "0";

  const maxDonations = Math.max(...monthlyTrends.map((m: any) => m.donations));

  return (
    <AdminLayout>
      <div>
        <div className="flex flex-col md:flex-row md:items-center justify-between mb-6 gap-4">
          <div>
            <Typography.H1 className="text-[32px] mb-2">{t("admin.reports.title")}</Typography.H1>
            <Typography.Body className="text-[#888888]">
              {t("admin.reports.national_overview")} - {new Date().toLocaleString('fr-FR', { month: 'long', year: 'numeric' })}
            </Typography.Body>
          </div>
          <div className="flex items-center gap-3">
            <Button variant="secondary" onClick={fetchReports} disabled={isLoading} className="bg-white">
              <RefreshCw className={`w-4 h-4 mr-2 ${isLoading ? 'animate-spin' : ''}`} />
              {t("admin.dashboard.refresh") || "Actualiser"}
            </Button>
            <Button className="bg-[#CC0000]" onClick={handleExportPDF}>
              <Download className="w-4 h-4 mr-2" />
              {t("admin.reports.export_btn")}
            </Button>
          </div>
        </div>

        {/* Global KPIs */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          <Card className="bg-gradient-to-br from-[#CC0000] to-[#990000] text-white">
            <div className="flex items-center justify-between mb-2">
              <Droplet className="w-8 h-8 opacity-80" />
              <div className="flex items-center gap-1 text-sm">
                {data.growth?.donations >= 0 ? <TrendingUp className="w-4 h-4" /> : <TrendingDown className="w-4 h-4" />}
                <span>{data.growth?.donations >= 0 ? '+' : ''}{data.growth?.donations || 0}%</span>
              </div>
            </div>
            <Typography.H2 className="text-white text-3xl mb-1">{(data.currentMonthDonations || 0).toLocaleString()}</Typography.H2>
            <Typography.Body className="text-white/90 text-sm">{t("admin.stats.donations")} ({t("admin.dashboard.this_month")})</Typography.Body>
          </Card>

          <Card className="bg-gradient-to-br from-[#1A7A3F] to-[#0F5028] text-white">
            <div className="flex items-center justify-between mb-2">
              <Users className="w-8 h-8 opacity-80" />
              <div className="flex items-center gap-1 text-sm">
                {data.growth?.donors >= 0 ? <TrendingUp className="w-4 h-4" /> : <TrendingDown className="w-4 h-4" />}
                <span>{data.growth?.donors >= 0 ? '+' : ''}{data.growth?.donors || 0}%</span>
              </div>
            </div>
            <Typography.H2 className="text-white text-3xl mb-1">{(data.activeDonorsCount || 0).toLocaleString()}</Typography.H2>
            <Typography.Body className="text-white/90 text-sm">{t("admin.users.active")}</Typography.Body>
          </Card>

          <Card className="bg-gradient-to-br from-[#D4720B] to-[#A85A09] text-white">
            <div className="flex items-center justify-between mb-2">
              <Building2 className="w-8 h-8 opacity-80" />
              <div className="flex items-center gap-1 text-sm">
                {data.growth?.hospitals >= 0 ? <TrendingUp className="w-4 h-4" /> : <TrendingDown className="w-4 h-4" />}
                <span>{data.growth?.hospitals >= 0 ? '+' : ''}{data.growth?.hospitals || 0}%</span>
              </div>
            </div>
            <Typography.H2 className="text-white text-3xl mb-1">{totalHospitals}</Typography.H2>
            <Typography.Body className="text-white/90 text-sm">{t("hospital.stats.partners")}</Typography.Body>
          </Card>

          <Card className="bg-gradient-to-br from-[#111111] to-[#333333] text-white">
            <div className="flex items-center justify-between mb-2">
              <Calendar className="w-8 h-8 opacity-80" />
            </div>
            <Typography.H2 className="text-white text-3xl mb-1">{data.satisfactionRate}%</Typography.H2>
            <Typography.Body className="text-white/90 text-sm">{t("admin.reports.satisfaction")}</Typography.Body>
          </Card>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 mb-8">
          {/* Monthly Trends */}
          <Card>
            <Typography.H2 className="mb-6">{t("admin.reports.monthly_evolution")}</Typography.H2>
            <div className="flex items-end gap-3 h-64">
              {monthlyTrends.map((item: any) => (
                <div key={item.month} className="flex-1 flex flex-col items-center gap-2">
                  <div className="w-full bg-[#F5F5F5] rounded-t-lg flex items-end justify-center relative" style={{ height: "100%" }}>
                    <div
                      className="w-full bg-gradient-to-t from-[#CC0000] to-[#FF3333] rounded-t-lg flex items-end justify-center pb-2 transition-all hover:opacity-80 cursor-pointer"
                      style={{ height: `${maxDonations > 0 ? (item.donations / maxDonations) * 100 : 0}%` }}
                    >
                      <span className="text-white text-xs font-semibold">{item.donations}</span>
                    </div>
                  </div>
                  <Typography.Small className="text-[#888888] font-medium">{item.month}</Typography.Small>
                </div>
              ))}
            </div>
          </Card>

          {/* Regional Distribution */}
          <Card>
            <Typography.H2 className="mb-6">{t("admin.reports.regional_distribution")}</Typography.H2>
            <div className="space-y-4">
              {regionalData.map((region: any) => (
                <div key={region.region} className="flex items-center gap-4">
                  <div className="w-24 flex-shrink-0">
                    <Typography.Body className="font-semibold text-sm">{region.region}</Typography.Body>
                  </div>
                  <div className="flex-1">
                    <div className="flex items-center justify-between mb-1">
                      <Typography.Small className="text-[#888888]">{t("admin.users.donation_count", { count: region.donations.toString() })}</Typography.Small>
                      <div className={`flex items-center gap-1 text-xs ${region.growth > 0 ? 'text-[#1A7A3F]' : 'text-[#CC0000]'}`}>
                        {region.growth > 0 ? <TrendingUp className="w-3 h-3" /> : <TrendingDown className="w-3 h-3" />}
                        {Math.abs(region.growth)}%
                      </div>
                    </div>
                    <div className="w-full h-2 bg-[#F5F5F5] rounded-full overflow-hidden">
                      <div
                        className="h-full bg-gradient-to-r from-[#CC0000] to-[#FF3333] rounded-full transition-all"
                        style={{ width: `${totalDonations > 0 ? (region.donations / totalDonations) * 100 : 0}%` }}
                      />
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </Card>
        </div>

        {/* Detailed Regional Table */}
        <Card>
          <Typography.H2 className="mb-6">{t("admin.reports.regional_details")}</Typography.H2>
          <div className="overflow-x-auto">
            <table className="w-full text-left font-['DM_Sans']">
              <thead className="bg-[#F9F9F9] text-[#888888] text-xs uppercase tracking-wider">
                <tr>
                  <th className="px-6 py-4 font-medium">{t("admin.reports.table.region")}</th>
                  <th className="px-6 py-4 font-medium">{t("admin.reports.table.hospitals")}</th>
                  <th className="px-6 py-4 font-medium">{t("admin.reports.table.donors")}</th>
                  <th className="px-6 py-4 font-medium">{t("admin.reports.table.donations")}</th>
                  <th className="px-6 py-4 font-medium">{t("admin.reports.table.growth")}</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-[#E0E0E0]">
                {regionalData.map((region: any) => (
                  <tr key={region.region} className="hover:bg-[#F9F9F9] transition-colors">
                    <td className="px-6 py-4 font-semibold text-[#111111]">{region.region}</td>
                    <td className="px-6 py-4 text-[#444444]">{region.hospitals}</td>
                    <td className="px-6 py-4 text-[#444444]">{region.donors.toLocaleString()}</td>
                    <td className="px-6 py-4 font-semibold text-[#CC0000]">{region.donations}</td>
                    <td className="px-6 py-4">
                      <div className={`flex items-center gap-1 ${region.growth > 0 ? 'text-[#1A7A3F]' : 'text-[#CC0000]'}`}>
                        {region.growth > 0 ? <TrendingUp className="w-4 h-4" /> : <TrendingDown className="w-4 h-4" />}
                        <span className="font-semibold">{region.growth > 0 ? '+' : ''}{region.growth}%</span>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </Card>
      </div>
    </AdminLayout>
  );
}
