import { useEffect, useState } from "react";
import { Link, useParams } from "react-router-dom";
import Loading from "../components/Loading";
import { Results } from "../api/endpoints";
import { sessionStore } from "../lib/storage";
import type { Result, RiasecCode } from "../types/api";
import { RIASEC_LABELS } from "../types/api";

export default function ResultPage() {
  const { resultId } = useParams<{ resultId: string }>();
  const [data, setData] = useState<Result | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!resultId) return;
    Results.get(resultId)
      .then((r) => {
        setData(r);
        sessionStore.clear();
      })
      .catch(() => setError("Não foi possível carregar o resultado."));
  }, [resultId]);

  if (error) {
    return (
      <div className="rounded-md bg-rose-50 border border-rose-200 px-4 py-3 text-rose-700">
        {error}
      </div>
    );
  }
  if (!data) return <Loading label="Buscando seu resultado..." />;

  const orderedAreas = (Object.keys(RIASEC_LABELS) as RiasecCode[]).sort(
    (a, b) => (data.area_scores[b] ?? 0) - (data.area_scores[a] ?? 0)
  );

  return (
    <div className="space-y-8">
      <section className="bg-white rounded-lg shadow-sm border border-slate-200 p-6 md:p-8">
        <p className="text-xs uppercase tracking-wider text-indigo-600 font-semibold">
          Seu perfil dominante
        </p>
        <h1 className="mt-1 text-3xl font-semibold text-slate-900">
          {data.dominant_area_name}
        </h1>
        <p className="text-sm text-slate-600 mt-2">
          Baseado nas suas respostas, este é o tipo de atividade que mais ressoa com você.
        </p>

        <div className="mt-6 space-y-3">
          {orderedAreas.map((code) => {
            const v = data.area_scores[code] ?? 0;
            const pct = (v * 100).toFixed(0);
            const isDominant = code === data.dominant_area_code;
            return (
              <div key={code}>
                <div className="flex justify-between text-sm">
                  <span
                    className={
                      isDominant ? "font-semibold text-indigo-700" : "text-slate-700"
                    }
                  >
                    {RIASEC_LABELS[code]}
                  </span>
                  <span className="text-slate-500 tabular-nums">{pct}%</span>
                </div>
                <div className="h-2 bg-slate-100 rounded mt-1">
                  <div
                    className={`h-2 rounded transition-all ${
                      isDominant ? "bg-indigo-600" : "bg-slate-300"
                    }`}
                    style={{ width: `${pct}%` }}
                  />
                </div>
              </div>
            );
          })}
        </div>
      </section>

      <section className="bg-white rounded-lg shadow-sm border border-slate-200 p-6 md:p-8">
        <h2 className="text-xl font-semibold text-slate-900">Profissões com maior afinidade</h2>
        <ol className="mt-4 space-y-3">
          {data.top_professions.map((p) => (
            <li
              key={p.profession_id}
              className="flex items-start gap-4 border-b last:border-b-0 pb-3 last:pb-0"
            >
              <div className="shrink-0 w-10 h-10 rounded-full bg-indigo-100 text-indigo-700 flex items-center justify-center font-semibold">
                {p.rank}
              </div>
              <div className="flex-1">
                <div className="flex items-baseline justify-between gap-3">
                  <h3 className="font-medium text-slate-900">{p.name}</h3>
                  <span className="text-sm font-medium text-indigo-700 tabular-nums">
                    {p.match_score.toFixed(0)}% match
                  </span>
                </div>
                {p.description && (
                  <p className="text-sm text-slate-600 mt-1">{p.description}</p>
                )}
              </div>
            </li>
          ))}
        </ol>
      </section>

      <section className="bg-white rounded-lg shadow-sm border border-slate-200 p-6 md:p-8">
        <h2 className="text-xl font-semibold text-slate-900">
          Onde estudar na sua cidade
        </h2>
        {data.top_institutions.length === 0 ? (
          <p className="text-sm text-slate-600 mt-2">
            Ainda não temos instituições cadastradas na sua cidade. Em breve!
          </p>
        ) : (
          <ul className="mt-4 space-y-3">
            {data.top_institutions.map((i) => (
              <li
                key={`${i.institution_id}-${i.course_id}`}
                className="border-b last:border-b-0 pb-3 last:pb-0"
              >
                <div className="flex items-baseline justify-between gap-3">
                  <h3 className="font-medium text-slate-900">{i.institution_name}</h3>
                  <span className="text-xs uppercase tracking-wide text-slate-500">
                    {i.institution_type.replace("_", " ").toLowerCase()}
                  </span>
                </div>
                <p className="text-sm text-slate-700 mt-1">
                  {i.course_name}
                  <span className="text-slate-400"> · {i.course_type.toLowerCase()}</span>
                </p>
                <p className="text-xs text-slate-500 mt-0.5">{i.city_name}</p>
              </li>
            ))}
          </ul>
        )}
      </section>

      <section className="text-center text-sm text-slate-500">
        {data.email_sent ? (
          <p>📧 Enviamos uma cópia do relatório para o seu e-mail.</p>
        ) : (
          <p>O envio do e-mail está temporariamente indisponível, mas o relatório acima é seu!</p>
        )}
        <Link to="/" className="inline-block mt-3 text-indigo-600 hover:underline">
          Refazer o teste
        </Link>
      </section>
    </div>
  );
}
