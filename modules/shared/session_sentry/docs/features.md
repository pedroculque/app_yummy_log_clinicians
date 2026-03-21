# session_sentry — Funcionalidades

## SentrySessionClient

- Recebe logs do flush do `package_session_logger`.
- **`LogType.error`:** `Sentry.captureException` com fingerprint estável (`session_logger`, nome do log, contexto ou `no_context`).
- **Outros tipos:** breadcrumbs no scope atual.
- Sincroniza tags/contexto de sessão quando aplicável (ver implementação).

## sentryBeforeSend

- Callback para `SentryOptions.beforeSend`.
- Uso típico no app clínico: descartar eventos de **compra cancelada** (RevenueCat / loja), para não poluir o painel.

## Utilizador e suporte

Em `setUserId`, além de `SentryUser(id: …)`, o app define tags **`user`** e **`support_id`** com o Firebase UID, alinhadas ao **ID de Suporte** nas Configurações. Ver `docs/OBSERVABILITY.md` no repositório do app.

## Integração no app

Registo de `SessionLoggerImpl` com `clients: [SentrySessionClient()]` e `SentryFlutter.init` com `beforeSend: sentryBeforeSend`. Fluxo completo: [OBSERVABILITY.md](../../../../docs/OBSERVABILITY.md) na raiz do repositório do app.
