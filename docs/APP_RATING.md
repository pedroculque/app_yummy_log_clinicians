# Avaliação na loja (App Rating)

Documentação do fluxo de pedido de notas à App Store / Play Store e de avaliação in-app no **YummyLog for Clinicians**.

---

## Visão geral

| Conceito | Descrição |
|----------|-----------|
| **Biblioteca** | `package_app_rating` (pacote `app_rating_core` no repositório [mobile-foundation](https://github.com/pedroculque/mobile-foundation), path `packages/app_rating_core`). |
| **Classe principal** | `AppRating` — elegibilidade, estado persistido, modal e integração com `in_app_review` / loja. |
| **Registo DI** | `GetIt` em [`lib/core/di/injection.dart`](../lib/core/di/injection.dart), após `SharedPreferences` e antes das features. |
| **Pedidos automáticos** | `trackAction()` + `requestIfEligible()` em momentos de valor (ver § Pontos de integração). |
| **Pedido manual** | Tile em Configurações → `forceRequest()` (ignora triggers). |

---

## Configuração (`AppRatingConfig`)

Definida em [`lib/core/di/injection.dart`](../lib/core/di/injection.dart) ao construir `AppRating`.

| Campo | Valor no projeto | Notas |
|-------|-------------------|--------|
| `enabled` | *(default do construtor)* | O default em `AppRatingConfig` é **`true`**. Pedidos automáticos via `requestIfEligible` só ocorrem se `enabled` for true. Para desligar sem alterar código do pacote, seria necessário expor `enabled: false` explicitamente. |
| `appleStoreId` | `'0'` | Substituir pelo ID real na App Store Connect quando publicado. |
| `androidPackageId` | `com.yummylogdiaryforclinicians.app` | Usado para abrir a ficha na Play Store quando o in-app review nativo não está disponível. |
| `minRatingForStore` | *(default)* | Default do pacote: **4**. Notas **≥ 4** tendem a abrir In-App Review / loja; **&lt; 4** disparam fluxo interno (eventos/analytics). |
| `triggers` | Ver tabela abaixo | Composição **AND**: todos têm de ser satisfeitos. |

### Triggers (elegibilidade)

Implementação no pacote: `CompositeTrigger.all(config.triggers)` — **todos** os triggers abaixo têm de passar **em simultâneo**.

| Trigger | Parâmetros no app | Significado |
|---------|-------------------|-------------|
| `SessionTrigger` | `minSessions: 6` | Pelo menos **6 sessões** registadas com `trackSession()` (chamado nos `main_*.dart` por arranque do app). |
| `CountTrigger` | `actionsRequired: 10` | Pelo menos **10** chamadas acumuladas a `trackAction()`. Cada “momento feliz” integrado chama `trackAction()` antes de `requestIfEligible`. |
| `TimeTrigger.betweenPrompts` | `days: 30` | Mínimo de **30 dias** desde o último prompt (`lastPromptDate`), ou ainda não houve prompt. |
| `TimeTrigger.afterPostpone` | `days: 7` | Se o utilizador **adiou** o pedido (`isPostponed`), só volta a ser elegível após **7 dias** desde a data de referência do estado. |

Outras regras do pacote:

- Se `hasRated` (já avaliou na loja, conforme estado persistido), **não** volta a pedir.
- `requestIfEligible` verifica `config.enabled` no início; se false, retorna sem mostrar modal.

---

## Persistência

| Ficheiro | Papel |
|----------|--------|
| [`lib/core/app_rating/shared_preferences_rating_storage.dart`](../lib/core/app_rating/shared_preferences_rating_storage.dart) | Implementa `RatingStorage` com chave `clinician_app_rating_state_v1`. |

---

## UI do modal

| Ficheiro | Papel |
|----------|--------|
| [`lib/core/app_rating/clinician_app_rating_modal.dart`](../lib/core/app_rating/clinician_app_rating_modal.dart) | `showClinicianAppRatingModal` registado em `DefaultAppRatingModalProvider`. Textos via `yummy_log_l10n` (`appRatingModalTitle`, etc.). |

Comportamento atual:

- **Sem** botão “Cancelar”; ação principal **Enviar** (estrelas obrigatórias para enviar).
- Fechar **sem** enviar: toque **fora** do diálogo (barrier) ou botão voltar (Android) — resultado `null` → chama-se `onDismiss` e depois `onClose` conforme contrato do pacote.

---

## Analytics

Eventos emitidos por `AppRating` são encaminhados para `AnalyticsLogger` no mesmo bloco de `injection.dart` (`onEvent`), com `event.name` e `params`.

Origens úteis para filtrar em relatórios:

| `origin` | Origem |
|----------|--------|
| `settings_rate_app` | Pedido manual (Configurações). |
| `first_patient_linked` | Primeira vez que a lista passa de 0 para ≥1 paciente. |
| `insights_dashboard_loaded` | Primeiro carregamento bem-sucedido da aba Insights **com** dados (`totalPatients > 0`), por sessão de utilizador (flag local evita repetir em refresh). |
| `form_config_saved` | Gravação com sucesso do formulário de comportamento. |

---

## Pedido manual (Configurações)

- `RateAppCubit` + `AppRating.forceRequest` em [`modules/features/settings/...`](../modules/features/settings/lib/src/cubit/rate_app_cubit.dart).
- **Não** passa pelos triggers; mostra o modal se o contexto estiver válido.

---

## Pedidos automáticos (momentos de valor)

Helper partilhado (export do `patients_feature`):

- Ficheiro: [`modules/features/patients/lib/src/app_rating_prompt.dart`](../modules/features/patients/lib/src/app_rating_prompt.dart)
- Função: `trackActionAndRequestAppRatingIfEligible(BuildContext context, {required String origin})`
  1. `GetIt.I<AppRating>()` (se registado).
  2. `await appRating.trackAction()`.
  3. `await appRating.requestIfEligible(context: context, origin: origin)`.

Integrações:

| Momento | Ficheiro | Mecanismo |
|---------|----------|-----------|
| Primeiro paciente na lista | `patients_page.dart` | `BlocConsumer` — `listenWhen`: de lista vazia para com pacientes, estado `loaded`. |
| Insights com dados | `insights_page.dart` | `BlocConsumer` — primeiro `loaded` com `!isEmpty`; flag `_hasRequestedAppRatingForInsightsData` (reset ao mudar utilizador). |
| Formulário guardado | `patient_form_config_page.dart` | `BlocListener` — transição `saving` → `loaded` após sucesso (junto ao SnackBar). |

---

## Sessões (`trackSession`)

Chamado nos entrypoints `main_development.dart`, `main_staging.dart`, `main_production.dart` após `configureDependencies`, para alimentar `SessionTrigger`.

---

## Alterar regras ou desativar

1. **Triggers / IDs / `minRatingForStore`:** editar `AppRatingConfig` em [`injection.dart`](../lib/core/di/injection.dart).
2. **Desativar pedidos automáticos:** passar `enabled: false` em `AppRatingConfig` (substitui o default).
3. **Novos momentos:** chamar o helper com um novo `origin` (string estável para analytics) ou, só para testes locais, `forceRequest`.

---

## Referência rápida de ficheiros

| Caminho | Conteúdo |
|---------|-----------|
| `lib/core/di/injection.dart` | `AppRating`, config, storage, modal provider, analytics |
| `lib/core/app_rating/clinician_app_rating_modal.dart` | UI do modal |
| `lib/core/app_rating/shared_preferences_rating_storage.dart` | Persistência |
| `modules/features/patients/lib/src/app_rating_prompt.dart` | Helper `trackAction` + `requestIfEligible` |
| `modules/features/settings/.../rate_app_cubit.dart` | Pedido manual |

---

Ver também: [ANALYTICS.md](ANALYTICS.md) (stack mobile-foundation, utilizador, rotas).

---

*Última atualização alinhada ao código em `injection.dart` e integrações nos módulos patients / insights.*
