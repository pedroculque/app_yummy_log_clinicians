# persistence_foundation

Persistência local do Yummy Log: armazenamento das entradas do diário em Sembast (key-value no disco).

## Funcionalidades

- **MealEntryLocalDataSource:** interface para salvar, listar e remover entradas (como `Map<String, dynamic>`).
- **SembastMealEntryLocalDataSource:** implementação com Sembast; entradas ordenadas por data/hora (mais recente primeiro).
- **Inicialização:** `initPersistence(getIt)` registra o data source e abre o banco; deve ser chamado no startup do app.

## Quick Start

```dart
// No init do app (antes de registrar diary_feature)
initPersistence(getIt);

final ds = getIt<MealEntryLocalDataSource>();
await ds.save('id-1', {'dateTime': '...', 'mealType': '...', ...});
final list = await ds.getAll();
await ds.delete('id-1');
```

## Documentação

| Documento | Descrição |
|-----------|-----------|
| (a criar) | docs/architecture.md – interface, Sembast, schema |
| (a criar) | docs/features.md – lifecycle, migrações (se houver) |

## Estrutura

```
lib/
├── persistence_foundation.dart # Barrel
└── src/
    ├── meal_entry_local_data_source.dart       # Interface
    ├── sembast_meal_entry_local_data_source.dart # Implementação Sembast
    └── persistence_init.dart                   # initPersistence(getIt)
```

## Dependências

- `sembast`, `path_provider`, `path`, `get_it`

## Referências

- [REQUIREMENTS.md](../../../REQUIREMENTS.md) – R5 (persistência local)
- [diary_feature](../../features/diary/README.md) – consome via `MealEntryRepository`
