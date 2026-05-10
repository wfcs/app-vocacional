import { useState } from "react";
import { useNavigate } from "react-router-dom";
import Button from "../../components/Button";
import { supabase } from "../../lib/supabase";

export default function AdminLogin() {
  const navigate = useNavigate();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError(null);
    setSubmitting(true);
    const { error } = await supabase.auth.signInWithPassword({ email, password });
    setSubmitting(false);
    if (error) {
      setError(error.message);
      return;
    }
    navigate("/admin/dashboard");
  }

  return (
    <div className="max-w-md mx-auto bg-white rounded-lg shadow-sm border border-slate-200 p-6 md:p-8">
      <h1 className="text-2xl font-semibold text-slate-900">Admin · Login</h1>
      <p className="text-sm text-slate-600 mt-1">
        Acesso restrito à equipe.
      </p>
      <form onSubmit={handleSubmit} className="mt-6 space-y-4">
        <div>
          <label className="block text-sm font-medium text-slate-700">E-mail</label>
          <input
            type="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            className="mt-1 w-full rounded-md border border-slate-300 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500"
            autoComplete="email"
          />
        </div>
        <div>
          <label className="block text-sm font-medium text-slate-700">Senha</label>
          <input
            type="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            className="mt-1 w-full rounded-md border border-slate-300 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500"
            autoComplete="current-password"
          />
        </div>
        {error && (
          <div className="rounded-md bg-rose-50 border border-rose-200 px-3 py-2 text-sm text-rose-700">
            {error}
          </div>
        )}
        <Button type="submit" disabled={submitting} className="w-full">
          {submitting ? "Entrando..." : "Entrar"}
        </Button>
      </form>
    </div>
  );
}
