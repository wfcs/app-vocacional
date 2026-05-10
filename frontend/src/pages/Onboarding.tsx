import { useState } from "react";
import { useNavigate } from "react-router-dom";
import Button from "../components/Button";
import CityCombobox from "../components/CityCombobox";
import { Assessments, Leads } from "../api/endpoints";
import { sessionStore } from "../lib/storage";
import { ApiError } from "../api/client";
import type { City } from "../types/api";

export default function Onboarding() {
  const navigate = useNavigate();
  const [fullName, setFullName] = useState("");
  const [email, setEmail] = useState("");
  const [city, setCity] = useState<City | null>(null);
  const [consentLgpd, setConsentLgpd] = useState(false);
  const [consentMarketing, setConsentMarketing] = useState(false);
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const canSubmit =
    fullName.trim().length >= 2 &&
    /\S+@\S+\.\S+/.test(email) &&
    city !== null &&
    consentLgpd &&
    !submitting;

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!canSubmit || !city) return;
    setError(null);
    setSubmitting(true);
    try {
      const lead = await Leads.create({
        full_name: fullName.trim(),
        email: email.trim().toLowerCase(),
        city_id: city.id,
        consent_lgpd: consentLgpd,
        consent_marketing: consentMarketing,
      });
      sessionStore.setLead(lead.id);
      const ass = await Assessments.start(lead.id);
      sessionStore.setAssessment(ass.assessment_id);
      // passa as perguntas via state do router para evitar nova request
      navigate(`/assessment/${ass.assessment_id}`, { state: { questions: ass.questions } });
    } catch (err) {
      if (err instanceof ApiError) {
        setError(extractMsg(err.detail) ?? `Erro ${err.status}`);
      } else {
        setError("Falha ao enviar. Verifique sua conexão.");
      }
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <div className="bg-white rounded-lg shadow-sm border border-slate-200 p-6 md:p-8">
      <h1 className="text-2xl font-semibold text-slate-900">Descubra qual carreira combina com você</h1>
      <p className="text-sm text-slate-600 mt-2">
        Responda 12 perguntas baseadas no modelo RIASEC e receba um relatório com profissões,
        cursos e instituições da sua cidade.
      </p>

      <form onSubmit={handleSubmit} className="mt-8 space-y-5">
        <div>
          <label className="block text-sm font-medium text-slate-700">Nome completo</label>
          <input
            type="text"
            value={fullName}
            onChange={(e) => setFullName(e.target.value)}
            className="mt-1 w-full rounded-md border border-slate-300 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500"
            placeholder="Maria Silva"
            autoComplete="name"
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-slate-700">E-mail</label>
          <input
            type="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            className="mt-1 w-full rounded-md border border-slate-300 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500"
            placeholder="voce@exemplo.com"
            autoComplete="email"
          />
          <p className="text-xs text-slate-500 mt-1">Enviaremos o relatório para este endereço.</p>
        </div>

        <div>
          <label className="block text-sm font-medium text-slate-700">Cidade</label>
          <div className="mt-1">
            <CityCombobox value={city} onChange={setCity} />
          </div>
          <p className="text-xs text-slate-500 mt-1">
            Vamos sugerir instituições de ensino na sua cidade.
          </p>
        </div>

        <div className="space-y-2 pt-2">
          <label className="flex items-start gap-2 text-sm">
            <input
              type="checkbox"
              checked={consentLgpd}
              onChange={(e) => setConsentLgpd(e.target.checked)}
              className="mt-0.5"
            />
            <span className="text-slate-700">
              Concordo com o tratamento dos meus dados conforme a LGPD para gerar e enviar o resultado.
              <span className="text-rose-600"> *</span>
            </span>
          </label>
          <label className="flex items-start gap-2 text-sm">
            <input
              type="checkbox"
              checked={consentMarketing}
              onChange={(e) => setConsentMarketing(e.target.checked)}
              className="mt-0.5"
            />
            <span className="text-slate-700">
              Posso receber dicas de carreira por e-mail (opcional).
            </span>
          </label>
        </div>

        {error && (
          <div className="rounded-md bg-rose-50 border border-rose-200 px-3 py-2 text-sm text-rose-700">
            {error}
          </div>
        )}

        <div className="pt-2">
          <Button type="submit" disabled={!canSubmit} className="w-full">
            {submitting ? "Iniciando..." : "Começar teste"}
          </Button>
        </div>
      </form>
    </div>
  );
}

function extractMsg(detail: unknown): string | null {
  if (typeof detail === "string") return detail;
  if (detail && typeof detail === "object" && "detail" in detail) {
    const d = (detail as { detail: unknown }).detail;
    if (typeof d === "string") return d;
    if (Array.isArray(d) && d.length > 0 && typeof d[0]?.msg === "string") return d[0].msg;
  }
  return null;
}
