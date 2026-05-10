# Setup do Resend (envio real de e-mail)

O backend já está integrado ao [Resend](https://resend.com). Quando `RESEND_API_KEY`
está vazio, o serviço cai no `ConsoleEmailService` (apenas loga). Para ativar envios reais:

## 1. Criar conta
- Acesse https://resend.com/signup
- Confirme o e-mail e faça login

## 2. Obter a API key
- Dashboard → **API Keys** → **Create API Key**
- Nome: `app-vocacional-prod` (ou `dev` se for local)
- Permissão: `Sending access`
- Copie a chave que começa com `re_...` (só aparece uma vez)

## 3. Domínio remetente
Você tem **duas opções**:

### Opção A — Usar o domínio sandbox do Resend (rápido)
- Sender padrão: `onboarding@resend.dev`
- ✅ Funciona imediatamente
- ⚠ Limitado a **100 e-mails/dia** e só envia para o e-mail que você cadastrou

### Opção B — Verificar seu próprio domínio (produção)
- Dashboard → **Domains** → **Add Domain**
- Adicione, p.ex., `vocacional.com.br`
- Configure os registros DNS que o Resend mostrar (TXT, MX, DKIM, SPF)
- Aguarde verificação (~minutos)
- Sender: `noreply@vocacional.com.br`

## 4. Configurar no `.env`

Local:
```bash
# backend/.env
RESEND_API_KEY=re_xxxxxxxxxxxxxxxxxxxxxxxx
EMAIL_FROM=Vocacional <onboarding@resend.dev>
```

Produção (Vercel):
- Settings → Environment Variables
- Adicione `RESEND_API_KEY` e `EMAIL_FROM`
- Re-deploy

## 5. Testar

```bash
cd backend
.venv\Scripts\activate
python tests/smoke_e2e.py
```

Verifique a caixa de entrada do `smoke@example.com` (ajuste o e-mail do smoke test
para um endereço real seu).

## Custos
- Free tier: 100 e-mails/dia, 3.000/mês
- Pro: US$ 20/mês para 50k e-mails/mês

Mais que suficiente para MVP de orientação vocacional.
