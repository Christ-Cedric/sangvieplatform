import React, { createContext, useContext, useState, useEffect, useCallback } from "react";
import type { LoginResponse } from "./api";

// ── Types ─────────────────────────────────────────────────────────────────────

export type UserRole = "user" | "hospital" | "admin";

export interface AuthUser {
  _id: string;
  nom: string;
  role: UserRole;
  email?: string;
  prenom?: string;
  telephone?: string;
  lieuResidence?: string;
  contact?: string;
  region?: string;
  localisation?: string;
  numeroAgrement?: string;
  verified?: boolean;
  createdAt?: string;
  groupeSanguin?: string; // Ajouté pour le donneur
  [key: string]: any;
}

interface AuthContextValue {
  user: AuthUser | null;
  token: string | null;
  isLoading: boolean;
  isAuthenticated: boolean;
  login: (data: LoginResponse) => void;
  logout: () => void;
}

// ── Storage keys ──────────────────────────────────────────────────────────────

const TOKEN_KEY = "sangvie_token";
const USER_KEY = "sangvie_user";

// ── Context ───────────────────────────────────────────────────────────────────

const AuthContext = createContext<AuthContextValue | null>(null);

// ── Provider ──────────────────────────────────────────────────────────────────

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<AuthUser | null>(null);
  const [token, setToken] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  // Restore session from localStorage on mount
  useEffect(() => {
    try {
      const storedToken = localStorage.getItem(TOKEN_KEY);
      const storedUser = localStorage.getItem(USER_KEY);
      if (storedToken && storedUser) {
        setToken(storedToken);
        setUser(JSON.parse(storedUser));
      }
    } catch {
      // Corrupted storage — clear it
      localStorage.removeItem(TOKEN_KEY);
      localStorage.removeItem(USER_KEY);
    } finally {
      setIsLoading(false);
    }
  }, []);

  /** Appelé après un login ou register réussi */
  const login = useCallback((data: LoginResponse) => {
    const { token: _, ...userData } = data; // On retire le token de l'objet user
    const authUser: AuthUser = userData as AuthUser;

    localStorage.setItem(TOKEN_KEY, data.token);
    localStorage.setItem(USER_KEY, JSON.stringify(authUser));
    setToken(data.token);
    setUser(authUser);
  }, []);

  /** Vide la session */
  const logout = useCallback(() => {
    localStorage.removeItem(TOKEN_KEY);
    localStorage.removeItem(USER_KEY);
    setToken(null);
    setUser(null);
  }, []);

  return (
    <AuthContext.Provider
      value={{
        user,
        token,
        isLoading,
        isAuthenticated: !!user && !!token,
        login,
        logout,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
}

// ── Hook ──────────────────────────────────────────────────────────────────────

export function useAuth(): AuthContextValue {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error("useAuth must be used inside <AuthProvider>");
  return ctx;
}

/** Retourne la route de redirection selon le rôle */
export function getRoleHome(role: UserRole): string {
  switch (role) {
    case "admin": return "/admin/dashboard";
    case "hospital": return "/hospital/dashboard";
    case "user":
    default: return "/donor/home";
  }
}
