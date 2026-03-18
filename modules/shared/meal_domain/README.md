# meal_domain

Pacote **Dart puro** com o modelo de refeição (`MealEntry`, enums relacionados).

## Uso no monorepo

| Consumidor | Motivo |
|------------|--------|
| `patients_feature` | Diário read-only do paciente, Firestore |
| `insights_feature` | Métricas e alertas |
| `sync_foundation` | Sync local ↔ remoto |
| `diary_feature` | UI do diário (app paciente legado neste repo) |

O app **clínico** não depende de `diary_feature` para domínio — apenas de `meal_domain`.
