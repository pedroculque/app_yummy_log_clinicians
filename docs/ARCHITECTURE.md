# Arquitetura – YummyLog for Clinicians

Este documento descreve a arquitetura do app do clínico: **roteamento (go_router)** com tab bar, **injeção de dependências (get_it)** e **estrutura de módulos**.

---

## Stack técnica

| Responsabilidade | Pacote | Uso |
|------------------|--------|-----|
| **Roteamento e tab bar** | [go_router](https://pub.dev/packages/go_router) | Rotas declarativas; **StatefulShellRoute** para tab bar (Pacientes \| Insights \| Configurações). |
| **Injeção de dependências** | [get_it](https://pub.dev/packages/get_it) | Service locator: registrar repositórios, serviços e cubits no startup. |
| **Estado** | bloc / flutter_bloc | Cubits por feature; registrados no get_it ou fornecidos via contexto. |
| **Backend remoto** | [cloud_firestore](https://pub.dev/packages/cloud_firestore) | Firestore para leitura de pacientes e refeições. |
| **Autenticação** | [firebase_auth](https://pub.dev/packages/firebase_auth) | Google Sign-In e Apple Sign-In. |
| **UI compartilhada** | ui_kit (git) | Design system; tokens e componentes reutilizáveis. |

---

## go_router e tab bar

O app tem **3 abas** fixas: **Pacientes**, **Insights** e **Configurações**. Cada aba mantém sua própria pilha de navegação.

### Modelo com StatefulShellRoute

- **Shell:** um `StatefulShellRoute` com três **StatefulShellBranch** (um por aba).
- **Branch 0 – Pacientes:** rota base `/patients` e rotas filhas (ex.: `/patients/:id/diary`).
- **Branch 1 – Insights:** rota base `/insights`.
- **Branch 2 – Configurações:** rota base `/settings`.
- **Troca de aba:** `StatefulNavigationShell.goBranch(index)` no `BottomNavigationBar.onTap`.

### Login

Login **NÃO é obrigatório** para navegar pelo app. Quando o usuário tenta convidar pacientes sem estar logado:
1. Mostra um `AlertDialog` explicando que login é necessário
2. Direciona para a aba de Configurações (`context.go('/settings')`)
3. Usuário faz login nas Configurações
4. Volta para aba Pacientes e pode convidar

---

## get_it (injeção de dependências)

- **Instância global:** `getIt` em `lib/core/di/injection.dart`.
- **Configuração no startup:** `await configureDependencies(flavor: …)` registra:
  - `AppBuildFlavorConfig` (development / staging / production) — ex.: debug de tokens push só fora de prod
  - `PatientsFeature` → `PatientsRepository`, `PatientsCubit`, `FormConfigCubit`, `PatientDiaryCubit`
  - `InsightsFeature` → `InsightsCubit`, `SubscriptionEntitlementCubit` (gate Pro), repositórios de métricas
  - `SettingsFeature` → `AuthCubit`
  - Cubits globais: `ThemeModeCubit`, `LocaleCubit`
- **Acesso:** `getIt<PatientsRepository>()`, `getIt<AuthRepository>()`, etc.

---

## Estrutura de módulos

```
modules/
├── shared/
│   ├── feature_contract/   # YummyLogFeature
│   ├── meal_domain/        # MealEntry + enums (Firestore)
│   └── yummy_log_l10n/      # i18n pt/es/en
├── features/
│   ├── patients/           # Feature principal (lista, diário, form config)
│   │   ├── lib/src/
│   │   │   ├── cubit/      # PatientsCubit, FormConfigCubit, PatientDiaryCubit
│   │   │   ├── data/       # Patient, PatientsRepository, FormConfigRepository
│   │   │   ├── pages/      # PatientsPage, PatientDiaryPage, PatientFormConfigPage
│   │   │   └── patients_feature.dart
│   │   └── pubspec.yaml
│   ├── insights/           # Dashboard clínico
│   │   └── ...
│   └── settings/           # Configurações
│       ├── lib/src/
│       │   ├── cubit/      # AuthCubit, AuthState
│       │   ├── pages/      # SettingsPage
│       │   └── settings_feature.dart
│       └── pubspec.yaml
└── foundation/
    ├── auth/               # AuthRepository, LoginPage
    ├── persistence/        # Sembast (cache local)
    └── sync/               # Firestore utilities (do app paciente)
```

### Interface YummyLogFeature

Cada feature implementa:

```dart
abstract class YummyLogFeature {
  String get name;
  void registerDependencies(GetIt getIt);
  List<RouteBase> getRoutes(GetIt getIt, {GlobalKey<NavigatorState>? rootNavigatorKey});
}
```

---

## Fluxo de inicialização

Os entry points (`lib/main_*.dart`) delegam em `launchClinicianApp(flavor)` em [`lib/core/observability/launch_clinician_app.dart`](../lib/core/observability/launch_clinician_app.dart): primeiro `SentryFlutter.init`, depois o corpo abaixo no `appRunner`.

```dart
// Resumo (ver ficheiro para imports e detalhes)
await initPersistence(getIt);
await registerSessionLogger(getIt, prefs: prefs);
registerCrashReporterIfNeeded(getIt);
await initAuth(getIt);
await initRemoteConfig();
await configureRevenueCat(flavor);
initSync(getIt, config: const SyncConfig(watchersEnabled: false));
await configureDependencies(flavor: flavor);
await getIt<AppRating>().trackSession();
await getIt<ThemeModeCubit>().init();
await getIt<LocaleCubit>().init();
final router = createAppRouter();
unawaited(getIt<ClinicianNotificationService>().attachRouter(router));
await bootstrap(() => App(router: router));
```

O **SessionLogger** é registado cedo (após persistência, antes de auth/sync) para capturar falhas precoces e para o `CrashReporter` depender apenas do buffer de sessão.

[`bootstrap`](../lib/bootstrap.dart) regista `AppBlocObserver`: em `onError`, se `SessionLogger` estiver no `GetIt`, grava o erro com `context: 'Bloc:…'` (além de `FlutterError` / `PlatformDispatcher`).

---

## Observabilidade

- **Sentry:** DSN via `--dart-define=SENTRY_DSN`, `environment` = flavor, `sendDefaultPii: false`, `beforeSend` do pacote `session_sentry`.
- **Session logger:** `package_session_logger` + cliente `SentrySessionClient` (módulo `modules/shared/session_sentry`): erros de sessão → evento com fingerprint; resto → breadcrumbs; `appVersion` no config inclui `version+buildNumber` (`register_session_logger`).
- **Erros tratados:** `CrashReporter` (`feature_contract`) → `SessionLoggerErrorReporter` → `SessionLogger.error` (sem `captureException` direto nas features).
- **Rotas:** `AnalyticsRouteObserver` recebe `logger` (Firebase) e `sessionLogger` (trilho de sessão).
- **Utilizador / suporte:** `init_session_logger_user_binding` sincroniza `AuthUser.uid` com o session logger; o mesmo UID aparece como **ID de Suporte** nas Configurações (logado) e nas tags Sentry `user` / `support_id`. Ver [modules/features/settings/docs/support-id.md](../modules/features/settings/docs/support-id.md).

Documentação: [OBSERVABILITY.md](OBSERVABILITY.md), [lib/core/observability/README.md](../lib/core/observability/README.md).

---

## Diferenças do app do paciente

| Aspecto | App Paciente | App Clínico |
|---------|--------------|-------------|
| **Login** | Opcional (pode usar offline) | Opcional (necessário para convidar) |
| **Sync** | Offline-first (Sembast + Firestore) | Online-only (Firestore direto) |
| **Escrita** | Cria/edita refeições | Read-only (visualiza refeições) |
| **Tab bar** | Diário, Conectar, Configurações | Pacientes, Insights, Configurações |

---

## Referências

- [go_router – StatefulShellRoute](https://pub.dev/documentation/go_router/latest/go_router/StatefulShellRoute-class.html)
- [get_it no pub.dev](https://pub.dev/packages/get_it)
- [OBSERVABILITY.md](OBSERVABILITY.md) – Sentry e session logger
- [BACKEND_CONECTAR.md](BACKEND_CONECTAR.md) – Estrutura Firestore
- [FIRESTORE_RULES.md](FIRESTORE_RULES.md) – Regras de segurança e acesso a `users/{userId}`
