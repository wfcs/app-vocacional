import { apiAuth } from "./client";

export type AdminStats = {
  leads: number;
  assessments_completed: number;
  assessments_in_progress: number;
  conversion_pct: number;
  dominant_areas: { code: string; count: number }[];
};

export type AdminLeadRow = {
  id: string;
  full_name: string;
  email: string;
  city: string | null;
  created_at: string;
  assessment_status: string | null;
  dominant_area: string | null;
};

export type AdminLeadsPage = {
  total: number;
  items: AdminLeadRow[];
  limit: number;
  offset: number;
};

export const Admin = {
  me: (token: string) => apiAuth<{ id: string; email: string }>("/admin/me", token),
  stats: (token: string) => apiAuth<AdminStats>("/admin/stats", token),
  leads: (token: string, limit = 50, offset = 0) =>
    apiAuth<AdminLeadsPage>(`/admin/leads?limit=${limit}&offset=${offset}`, token),
};
