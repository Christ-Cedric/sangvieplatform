import React, { Component, ErrorInfo, ReactNode } from "react";

interface Props {
  children?: ReactNode;
}

interface State {
  hasError: boolean;
  error: Error | null;
}

export class ErrorBoundary extends Component<Props, State> {
  public state: State = {
    hasError: false,
    error: null,
  };

  public static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error };
  }

  public componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    console.error("Uncaught error:", error, errorInfo);
  }

  public render() {
    if (this.state.hasError) {
      return (
        <div className="min-h-screen flex flex-col items-center justify-center bg-[#F7F7F8] p-6 text-center">
          <div className="w-20 h-20 bg-red-50 rounded-full flex items-center justify-center mb-6">
            <svg className="w-10 h-10 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
            </svg>
          </div>
          <h1 className="text-2xl font-bold text-gray-900 mb-2">Oups ! Quelque chose s'est mal passé.</h1>
          <p className="text-gray-600 mb-8 max-w-md mx-auto">
            Une erreur inattendue est survenue. Veuillez rafraîchir la page ou revenir à l'accueil.
          </p>
          <div className="flex gap-4">
            <button
              onClick={() => window.location.reload()}
              className="px-6 py-2.5 bg-red-600 text-white rounded-xl font-semibold hover:bg-red-700 transition-colors"
            >
              Rafraîchir la page
            </button>
            <a
              href="/home"
              className="px-6 py-2.5 bg-gray-200 text-gray-800 rounded-xl font-semibold hover:bg-gray-300 transition-colors"
            >
              Aller à l'accueil
            </a>
          </div>
          {import.meta.env.DEV && (
            <div className="mt-8 p-4 bg-gray-100 rounded-lg text-left overflow-auto max-w-2xl w-full">
              <p className="text-xs font-mono text-red-800">{this.state.error?.toString()}</p>
              <pre className="text-[10px] mt-2 text-gray-500">{this.state.error?.stack}</pre>
            </div>
          )}
        </div>
      );
    }

    return this.props.children;
  }
}
