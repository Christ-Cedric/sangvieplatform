/**
 * api.ts — Client HTTP centralisé pour SangVie
 * Toutes les requêtes vers le backend passent par ici.
 */

const BASE_URL =
  (import.meta as unknown as { env: Record<string, string> }).env
    .VITE_API_URL ?? "http://localhost:5000/api";

// ── Helpers ──────────────────────────────────────────────────────────────────

function getToken(): string | null {
  return localStorage.getItem("sangvie_token");
}

async function request<T>(
  endpoint: string,
  options: RequestInit = {}
): Promise<T> {
  const token = getToken();

  const headers: Record<string, string> = {
    "Content-Type": "application/json",
    ...(options.headers as Record<string, string>),
  };

  if (token) {
    headers["Authorization"] = `Bearer ${token}`;
  }

  const response = await fetch(`${BASE_URL}${endpoint}`, {
    ...options,
    headers,
  });

  const data = await response.json().catch(() => ({ message: "Erreur réseau" }));

  if (!response.ok) {
    if (response.status === 401) {
      localStorage.removeItem("sangvie_token");
      localStorage.removeItem("sangvie_user");
      // On recharge la page pour réinitialiser l'état de l'app si on n'est pas déjà sur login
      if (!window.location.pathname.includes("/login")) {
        window.location.href = "/login";
      }
    }
    const error = new Error(data?.message ?? `Erreur ${response.status}`);
    throw error;
  }

  return data as T;
}

// ── Auth API ──────────────────────────────────────────────────────────────────

export interface LoginResponse {
  _id: string;
  nom: string;
  role: "user" | "hospital" | "admin";
  token: string;
  [key: string]: any;
}

export interface RegisterUserPayload {
  nom: string;
  prenom: string;
  email: string;
  motDePasse: string;
  telephone: string;
  lieuResidence: string;
  groupeSanguin: string;
}

export interface RegisterHospitalPayload {
  nom: string;
  email: string;
  motDePasse: string;
  numeroAgrement: string;
  contact: string;
  region: string;
  localisation: string;
}

/** Login universel — identifier (email/tel/user), ou les anciens champs directs */
export async function loginApi(payload: {
  identifier?: string;
  telephone?: string;
  contact?: string;
  nomUtilisateur?: string;
  motDePasse: string;
}): Promise<LoginResponse> {
  return request<LoginResponse>("/auth/login", {
    method: "POST",
    body: JSON.stringify(payload),
  });
}

/** Inscription donneur */
export async function registerUserApi(
  payload: RegisterUserPayload
): Promise<LoginResponse> {
  return request<LoginResponse>("/auth/register-user", {
    method: "POST",
    body: JSON.stringify(payload),
  });
}

/** Inscription hôpital */
export async function registerHospitalApi(
  payload: RegisterHospitalPayload
): Promise<LoginResponse> {
  return request<LoginResponse>("/auth/register-hospital", {
    method: "POST",
    body: JSON.stringify(payload),
  });
}

// ── Requests (demandes de sang) ───────────────────────────────────────────────

export interface BloodRequest {
  _id: string;
  hospitalId: {
    _id: string;
    nom: string;
    region: string;
    localisation: string;
  };
  groupeSanguin: string;
  quantitePoches: number;
  niveauUrgence: "normal" | "urgent" | "critique";
  description: string;
  dateDemande: string;
  statut: "en_attente" | "satisfait" | "annule";
  createdAt: string;
}

export async function getRequestsApi() {
  return request<BloodRequest[]>("/requests");
}

/** Route hospitalière pour créer une demande */
export async function createRequestApi(payload: {
  groupeSanguin: string;
  quantitePoches: number;
  niveauUrgence: "normal" | "urgent" | "critique";
  description: string;
}) {
  return request<BloodRequest>("/hospitals/request", {
    method: "POST",
    body: JSON.stringify(payload),
  });
}

