# Setup do Painel Admin

O painel admin (`/admin/login` → `/admin/dashboard`) usa **Supabase Auth** (e-mail + senha)
para login, e o backend valida o JWT e checa contra a whitelist `ADMIN_EMAILS`.

## 1. Criar o usuário admin

### Via Supabase Dashboard (recomendado, 30s)
1. Abra https://supabase.com/dashboard/project/vimxebnhbmtqegkjifvq/auth/users
2. Botão **Add user** → **Create new user**
3. Preencha:
   - **Email:** o mesmo e-mail que está em `ADMIN_EMAILS` no backend (default: `felipeatalaia.s7@gmail.com`)
   - **Password:** uma senha forte
   - **Auto Confirm User:** ✅ marcado (senão o login pede confirmação por e-mail)
4. Salvar

### Via script Python (precisa da `service_role` real, não a anon)
```bash
cd backend
.venv\Scripts\activate
python -c "
from supabase import create_client
import os
c = create_client(os.environ['SUPABASE_URL'], os.environ['SUPABASE_SERVICE_KEY'])
c.auth.admin.create_user({
  'email': 'felipeatalaia.s7@gmail.com',
  'password': 'troque-isso',
  'email_confirm': True,
})
print('ok')
"
```

## 2. Whitelist no backend

`backend/.env`:
```
ADMIN_EMAILS=felipeatalaia.s7@gmail.com,outro@admin.com
```

A whitelist garante que **só** e-mails listados conseguem usar `/admin/*`,
mesmo que outros tokens válidos do Supabase sejam apresentados.

## 3. Acessar

- Local: http://localhost:5173/admin/login
- Produção: https://<seu-frontend>.vercel.app/admin/login

## 4. Endpoints expostos

| Método | Rota | Descrição |
|---|---|---|
| GET | `/admin/me` | Debug — retorna `{id, email}` do admin logado |
| GET | `/admin/stats` | KPIs: leads, conversão, áreas dominantes |
| GET | `/admin/leads?limit=50&offset=0` | Lista paginada de leads + status do assessment |

Todos exigem header `Authorization: Bearer <jwt>` do Supabase Auth.

## 5. Adicionar mais admins
Basta:
1. Criar o user no Supabase Auth
2. Adicionar o e-mail em `ADMIN_EMAILS` no `.env` (separado por vírgula)
3. Re-deploy do backend

## 6. RLS
A tabela `auth.users` é gerenciada pelo Supabase (não tocar). As tabelas do app
têm RLS habilitado: o admin lê tudo via backend (que usa `service_role`,
bypassando RLS). Quando precisarmos liberar leitura direta no Supabase
para algum dashboard externo, criamos policies `TO authenticated USING (auth.email() = ANY(...))`.
