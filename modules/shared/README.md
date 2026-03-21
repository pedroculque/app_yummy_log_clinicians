# modules/shared

Pacotes Dart/Flutter **transversais** ao app (contrato de features, domínio de refeição, i18n).

| Pacote | Descrição |
|--------|-----------|
| `feature_contract` | Interface `YummyLogFeature` (rotas + DI), `CrashReporter` |
| `meal_domain` | `MealEntry` e enums (Firestore / app paciente) |
| `session_sentry` | `SessionClient` do session logger → Sentry (breadcrumbs + erros com fingerprint; tags `user` / `support_id` com UID) |
| `yummy_log_l10n` | ARBs pt / es / en |

**Path em pubspec** (a partir de `modules/features/<feature>/`):

```yaml
meal_domain:
  path: ../../shared/meal_domain
```
