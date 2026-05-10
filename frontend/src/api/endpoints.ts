import { api } from "./client";
import type {
  AnswerIn,
  AssessmentStart,
  City,
  Lead,
  LeadCreate,
  Result,
} from "../types/api";

export const Cities = {
  list: (q?: string, limit = 20) => {
    const params = new URLSearchParams();
    if (q) params.set("q", q);
    params.set("limit", String(limit));
    return api<City[]>(`/cities?${params}`);
  },
};

export const Leads = {
  create: (payload: LeadCreate) =>
    api<Lead>("/leads", { method: "POST", body: JSON.stringify(payload) }),
};

export const Assessments = {
  start: (lead_id: string) =>
    api<AssessmentStart>("/assessments", {
      method: "POST",
      body: JSON.stringify({ lead_id }),
    }),
  answer: (assessment_id: string, answers: AnswerIn[]) =>
    api<void>(`/assessments/${assessment_id}/answers`, {
      method: "POST",
      body: JSON.stringify({ answers }),
    }),
  finalize: (assessment_id: string) =>
    api<Result>(`/assessments/${assessment_id}/finalize`, { method: "POST" }),
};

export const Results = {
  get: (result_id: string) => api<Result>(`/results/${result_id}`),
};
