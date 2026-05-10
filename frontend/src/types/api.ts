// Tipos espelhando os schemas Pydantic do backend.
// Manter alinhado com backend/app/schemas/*

export type City = {
  id: number;
  name: string;
  state_code: string;
};

export type LeadCreate = {
  full_name: string;
  email: string;
  city_id: number;
  consent_lgpd: boolean;
  consent_marketing?: boolean;
};

export type Lead = {
  id: string;
  full_name: string;
  email: string;
  city_id: number;
};

export type QuestionOption = {
  id: number;
  label: string;
};

export type Question = {
  id: number;
  sequence: number;
  statement: string;
  options: QuestionOption[];
};

export type AssessmentStart = {
  assessment_id: string;
  questions: Question[];
};

export type AnswerIn = {
  question_id: number;
  option_id: number;
};

export type ProfessionRec = {
  profession_id: number;
  name: string;
  description: string | null;
  match_score: number;
  rank: number;
};

export type InstitutionRec = {
  institution_id: number;
  institution_name: string;
  institution_type: string;
  city_name: string;
  course_id: number;
  course_name: string;
  course_type: string;
  profession_id: number | null;
  rank: number;
};

export type Result = {
  result_id: string;
  assessment_id: string;
  dominant_area_code: RiasecCode;
  dominant_area_name: string;
  area_scores: Record<RiasecCode, number>;
  top_professions: ProfessionRec[];
  top_institutions: InstitutionRec[];
  email_sent: boolean;
};

export type RiasecCode =
  | "REALISTIC"
  | "INVESTIGATIVE"
  | "ARTISTIC"
  | "SOCIAL"
  | "ENTERPRISING"
  | "CONVENTIONAL";

export const RIASEC_LABELS: Record<RiasecCode, string> = {
  REALISTIC: "Realista",
  INVESTIGATIVE: "Investigativo",
  ARTISTIC: "Artístico",
  SOCIAL: "Social",
  ENTERPRISING: "Empreendedor",
  CONVENTIONAL: "Convencional",
};
