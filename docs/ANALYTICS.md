# Analytics (mobile-foundation)

Integração com os pacotes **analytics_core** (`package_analytics`) e **analytics_firebase** (`package_firebase_analytics`) do repositório [mobile-foundation](https://github.com/pedroculque/mobile-foundation), com Firebase Analytics no app do clínico.

---

## Pacotes

| Pubspec | Path no mobile-foundation | Função |
|---------|---------------------------|--------|
| `package_analytics` | `packages/analytics_core` | Abstração `AnalyticsLogger`, `EventParams`, `AnalyticsRouteObserver`, `ConsoleAnalyticsClient`. |
| `package_firebase_analytics` | `packages/analytics_firebase` | `FirebaseAnalyticsClient` (SDK `firebase_analytics`). |

---

## Onde está ligado no app

| Peça | Ficheiro |
|------|----------|
| Registo do logger, `initialize()`, clientes Firebase + fallback | [`lib/core/di/injection.dart`](../lib/core/di/injection.dart) |
| Utilizador analytics ↔ login ( `setUserId` / `resetAnalyticsData` ) | [`lib/core/analytics/init_analytics_user_binding.dart`](../lib/core/analytics/init_analytics_user_binding.dart), chamado no fim de `configureDependencies` |
| Screen views automáticas (navegação) | [`lib/core/router/app_router.dart`](../lib/core/router/app_router.dart) — `observers: [AnalyticsRouteObserver(logger: getIt<AnalyticsLogger>())]` |
| Eventos do fluxo de avaliação (app rating) | `AppRating.onEvent` em `injection.dart` → `AnalyticsLogger.logEvent` |

Se o Firebase não estiver inicializado (`Firebase.apps.isEmpty`), o DI usa só `ConsoleAnalyticsClient` para não quebrar ambientes sem `google-services`.

---

## Comportamento

1. **`AnalyticsLoggerImpl`** com `AnalyticsLoggerConfig(showDebugLogs: kDebugMode)` e targets padrão **Firebase**.
2. **`await analyticsLogger.initialize()`** antes do registo no `GetIt`.
3. **Login:** em cada emissão de `AuthRepository.authStateChanges` com utilizador, `setUserId(uid)`.
4. **Logout:** `resetAnalyticsData()` (comportamento do cliente Firebase no mobile-foundation).
5. **Rotas:** `AnalyticsRouteObserver` regista mudanças de rota; rotas com segmentos numéricos longos são normalizadas (ex. `:id`) conforme a documentação do pacote.

---

## Como enviar eventos no código

Obter o logger já registado:

```dart
import 'package:app_yummy_log_clinicians/core/di/injection.dart';
import 'package:package_analytics/package_analytics.dart';

getIt<AnalyticsLogger>().logEvent('nome_evento', params: {'chave': 'valor'});
```

Ou `logEventWithParams` com `EventParams` para tipagem forte (ver README do `package_analytics`).

---

## Documentação relacionada

| Documento | Conteúdo |
|-----------|----------|
| [APP_RATING.md](APP_RATING.md) | Eventos do modal de avaliação e origens (`origin`) |

---

*Alinhado ao código em `injection.dart`, `app_router.dart` e `init_analytics_user_binding.dart`.*
