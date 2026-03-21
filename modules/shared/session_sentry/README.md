# session_sentry

Pacote partilhável: integração **package_session_logger** → **Sentry** (sem Firestore).

## Funcionalidades

- `SentrySessionClient` — `SessionClient` com erros como eventos e resto como breadcrumbs.
- `sentryBeforeSend` — filtro de eventos (ex.: compra cancelada na loja).

## Quick start

```dart
import 'package:session_sentry/session_sentry.dart';

// SentryFlutter.init:
//   ..beforeSend = sentryBeforeSend

// SessionLoggerImpl(
//   clients: [SentrySessionClient()],
//   ...
// )
```

Fingerprints em erros de sessão: `session_logger`, `log.name`, `log.context` (ou `no_context`).

Em `setUserId`, o app clínico define também as tags **`user`** e **`support_id`** (Firebase UID), alinhadas ao ID de Suporte na UI.

## Documentação

| Documento | Descrição |
|-----------|-----------|
| [docs/architecture.md](docs/architecture.md) | Dependências e papel de cada ficheiro |
| [docs/features.md](docs/features.md) | Comportamento do cliente e do `beforeSend` |

No app **Yummy Log Clínicos**, ver também [docs/OBSERVABILITY.md](../../../docs/OBSERVABILITY.md) e [lib/core/observability/README.md](../../../lib/core/observability/README.md).

## Estrutura

```
session_sentry/
├── lib/
│   ├── session_sentry.dart
│   └── src/
│       ├── sentry_before_send.dart
│       └── sentry_session_client.dart
├── docs/
│   └── architecture.md
└── pubspec.yaml
```
