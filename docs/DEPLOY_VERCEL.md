# Deploy combinado na Vercel

O repo é um monorepo (`backend/` Python + `frontend/` Vite). Solução: **2 projetos
Vercel separados** apontando para o mesmo repo, cada um com seu Root Directory.

Faça uma vez. Depois cada `git push origin main` redeploya tudo automaticamente.

---

## Pré-requisitos
- Conta Vercel logada com a mesma org do GitHub `wfcs`
- Repositório `wfcs/app-vocacional` já está público

---

## 1. Deploy do Backend (FastAPI)

1. https://vercel.com/new → **Import** o repo `wfcs/app-vocacional`
2. Configure:
   - **Project Name:** `app-vocacional-backend`
   - **Framework Preset:** Other
   - **Root Directory:** `backend`
   - **Build Command:** *(deixe vazio — Vercel detecta `vercel.json`)*
   - **Output Directory:** *(vazio)*
   - **Install Command:** `pip install -r requirements.txt`
3. **Environment Variables** (todas em `Production`, `Preview`, `Development`):
   ```
   SUPABASE_URL              = https://vimxebnhbmtqegkjifvq.supabase.co
   SUPABASE_SERVICE_KEY      = <pegar service_role no dashboard Supabase → Settings → API>
   ADMIN_EMAILS              = felipeatalaia.s7@gmail.com
   CORS_ORIGINS              = https://app-vocacional-frontend.vercel.app,http://localhost:5173
   RESEND_API_KEY            = <opcional — re_xxx do Resend>
   EMAIL_FROM                = Vocacional <onboarding@resend.dev>
   TOP_PROFESSIONS           = 5
   TOP_INSTITUTIONS          = 5
   ```
   ⚠ **Importante:** use a `service_role` real (não a `anon`), porque o backend
   precisa bypassar RLS para gravar leads/answers/results.
4. **Deploy**
5. Anote a URL gerada, ex.: `https://app-vocacional-backend.vercel.app`
6. Sanity check:
   ```
   curl https://app-vocacional-backend.vercel.app/health
   # → {"status":"ok"}
   ```

---

## 2. Deploy do Frontend (React + Vite)

1. https://vercel.com/new → **Import** o mesmo repo `wfcs/app-vocacional`
2. Configure:
   - **Project Name:** `app-vocacional-frontend`
   - **Framework Preset:** Vite
   - **Root Directory:** `frontend`
   - **Build Command:** `npm run build`
   - **Output Directory:** `dist`
   - **Install Command:** `npm install`
3. **Environment Variables**:
   ```
   VITE_API_BASE_URL       = https://app-vocacional-backend.vercel.app
   VITE_SUPABASE_URL       = https://vimxebnhbmtqegkjifvq.supabase.co
   VITE_SUPABASE_ANON_KEY  = eyJhbGc...HkPs   (a anon legacy)
   ```
4. **Deploy**
5. URL final: `https://app-vocacional-frontend.vercel.app`

---

## 3. Atualizar CORS do backend

Volte ao projeto **backend** → Settings → Environment Variables → edite:
```
CORS_ORIGINS = https://app-vocacional-frontend.vercel.app,http://localhost:5173
```
e clique **Redeploy** no último deployment.

---

## 4. Criar usuário admin (se ainda não fez)

Veja [`docs/ADMIN_SETUP.md`](./ADMIN_SETUP.md). Resumo:
1. Dashboard Supabase → Authentication → Users → **Add user**
2. E-mail: `felipeatalaia.s7@gmail.com`, senha forte, **Auto Confirm User: ✓**

---

## 5. Smoke test em produção

```bash
# Cidades
curl "https://app-vocacional-backend.vercel.app/cities?q=são&limit=3"

# Frontend (abre no browser)
open https://app-vocacional-frontend.vercel.app
```

Fluxo manual:
1. Onboarding → preencher → Iniciar
2. 40 perguntas (era 12 — expandimos na 4.1)
3. Resultado com profissões + instituições
4. `https://app-vocacional-frontend.vercel.app/admin/login` → entrar com admin

---

## 6. Custos
- **Vercel Hobby:** US$ 0/mês — suficiente para MVP (100GB bandwidth/mês,
  100GB-h serverless functions/mês).
- **Supabase Free:** US$ 0/mês — 500MB DB, 2GB bandwidth, 50k MAUs Auth.
- **Resend Free:** US$ 0/mês — 100 e-mails/dia, 3k/mês.

Total: **US$ 0/mês** até decolar.

---

## 7. Domínio próprio (opcional)
- Comprar `vocacional.com.br` (Registro.br)
- Vercel → projeto frontend → Settings → Domains → adicionar `vocacional.com.br`
- Configurar DNS (Vercel mostra os registros)
- Atualizar `CORS_ORIGINS` no backend para incluir o novo domínio
