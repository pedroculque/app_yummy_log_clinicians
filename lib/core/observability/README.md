# Observabilidade (sessão + Sentry)

Visão geral, fluxo e privacidade: [docs/OBSERVABILITY.md](../../../docs/OBSERVABILITY.md).

## Session logger vs Firebase Analytics

| | Session logger (`package_session_logger`) | Firebase Analytics |
|---|-----|-----|
| **Objetivo** | Trilho de sessão para suporte e correlação com erros (Sentry) | Métricas de produto e audiência |
| **Destino** | Sentry (`session_sentry` → `SentrySessionClient`), sem Firestore | Firebase / GA |
| **Rotas** | `AnalyticsRouteObserver` com `sessionLogger` (mesmos nomes de ecrã) | Mesmo observer com `logger` |

## DSN e flavors

- O DSN do Sentry vem de `--dart-define=SENTRY_DSN=...` (ver `sentry_dsn.dart`).
- O ambiente Sentry (`options.environment`) é o nome do flavor (`development`, `staging`, `production`).
- `beforeSend` (`package:session_sentry`): remove eventos de compra cancelada pelo utilizador (RevenueCat).
- Não commitar DSN em repositório público; usar CI/segredos ou defines locais.

## Pacote `session_sentry`

- Código em `modules/shared/session_sentry` (reutilizável noutras apps).
- Em cada flush: `LogType.error` → `captureException` com **fingerprint** estável (`session_logger`, `name`, `context`); outras → breadcrumbs.
- Sem `captureMessage` genérico por flush.

## Estratégia de envio

- **Debug:** `SendStrategy.realtime` (mais eventos; útil para testar).
- **Release:** `SendStrategy.onError` (menos volume; flush com erros globais ou fim de sessão conforme o pacote).

## Privacidade

- `sendDefaultPii` está desligado no Sentry.
- Utilizador: apenas ID opaco (UID Firebase), sem email nos scopes.
- Não colocar dados de pacientes ou PII em `data` dos logs; alinhar com a política de analytics do projeto.

## ID de Suporte ↔ Session logger / Sentry

[`init_session_logger_user_binding`](init_session_logger_user_binding.dart) liga `AuthRepository.authStateChanges` a `SessionLogger.setUser(user?.uid)`. O mesmo UID aparece nas **Configurações** como “ID de Suporte” (só com sessão ativa). No Sentry, `SentrySessionClient` define utilizador e tags `user` / `support_id` com esse valor. Ver [docs/OBSERVABILITY.md](../../../docs/OBSERVABILITY.md) § ID de Suporte e [modules/features/settings/docs/support-id.md](../../../modules/features/settings/docs/support-id.md).

## Erros tratados (CrashReporter)

Contrato em `feature_contract`: [`CrashReporter`](../../../modules/shared/feature_contract/lib/crash_reporter.dart). Implementação no app: [`SessionLoggerErrorReporter`](session_logger_error_reporter.dart) — **só** `SessionLogger.error` (um único caminho até ao Sentry: flush → `SentrySessionClient`). Sem `captureException` direto no reporter.

`SessionLogger` é registado no arranque **logo após** `initPersistence` (antes de `initAuth` / `initSync` / `configureDependencies`). `registerCrashReporterIfNeeded` vem a seguir.

No [`bootstrap`](../../../lib/bootstrap.dart) (`FlutterError`, `PlatformDispatcher`, **`BlocObserver.onError`**) os erros globais também vão para `SessionLogger` quando registado.

### Áreas com tag `feature` no Sentry (prioridade produto)

| # | `feature` (tag) | Onde |
|---|-----|-----|
| 1 | `auth` | `FirebaseAuthRepository` (falhas inesperadas no sign-in, `updatePhotoURL`) |
| 2 | `subscription` | `SubscriptionEntitlementCubit` (RevenueCat: sync utilizador, refresh, compra, restore) |
| 3 | `sync` | `SyncService` (watchers, merge, fila, `fullPush`, foto na refeição) |
| 4 | `photo_storage` | `PhotoUploadService` (upload/download refeição e perfil) |
| 5 | `patients` | `PatientsCubit` (lista, convite, remover paciente) |
| 6 | `patient_diary` | `PatientDiaryCubit` (stream e refresh) |
| 7 | `form_config` | `FormConfigCubit` (watch e gravação) |
| 8 | `diary` | `DiaryCubit`, `EntryDetailCubit` |
| 9 | `insights` / `patient_analytics` | `InsightsCubit`, `PatientAnalyticsCubit` |
| 10 | `settings_auth` / `notifications` | `AuthCubit` (definições), `ClinicianNotificationService` (FCM / token) |

Filtrar no Sentry por `feature:subscription` (etc.) ou por `hint` (ex.: `purchase_or_offerings`).
