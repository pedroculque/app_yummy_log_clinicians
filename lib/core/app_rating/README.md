# App rating (core)

Implementação do modal e do storage local para o fluxo `AppRating` (pacote `package_app_rating`).

## Documentação

| Documento | Conteúdo |
|-----------|----------|
| [docs/APP_RATING.md](../../../docs/APP_RATING.md) | Regras completas: triggers, config, origens, pedido manual vs automático |

## Ficheiros aqui

- `clinician_app_rating_modal.dart` — UI do diálogo (estrelas, enviar, dismiss por barrier).
- `shared_preferences_rating_storage.dart` — estado persistido (`RatingStorage`).

Registo de `AppRating` e `AppRatingConfig`: [`lib/core/di/injection.dart`](../di/injection.dart).
