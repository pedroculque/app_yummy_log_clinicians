# modules/shared

Pacotes Dart/Flutter **transversais** ao app (contrato de features, domínio de refeição, i18n).

| Pacote | Descrição |
|--------|-----------|
| `feature_contract` | Interface `YummyLogFeature` (rotas + DI) |
| `meal_domain` | `MealEntry` e enums (Firestore / app paciente) |
| `yummy_log_l10n` | ARBs pt / es / en |

**Path em pubspec** (a partir de `modules/features/<feature>/`):

```yaml
meal_domain:
  path: ../../shared/meal_domain
```
