// Wrapper fino sobre fetch.
// Lança ApiError em status >= 400 com payload do backend.

const BASE = (import.meta.env.VITE_API_BASE_URL ?? "http://localhost:8000").replace(/\/$/, "");

export class ApiError extends Error {
  constructor(public status: number, public detail: unknown) {
    super(typeof detail === "string" ? detail : `HTTP ${status}`);
  }
}

export async function api<T = unknown>(
  path: string,
  init: RequestInit = {}
): Promise<T> {
  const res = await fetch(`${BASE}${path}`, {
    ...init,
    headers: {
      "Content-Type": "application/json",
      ...(init.headers ?? {}),
    },
  });

  return parseResponse<T>(res);
}

export async function apiAuth<T = unknown>(
  path: string,
  token: string,
  init: RequestInit = {}
): Promise<T> {
  const res = await fetch(`${BASE}${path}`, {
    ...init,
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${token}`,
      ...(init.headers ?? {}),
    },
  });
  return parseResponse<T>(res);
}

async function parseResponse<T>(res: Response): Promise<T> {

  if (res.status === 204) {
    return undefined as T;
  }

  let body: unknown = null;
  const text = await res.text();
  if (text) {
    try {
      body = JSON.parse(text);
    } catch {
      body = text;
    }
  }

  if (!res.ok) {
    throw new ApiError(res.status, body);
  }
  return body as T;
}
