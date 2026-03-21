# Dicionário de eventos — YummyLog Clinicians

Eventos Firebase Analytics com prefixo **`cl_`** (app do clínico no mesmo projeto que o app paciente). Nomes ≤ 40 caracteres; parâmetros sem PII.

**Não duplicar** navegação já coberta por [`AnalyticsRouteObserver`](lib/core/router/app_router.dart) (screen views). **App Rating** continua a enviar eventos do pacote via [`injection.dart`](lib/core/di/injection.dart).

---

## Propriedade de utilizador

| Nome | Valor | Quando |
|------|--------|--------|
| `app_variant` | `clinicians` | Após `AnalyticsLogger.initialize`, no arranque do app |

Complementa `user_id` (Firebase Auth) definido em [`init_analytics_user_binding.dart`](lib/core/analytics/init_analytics_user_binding.dart).

---

## P0 — Receita e ativação

| Evento | Descrição | Parâmetros |
|--------|-----------|------------|
| `cl_paywall_view` | Utilizador vê paywall (sheet de limite ou ecrã de planos) | `source`: `invite_limit` \| `settings_subscription` \| `direct` \| `invite_limit_sheet` |
| `cl_purchase_submit` | Tap em subscrever (antes do SDK) | `plan_period`: `annual` \| `monthly` |
| `cl_purchase_outcome` | Resultado da compra | `result`: `success` \| `cancelled` \| `offerings_unavailable` \| `not_configured` \| `failed` |
| `cl_restore_outcome` | Restaurar compras | `result`: `success` \| `nothing_found` \| `not_configured` \| `failed` |
| `cl_invite_flow_open` | Abre o bottom sheet de convite | `patient_count_bucket`: `0` \| `1_2` \| `3plus` |
| `cl_invite_share` | Partilha ou cópia do código | `channel`: `whatsapp` \| `sms` \| `email` \| `copy` |
| `cl_patient_remove_confirm` | Remove paciente (confirmado) | — |

### Notas P0

- **`cl_paywall_view`**: o sheet de limite gratuito (`invite_limit_sheet`) dispara ao abrir o modal; a rota `/plans` dispara com `source` da query (`invite_limit`, `settings_subscription`, `direct`).
- **`direct`**: abertura de `/plans` sem query (links externos ou default).

---

## P1 — Insights, configurações, confiança

| Evento | Descrição | Parâmetros |
|--------|-----------|------------|
| `cl_insights_period_set` | Alteração do período do dashboard ou análises por paciente | `days`: `7` \| `30` \| `90` (ou outro inteiro na página de analytics) |
| `cl_insights_patient_drill` | Navegação para detalhe ou analytics a partir de Insights | `target`: `detail` \| `analytics` |
| `cl_auth_start` | Início do fluxo de login | `method`: `google` \| `apple` |
| `cl_auth_result` | Resultado do login | `method`, `success`: `true` \| `false` |
| `cl_logout` | Logout explícito com sucesso | — |
| `cl_notif_pref_update` | Alteração das preferências push | `push_enabled`: bool, `mode`: `all` \| `critical_only` |
| `cl_rate_app_open` | Tap em “Avaliar o app” | `source`: `settings` |
| `cl_account_delete_complete` | Conta eliminada com sucesso | — |

---

## P2 — Diário do paciente e formulário de comportamento

Complementa o **screen view** do diário / form: interação explícita (tap, gravação).

| Evento | Descrição | Parâmetros |
|--------|-----------|------------|
| `cl_diary_meal_open` | Tap num card de refeição (abre bottom sheet de detalhe) | `meal_type`: `breakfast` \| `lunch` \| `dinner` \| `supper` \| `morning_snack` \| `afternoon_snack` \| `evening_snack` |
| `cl_form_config_save` | Gravação **bem-sucedida** no Firestore (formulário de comportamento por paciente) | — |

**Nota:** `cl_form_config_save` dispara após `save` OK; o pedido de app rating continua em [`patient_form_config_page.dart`](../modules/features/patients/lib/src/pages/patient_form_config_page.dart) (`origin: form_config_saved`).

---

## Validação (DebugView / GA4)

1. Build com flavor **development**, dispositivo físico ou emulador com **DebugView** ativo no Firebase.
2. Confirmar que cada nome de evento aparece uma vez por ação esperada.
3. Confirmar que **não** há emails, nomes de pacientes ou IDs sensíveis em parâmetros (apenas `patient_count_bucket`, canais, etc.).
4. Confirmar comprimento dos nomes ≤ 40 caracteres (tabela acima já validada).

---

## Implementação

- Contrato: [`CliniciansAnalytics`](../modules/shared/feature_contract/lib/clinicians_analytics.dart)
- Implementação: [`clinicians_analytics_impl.dart`](../lib/core/analytics/clinicians_analytics_impl.dart)
- Registo: [`injection.dart`](../lib/core/di/injection.dart)
- **Camada:** `CliniciansAnalytics?` é injetado nos cubits (não nas páginas); a UI fala só com o cubit. Detalhes em [ANALYTICS.md](ANALYTICS.md) (secção «Onde chamar analytics»).

Ver também [ANALYTICS.md](ANALYTICS.md).
