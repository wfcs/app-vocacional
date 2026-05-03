-- =============================================================================
-- 001 — Extensões do PostgreSQL
-- Rodar 1x por banco. Idempotente.
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;   -- gen_random_uuid()
CREATE EXTENSION IF NOT EXISTS citext;     -- e-mail case-insensitive
CREATE EXTENSION IF NOT EXISTS pg_trgm;    -- busca fuzzy de cidades/instituições
