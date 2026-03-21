# session_sentry — Arquitetura

## Responsabilidade

- **`SentrySessionClient`**: implementa `SessionClient` do `package_session_logger`. No flush da sessão: `LogType.error` → `Sentry.captureException` (fingerprint `session_logger` + `name` + `context`); outros tipos → breadcrumbs; atualiza tags/contextos de sessão no scope. Em **`setUserId`**: `SentryUser(id)` + tags `user` e `support_id` (UID Firebase no app clínico, igual ao ID de Suporte nas Configurações).
- **`sentryBeforeSend`**: callback opcional para `SentryFlutter.init` (ex. descartar cancelamento de compra).

## Dependências

- `package_session_logger` (git mobile-foundation)
- `sentry_flutter`

## Consumo

O **app** regista `SessionLoggerImpl(..., clients: [SentrySessionClient()])` e importa `package:session_sentry/session_sentry.dart`. Documentação de produto: `docs/OBSERVABILITY.md` na raiz do repositório do app.