/** Route hospitalière pour voir ses propres demandes */
export async function getMyRequestsApi() {
  return request<BloodRequest[]>("/hospitals/my-requests");
}

export async function updateHospitalProfileApi(data: any) {
  return request<any>("/hospitals/profile", {
    method: "PUT",
    body: JSON.stringify(data),
  });
}

// ── Users ─────────────────────────────────────────────────────────────────────

export async function updateDonorStatusApi(status: "actif" | "inactif") {
  return request<any>("/users/status", {
    method: "PUT",
    body: JSON.stringify({ statutDonneur: status }),
  });
}

export async function getMyDonationsApi() {
  return request<any[]>("/users/my-donations");
}

// ── Messages ─────────────────────────────────

export interface Message {
  _id: string;
  senderId: string;
  senderType: string;
  receiverId: string;
  receiverType: string;
  content: string;
  createdAt: string;
  isRead: boolean;
  requestId?: string;
  donationId?: string;
}

export interface Conversation {
  otherId: string;
  otherType: string;
  otherName: string;
  lastMessage: string;
  date: string;
  isRead: boolean;
}

export async function sendMessageApi(payload: {
  receiverId: string;
  receiverType: string;
  content: string;
  requestId?: string;
  donationId?: string;
}) {
  return request<Message>("/messages", {
    method: "POST",
    body: JSON.stringify(payload),
  });
}

export async function getConversationsApi() {
  return request<Conversation[]>("/messages/conversations");
}

export async function getMessagesApi(otherId: string) {
  return request<Message[]>(`/messages/${otherId}`);
}

export async function respondToRequestApi(requestId: string, message?: string) {
  return request<any>(`/users/respond/${requestId}`, {
    method: "POST",
    body: JSON.stringify({ message }),
  });
}

export async function updateUserProfileApi(data: any) {
  return request<any>("/users/profile", {
    method: "PUT",
    body: JSON.stringify(data),
  });
}

// ── Hospitals ─────────────────────────────────────────────────────────────────

export async function getHospitalStatsApi() {
  return request<any>("/hospitals/stats");
}

export async function getRequestResponsesApi(requestId: string) {
  return request<any[]>(`/hospitals/request-responses/${requestId}`);
}

export async function updateRequestStatusApi(requestId: string, statut: string) {
  return request<any>(`/hospitals/request/${requestId}`, {
    method: "PUT",
    body: JSON.stringify({ statut }),
  });
}

export async function getHospitalNotificationsApi() {
  return request<any[]>("/hospitals/notifications");
}

export async function markHospitalNotificationsAsReadApi() {
  return request<any>("/hospitals/notifications/read", {
    method: "PUT",
  });
}

export async function confirmDonationApi(donationId: string) {
  return request<any>(`/hospitals/confirm-donation/${donationId}`, {
    method: "PUT",
  });
}

export async function updateHospitalApi(hospitalId: string, payload: any) {
  return request<any>(`/hospitals/${hospitalId}`, {
    method: "PUT",
    body: JSON.stringify(payload),
  });
}

// ── ADMIN ────────────────────────────────────

export async function getPendingHospitalsApi() {
  return request<any[]>("/admin/pending-hospitals");
}

export async function getAllHospitalsApi() {
  return request<any[]>("/admin/hospitals");
}

export async function getAllUsersApi() {
  return request<any[]>("/admin/users");
}

export async function verifyHospitalApi(hospitalId: string) {
  return request<any>(`/admin/verify-hospital/${hospitalId}`, {
    method: "PUT",
  });
}

export async function deleteAccountApi(id: string, type: "User" | "Hospital") {
  return request<any>(`/admin/account/${id}?type=${type}`, {
    method: "DELETE",
  });
}

export async function getAdminStatsApi() {
  return request<any>("/admin/stats");
}

export async function getAdminReportsApi() {
  return request<any>("/admin/reports");
}
