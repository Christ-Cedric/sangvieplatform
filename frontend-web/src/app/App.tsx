import React from "react";
import { RouterProvider } from "react-router";
import { router } from "./routes";
import { LanguageProvider } from "./i18n";
import { AuthProvider } from "./AuthContext";
import { ErrorBoundary } from "./components/ErrorBoundary";

export default function App() {
  return (
    <ErrorBoundary>
      <AuthProvider>
        <LanguageProvider>
          <RouterProvider router={router} />
        </LanguageProvider>
      </AuthProvider>
    </ErrorBoundary>
  );
}
