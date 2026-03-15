# diary_feature

Feature Diário do Yummy Log: lista de refeições por dia, calendário mensal, adicionar/editar refeição (tipo, sentimento, foto opcional) e persistência local.

## Funcionalidades

- **Tela Diário:** calendário mensal, faixa de dias, cards por refeição (tipo, sentimento, foto/ícone), menu por entrada.
- **Adicionar refeição:** fluxo com foto opcional → tipo de refeição → sentimento + texto livre → campos opcionais (onde, com quem, quanto).
- **Detalhe e edição:** ver entrada e editar pelo mesmo formulário.
- **Persistência:** leitura/escrita via `MealEntryRepository` (usa `persistence_foundation`).
- **Fotos:** armazenamento local de imagens das refeições (`MealPhotoStorage`).

## Quick Start

```dart
// Registro e rotas (app principal)
final feature = DiaryFeature();
feature.registerDependencies(getIt);
final routes = feature.getRoutes(getIt, rootNavigatorKey: rootNavigatorKey);

// Rotas: /diary, /diary/add, /diary/entry/:id, /diary/entry/:id/edit
```

## Documentação

| Documento | Descrição |
|-----------|-----------|
| (a criar) | docs/architecture.md – camadas, cubits, repositório |
| (a criar) | docs/features.md – fluxos, calendário, formulário |

## Estrutura

```
lib/
├── diary_feature.dart          # Barrel + classe DiaryFeature
└── src/
    ├── diary_feature.dart      # YummyLogFeature: deps + rotas
    ├── cubit/                  # DiaryCubit, EntryDetailCubit
    ├── data/                   # MealEntryRepository
    ├── domain/                 # MealEntry, enums (MealType, FeelingLabel, etc.)
    ├── pages/                  # DiaryPage, AddMealPage, EntryDetailPage
    ├── l10n/                   # meal_entry_labels (tipos/sentimentos)
    └── util/                   # MealPhotoStorage
```

## Dependências

- `persistence_foundation` – persistência local (Sembast)
- `feature_contract` – interface `YummyLogFeature`
- `ui_kit`, `yummy_log_l10n`, `go_router`, `flutter_bloc`, `image_picker`, `path_provider`

## Referências

- [REQUIREMENTS.md](../../../REQUIREMENTS.md) – R2–R4, R6, R9–R22 (diário e adicionar refeição)
- [docs/ROADMAP.md](../../../docs/ROADMAP.md) – fases do produto
