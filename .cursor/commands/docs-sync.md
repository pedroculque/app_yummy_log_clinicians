# /docs-sync - Sincronizar documentação com a implementação

Verifica e atualiza **toda** a documentação do projeto para refletir o código atual (estrutura de pastas, nomes de classes, dependências, rotas).

## Uso

```
/docs-sync
```

Executa uma passagem completa: compara READMEs e docs de cada módulo com o código em `lib/src/`, corrige nomenclatura (ex.: ui_kit em vez de yummy_design_system) e alinha diagramas/rotas com a implementação real.

## Instruções

Execute em ordem, aplicando as correções necessárias.

### 1. Module Growth Standards

- **docs/architecture.md**
  - Estrutura de pastas: conferir que constam todos os arquivos de `lib/src/` (data, domain, l10n, analytics, presentation).
  - Incluir: `adult_indicator.dart`, `adult_indicators_calculator.dart`, `patient_list_view_cubit.dart`, widgets `bmi_gauge.dart`, `child_card.dart`, `patient_limit_modal.dart`, `zscore_table.dart`, pasta `analytics/`.
  - Seção Cubits: incluir `PatientListViewCubit` (toggle grid/lista, persistido).
  - Injeção de dependências: incluir bind de `PatientListViewCubit`.
- **docs/ui-components.md**
  - ChildListPage: mencionar `PatientListViewCubit` no toggle grid/lista e `PatientLimitModal` no plano Free.
  - PhotoService: incluir método `resolvePhotoPath()` na tabela de métodos.
- **docs/features.md** e **docs/who-calculations.md**: conferir se estão alinhados (sem alteração se já corretos).

### 2. Module Sync (foundation/sync/impl)

- **README.md** e **docs/architecture.md**
  - Na estrutura em `data/`, incluir `photo_sync_service.dart` (sync de fotos Storage ↔ local).

### 3. Docs raiz – SYNC.md

- Diagrama do bloco `module_growth_standards`: usar nomes do código (child_repository, measurement_repository, SyncableChild*, child_local_datasource, measurement_local_datasource). Manter Firestore como `patients/` e `patient_photos/` se for o que o sync usa.

### 4. Dependência: yummy_design_system → ui_kit

Em todos os READMEs que citam `yummy_design_system`, trocar para `ui_kit` (o projeto usa ui_kit). Verificar e corrigir em:

- `modules/features/splash/README.md`
- `modules/features/subscription/README.md`
- `modules/features/authentication/README.md`
- `modules/features/app_rating/README.md`
- `modules/foundation/auth/impl/README.md`
- `modules/foundation/force_update/README.md`

### 5. Force Update

- **README.md**: na estrutura de pastas, incluir a pasta `config/` com `force_update_config_keys.dart`.

### 6. docs/ARCHITECTURE.md

- **Fluxo de navegação**: refletir o fluxo real (Splash → Force Update → `/authentication/` ou `/growth/` conforme AppConfig; sem Home/Calendar/Food Log/Profile).
- **Estrutura de rotas**: listar apenas rotas existentes no AppModule: `/`, `/authentication/`, `/auth/`, `/growth/`. Remover referências a HomeModule, CalendarModule, ProfileModule, etc. Incluir link para rotas do Growth Standards em `modules/features/growth_standards/docs/features.md`.

### 7. docs/architecture/module-structure.md

- **features**: listar apenas os módulos que existem em `modules/features/` (growth_standards, splash, app_rating, authentication, subscription). Remover home, calendar, food_log, profile, connection_management se não existirem.
- **Hierarquia**: texto que lista features deve usar a mesma lista real.
- **session**: na estrutura de foundation, incluir `debug/` (log viewer) se existir.

### 8. Analytics – Catálogo de eventos

- **modules/foundation/analytics/core/docs/event-catalog.md**
  - Conferir que todos os eventos das classes `GrowthEvents`, `SubscriptionEvents`, `AppRatingEvents` e `AppEvents` estão listados nas tabelas corretas.
  - Conferir que a coluna "Onde é disparado" reflete os arquivos que chamam cada `log*` (ex.: `ChildCubit`, `GrowthCubit`, `ChildListPage`, `SubscriptionCubit`, `SettingsPage`, `MeasurementsListPage`, `GrowthChartPage`).
  - Se novos eventos forem adicionados no código, incluir no catálogo com nome, parâmetros e local de disparo.
  - User properties: conferir que `patient_count_range` e `user_language` estão documentados.

### 9. Resumo final

Ao terminar, listar:

- Arquivos de documentação alterados.
- Itens verificados e já corretos (sem mudança).
- Qualquer doc que precise de revisão manual (ex.: referências a módulos futuros).

Responda em Português (pt-BR).
