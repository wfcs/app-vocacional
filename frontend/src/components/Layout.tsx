import type { ReactNode } from "react";
import { Link } from "react-router-dom";

export default function Layout({ children }: { children: ReactNode }) {
  return (
    <div className="min-h-full flex flex-col">
      <header className="border-b bg-white">
        <div className="max-w-3xl mx-auto px-4 py-4 flex items-center justify-between">
          <Link to="/" className="font-semibold text-lg text-slate-900">
            Teste Vocacional
          </Link>
          <span className="text-xs text-slate-500">RIASEC · Holland</span>
        </div>
      </header>
      <main className="flex-1">
        <div className="max-w-3xl mx-auto px-4 py-8">{children}</div>
      </main>
      <footer className="border-t bg-white">
        <div className="max-w-3xl mx-auto px-4 py-3 text-xs text-slate-500">
          App Vocacional · MVP · Dados sob LGPD
        </div>
      </footer>
    </div>
  );
}
