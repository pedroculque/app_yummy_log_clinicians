# subscription_foundation

Assinaturas com **RevenueCat** (`purchases_flutter`): configuração do SDK, entitlement **`clinicians_pro`** e `SubscriptionEntitlementCubit` (sincronizado com Firebase Auth).

## Documentação

| Documento | Descrição |
|-----------|-----------|
| [MONETIZATION_REVENUECAT.md](../../../docs/MONETIZATION_REVENUECAT.md) | Chaves, dashboard RevenueCat, build |

## Uso no app

- `configureRevenueCat(flavor)` no `main_*` (antes de `configureDependencies`). Chave: `REVENUECAT_API_KEY` (`.env.dev` / `.env.prod` com `--dart-define-from-file` no `launch.json`, ou Fastlane com `--dart-define`), ou overrides `REVENUECAT_APPLE_API_KEY` / `REVENUECAT_GOOGLE_API_KEY`.
- Registrar `SubscriptionEntitlementCubit` no `get_it` após a configuração do SDK.
