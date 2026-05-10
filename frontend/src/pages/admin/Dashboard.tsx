import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import Loading from "../../components/Loading";
import Button from "../../components/Button";
import { supabase } from "../../lib/supabase";
import { Admin, type AdminLeadsPage, type AdminStats } from "../../api/admin";
import { RIASEC_LABELS, type RiasecCode } from "../../types/api";

export default function AdminDashboard() {
  const navigate = useNavigate();
  const [token, setToken] = useState<string | null>(null);
  const [email, setEmail] = useState<string | null>(null);
  const [stats, setStats] = useState<AdminStats | null>(null);
  const [leads, setLeads] = useState<AdminLeadsPage | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let mounted = true;
    (async () => {
      const { data } = await supabase.auth.getSession();
      const session = data.session;
      if (!session) {
        navigate("/admin/login", { replace: true });
        return;
      }
      if (!mounted) return;
      setToken(session.access_token);
      setEmail(session.user.email ?? null);

      try {
        const [s, l] = await Promise.all([
          Admin.stats(session.access_token),
          Admin.leads(session.access_token, 50, 0),
        ]);
        if (!mounted) return;
        setStats(s);
        setLeads(l);
      } catch (e) {
        if (!mounted) return;
        setError(e instanceof Error ? e.message : "Erro carregando dashboard.");
      }
    })();
    return () => {
      mounted = false;
    };
  }, [navigate]);

  async function handleLogout() {
    await supabase.auth.signOut();
    navigate("/admin/login", { replace: true });
  }

  if (error) {
    return (
      <div className="space-y-3">
        <div className="rounded-md bg-rose-50 border border-rose-200 px-4 py-3 text-rose-700">
          {error}
        </div>
        <Button variant="secondary" onClick={handleLogout}>
          Sair
        </Button>
      </div>
    );
  }
  if (!stats || !leads || !token) return <Loading label="Carregando dashboard..." />;

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <p className="text-xs uppercase tracking-wider text-indigo-600 font-semibold">Admin</p>
          <h1 className="text-2xl font-semibold text-slate-900">Dashboard</h1>
          <p className="text-sm text-slate-500">Logado como {email}</p>
        </div>
        <Button variant="secondary" onClick={handleLogout}>
          Sair
        </Button>
      </div>

      <section className="grid grid-cols-2 md:grid-cols-4 gap-3">
        <Kpi label="Leads" value={stats.leads} />
        <Kpi label="Assessments concluídos" value={stats.assessments_completed} />
        <Kpi label="Em andamento" value={stats.assessments_in_progress} />
        <Kpi label="Conversão" value={`${stats.conversion_pct}%`} />
      </section>

      <section className="bg-white rounded-lg shadow-sm border border-slate-200 p-6">
        <h2 className="text-lg font-semibold text-slate-900">Áreas dominantes</h2>
        {stats.dominant_areas.length === 0 ? (
          <p className="text-sm text-slate-500 mt-2">Sem resultados ainda.</p>
        ) : (
          <ul className="mt-3 space-y-2">
            {stats.dominant_areas.map((a) => (
              <li key={a.code} className="flex justify-between text-sm">
                <span className="text-slate-700">
                  {RIASEC_LABELS[a.code as RiasecCode] ?? a.code}
                </span>
                <span className="text-slate-500 tabular-nums">{a.count}</span>
              </li>
            ))}
          </ul>
        )}
      </section>

      <section className="bg-white rounded-lg shadow-sm border border-slate-200 p-6">
        <div className="flex items-baseline justify-between">
          <h2 className="text-lg font-semibold text-slate-900">Leads recentes</h2>
          <span className="text-xs text-slate-500">{leads.total} total</span>
        </div>
        <div className="mt-4 overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="text-left text-xs uppercase tracking-wide text-slate-500 border-b">
                <th className="py-2 pr-3">Nome</th>
                <th className="py-2 pr-3">E-mail</th>
                <th className="py-2 pr-3">Cidade</th>
                <th className="py-2 pr-3">Status</th>
                <th className="py-2 pr-3">Área dominante</th>
                <th className="py-2 pr-3">Criado</th>
              </tr>
            </thead>
            <tbody>
              {leads.items.map((l) => (
                <tr key={l.id} className="border-b last:border-b-0 hover:bg-slate-50">
                  <td className="py-2 pr-3 text-slate-900">{l.full_name}</td>
                  <td className="py-2 pr-3 text-slate-700">{l.email}</td>
                  <td className="py-2 pr-3 text-slate-700">{l.city ?? "—"}</td>
                  <td className="py-2 pr-3">
                    <StatusBadge status={l.assessment_status} />
                  </td>
                  <td className="py-2 pr-3 text-slate-700">{l.dominant_area ?? "—"}</td>
                  <td className="py-2 pr-3 text-slate-500 tabular-nums">
                    {new Date(l.created_at).toLocaleString("pt-BR")}
                  </td>
                </tr>
              ))}
              {leads.items.length === 0 && (
                <tr>
                  <td colSpan={6} className="py-6 text-center text-slate-500">
                    Nenhum lead ainda.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </section>
    </div>
  );
}

function Kpi({ label, value }: { label: string; value: number | string }) {
  return (
    <div className="bg-white rounded-lg shadow-sm border border-slate-200 p-4">
      <p className="text-xs uppercase tracking-wider text-slate-500">{label}</p>
      <p className="mt-1 text-2xl font-semibold text-slate-900 tabular-nums">{value}</p>
    </div>
  );
}

function StatusBadge({ status }: { status: string | null }) {
  if (!status) return <span className="text-slate-400">—</span>;
  const style =
    status === "COMPLETED"
      ? "bg-emerald-100 text-emerald-700"
      : status === "IN_PROGRESS"
        ? "bg-amber-100 text-amber-700"
        : "bg-slate-100 text-slate-600";
  return (
    <span className={`inline-block px-2 py-0.5 rounded text-xs font-medium ${style}`}>
      {status.toLowerCase().replace("_", " ")}
    </span>
  );
}
