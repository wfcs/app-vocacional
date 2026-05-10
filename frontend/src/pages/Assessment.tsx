import { useEffect, useMemo, useState } from "react";
import { useLocation, useNavigate, useParams } from "react-router-dom";
import Button from "../components/Button";
import Loading from "../components/Loading";
import ProgressBar from "../components/ProgressBar";
import { Assessments } from "../api/endpoints";
import { ApiError } from "../api/client";
import type { Question } from "../types/api";

type LocationState = { questions?: Question[] } | null;

export default function Assessment() {
  const { assessmentId } = useParams<{ assessmentId: string }>();
  const navigate = useNavigate();
  const { state } = useLocation();
  const initialQuestions = (state as LocationState)?.questions ?? null;

  const [questions] = useState<Question[] | null>(initialQuestions);
  const [answers, setAnswers] = useState<Map<number, number>>(new Map()); // question_id -> option_id
  const [step, setStep] = useState(0);
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // Se entrou direto na URL sem state, voltar pro onboarding
  useEffect(() => {
    if (!questions) navigate("/", { replace: true });
  }, [questions, navigate]);

  const total = questions?.length ?? 0;
  const current = questions?.[step] ?? null;
  const selectedOpt = current ? answers.get(current.id) ?? null : null;

  const allAnswered = useMemo(
    () => total > 0 && answers.size === total,
    [answers, total]
  );

  function pick(option_id: number) {
    if (!current) return;
    const next = new Map(answers);
    next.set(current.id, option_id);
    setAnswers(next);
  }

  function goNext() {
    if (step < total - 1) setStep(step + 1);
  }
  function goPrev() {
    if (step > 0) setStep(step - 1);
  }

  async function handleFinalize() {
    if (!assessmentId || !allAnswered) return;
    setError(null);
    setSubmitting(true);
    try {
      const payload = Array.from(answers.entries()).map(([qid, oid]) => ({
        question_id: qid,
        option_id: oid,
      }));
      await Assessments.answer(assessmentId, payload);
      const result = await Assessments.finalize(assessmentId);
      navigate(`/result/${result.result_id}`);
    } catch (err) {
      if (err instanceof ApiError) {
        setError(typeof err.detail === "string" ? err.detail : `Erro ${err.status}`);
      } else {
        setError("Falha ao processar. Tente novamente.");
      }
    } finally {
      setSubmitting(false);
    }
  }

  if (!questions || !current) return <Loading label="Preparando perguntas..." />;

  return (
    <div className="space-y-6">
      <ProgressBar current={step + 1} total={total} />

      <div className="bg-white rounded-lg shadow-sm border border-slate-200 p-6 md:p-8">
        <h2 className="text-lg font-medium text-slate-900">{current.statement}</h2>
        <ul className="mt-5 space-y-2">
          {current.options.map((opt) => {
            const checked = selectedOpt === opt.id;
            return (
              <li key={opt.id}>
                <button
                  type="button"
                  onClick={() => pick(opt.id)}
                  className={`w-full text-left px-4 py-3 rounded-md border text-sm transition ${
                    checked
                      ? "border-indigo-500 bg-indigo-50 text-indigo-900"
                      : "border-slate-200 bg-white hover:bg-slate-50 text-slate-700"
                  }`}
                >
                  {opt.label}
                </button>
              </li>
            );
          })}
        </ul>
      </div>

      {error && (
        <div className="rounded-md bg-rose-50 border border-rose-200 px-3 py-2 text-sm text-rose-700">
          {error}
        </div>
      )}

      <div className="flex items-center justify-between gap-3">
        <Button variant="secondary" onClick={goPrev} disabled={step === 0 || submitting}>
          Voltar
        </Button>
        {step < total - 1 ? (
          <Button onClick={goNext} disabled={selectedOpt === null}>
            Próxima
          </Button>
        ) : (
          <Button onClick={handleFinalize} disabled={!allAnswered || submitting}>
            {submitting ? "Calculando..." : "Ver resultado"}
          </Button>
        )}
      </div>
    </div>
  );
}
