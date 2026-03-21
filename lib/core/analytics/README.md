# Analytics (core)

| Ficheiro | Função |
|----------|--------|
| `init_analytics_user_binding.dart` | Liga `AuthRepository` a `AnalyticsLogger` (setUserId / reset no logout). |
| `clinicians_analytics_impl.dart` | Implementação de `CliniciansAnalytics` (`cl_*`) e `app_variant=clinicians`. |

Regra de uso: injetar `CliniciansAnalytics?` nos cubits, não nas views — ver [docs/ANALYTICS.md](../../../docs/ANALYTICS.md).

Dicionário de eventos: [docs/ANALYTICS_EVENTS.md](../../../docs/ANALYTICS_EVENTS.md).

Documentação geral: [docs/ANALYTICS.md](../../../docs/ANALYTICS.md).
