import { createBrowserRouter, Navigate, Outlet } from "react-router";
import { useAuth } from "./AuthContext";

import { SplashPage } from "./pages/Splash";
import { HomePage } from "./pages/Home";
import { UnifiedLogin } from "./pages/auth/UnifiedLogin";
import { Register } from "./pages/auth/Register";
import { ForgotPassword } from "./pages/auth/ForgotPassword";
import { DonorHome } from "./pages/donor/DonorHome";
import { DonorMap } from "./pages/donor/DonorMap";
import { DonorHistory } from "./pages/donor/DonorHistory";
import { DonorProfile } from "./pages/donor/DonorProfile";
import { HospitalDashboard } from "./pages/hospital/HospitalDashboard";
import { HospitalRequests } from "./pages/hospital/HospitalRequests";
import { HospitalStats } from "./pages/hospital/HospitalStats";
import { HospitalProfile } from "./pages/hospital/HospitalProfile";
import { HospitalMap } from "./pages/hospital/HospitalMap";
import { AdminDashboard } from "./pages/admin/AdminDashboard";
import { AdminHospitals } from "./pages/admin/AdminHospitals";
import { AdminUsers } from "./pages/admin/AdminUsers";
import { AdminReports } from "./pages/admin/AdminReports";
import { Messages } from "./pages/shared/Messages";

// ── Guard components ──────────────────────────────────────────────────────────

/** Loader plein écran pour les transitions d'auth */
function AuthLoader() {
  return (
    <div className="min-h-screen flex items-center justify-center bg-[#F7F7F8]">
      <div className="flex flex-col items-center gap-4">
        <div className="w-10 h-10 rounded-full border-4 border-[#CC0000]/20 border-t-[#CC0000] animate-spin" />
        <p className="text-[13px] text-[#888888] font-medium" style={{ fontFamily: "'DM Sans', sans-serif" }}>
          Chargement...
        </p>
      </div>
    </div>
  );
}

/**
 * Guard pour les routes protégées.
 * Si non authentifié → redirige vers /login.
 * Si authentifié mais mauvais rôle → redirige vers son espace.
 */
function RequireAuth({ roles }: { roles?: ("user" | "hospital" | "admin")[] }) {
  const { isAuthenticated, isLoading, user } = useAuth();

  if (isLoading) return <AuthLoader />;

  if (!isAuthenticated) {
    return <Navigate to="/login" replace />;
  }

  // Si des rôles sont exigés et que l'utilisateur n'a pas le bon rôle
  if (roles && user && (!user.role || !roles.includes(user.role))) {
    // Redirige vers son espace par défaut en évitant les boucles infinies
    const target = user.role === "admin" ? "/admin/dashboard" :
                   user.role === "hospital" ? "/hospital/dashboard" :
                   "/donor/home";
    
    // Si on est déjà sur la cible, on ne redirige pas (évite boucle infinie si rôle manquant)
    if (window.location.pathname === target) return <Outlet />;
    
    return <Navigate to={target} replace />;
  }

  return <Outlet />;
}

/**
 * Guard pour les routes publiques (login, register).
 * Si déjà authentifié → redirige vers l'espace correspondant.
 */
function RedirectIfAuthenticated() {
  const { isAuthenticated, isLoading, user } = useAuth();

  if (isLoading) return <AuthLoader />;

  if (isAuthenticated && user) {
    if (user.role === "admin") return <Navigate to="/admin/dashboard" replace />;
    if (user.role === "hospital") return <Navigate to="/hospital/dashboard" replace />;
    return <Navigate to="/donor/home" replace />;
  }

  return <Outlet />;
}

// ── Router ────────────────────────────────────────────────────────────────────

export const router = createBrowserRouter([
  // Page de démarrage
  { path: "/", Component: SplashPage },

  // Pages publiques — redirige si déjà connecté
  {
    element: <RedirectIfAuthenticated />,
    children: [
      { path: "/home", Component: HomePage },
      { path: "/login", Component: UnifiedLogin },
      { path: "/register", Component: Register },
      { path: "/forgot-password", Component: ForgotPassword },
    ],
  },

  // Espace Donneur — rôle "user" uniquement
  {
    element: <RequireAuth roles={["user"]} />,
    children: [
      { path: "/donor/home", Component: DonorHome },
      { path: "/donor/map", Component: DonorMap },
      { path: "/donor/history", Component: DonorHistory },
      { path: "/donor/profile", Component: DonorProfile },
    ],
  },

  // Espace Hôpital — rôle "hospital" uniquement
  {
    element: <RequireAuth roles={["hospital"]} />,
    children: [
      { path: "/hospital/dashboard", Component: HospitalDashboard },
      { path: "/hospital/requests", Component: HospitalRequests },
      { path: "/hospital/stats", Component: HospitalStats },
      { path: "/hospital/map", Component: HospitalMap },
      { path: "/hospital/profile", Component: HospitalProfile },
    ],
  },

  // Espace Admin — rôle "admin" uniquement
  {
    element: <RequireAuth roles={["admin"]} />,
    children: [
      { path: "/admin/dashboard", Component: AdminDashboard },
      { path: "/admin/hospitals", Component: AdminHospitals },
      { path: "/admin/users", Component: AdminUsers },
      { path: "/admin/reports", Component: AdminReports },
    ],
  },

  // Espace Commun — messages
  {
    element: <RequireAuth roles={["user", "hospital"]} />,
    children: [
      { path: "/messages", Component: Messages },
    ],
  },

  // 404 fallback
  {
    path: "*",
    element: (
      <div className="min-h-screen flex flex-col items-center justify-center bg-[#F7F7F8] gap-4">
        <div className="text-[80px] font-bold text-[#E0E0E0]" style={{ fontFamily: "'DM Sans', sans-serif" }}>
          404
        </div>
        <p className="text-[18px] font-bold text-[#333333]" style={{ fontFamily: "'DM Sans', sans-serif" }}>
          Page introuvable
        </p>
        <a
          href="/home"
          className="mt-2 px-5 py-2.5 rounded-xl bg-[#CC0000] text-white text-[14px] font-semibold hover:bg-[#B00000] transition-colors"
          style={{ fontFamily: "'DM Sans', sans-serif" }}
        >
          Retour à l'accueil
        </a>
      </div>
    ),
  },
]);