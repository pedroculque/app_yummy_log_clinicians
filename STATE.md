# Estado do Projeto – YummyLog for Clinicians

Documento de estado atual: posição, decisões recentes, bloqueios e próximos passos. Ver [docs/ROADMAP.md](docs/ROADMAP.md) para fases e [REQUIREMENTS.md](REQUIREMENTS.md) para requisitos.

---

## Posição atual

- **Pacotes:** `meal_domain` concentra `MealEntry` (patients, insights, sync, diary). Módulo `conectar` removido (fluxo do clínico é convite em `patients_feature`).
- **Fase:** Fase 3 (Insights **3.1–3.4**) concluída: dashboard, análises por paciente (3.2), análises avançadas (3.3) e notificações push (3.4).
- **Tab bar:** 3 abas (Pacientes, Insights, Configurações) com `StatefulShellRoute.indexedStack`.
- **Auth:** Login **NÃO é obrigatório** para acessar o app. Login é solicitado apenas quando o usuário tenta convidar pacientes.
- **Pacientes:** Feature `patients_feature` implementada com:
  - Header com saudação personalizada (nome do clínico)
  - Lista de pacientes (cards com avatar/foto de perfil ou iniciais, nome destacado, data de vínculo)
  - Swipe-to-remove com confirmação via bottom sheet
  - Tap no card → abre diário do paciente
  - Botão "CONVIDAR PACIENTE" (bloqueado se limite atingido)
  - Limite de 2 pacientes no plano gratuito
- **Diário do Paciente:** `PatientDiaryPage` com:
  - Timeline de refeições (últimos 14 dias via day strip)
  - Modo calendário (visão mensal com indicadores)
  - Cards de refeição com foto, tipo, horário, sentimento
  - Conectores de tempo entre refeições (alerta se > 4h)
  - Tags de comportamentos de risco nos cards (vômito, laxantes, etc.)
  - Chips de detalhes (quantidade, onde comeu, acompanhado)
  - Bottom sheet com detalhes completos da refeição (tap no card)
  - Botão "Configurar formulário" no header
- **Configuração do formulário de comportamento:** `PatientFormConfigPage` com:
  - Botão "Configurar formulário" no card do paciente e no header do diário
  - Tela full-screen `/patients/:patientId/form-config` com categorias e toggles
  - Toggle global para habilitar/desabilitar seção de comportamento
  - Persistência em `users/{patientId}/form_config/behavior`
  - Histórico de alterações (quem alterou e quando)
- **Monetização:** Sistema de planos implementado (RevenueCat + paywall); **oferta comercial** detalhada e decisões em [docs/MONETIZATION_REVENUECAT.md](docs/MONETIZATION_REVENUECAT.md):
  - Grátis: até 2 pacientes; formulário de comportamento e push (com login); **Insights em teaser** + CTA (a implementar no código — hoje Insights é igual ao Pro até ao gate)
  - Pro: pacientes ilimitados; Insights **completo**; preços R$ 24,90/mês ou R$ 179,90/ano (rever trimestralmente com métricas)
  - Seção "Assinatura" e `PlansPage`
- **Insights:** Feature `insights_feature` implementada com:
  - Dashboard resumo (pacientes ativos, registros do período, alertas)
  - Seletor de período (7 dias, 30 dias, 90 dias)
  - Data/hora da última atualização
  - Alertas de comportamentos de risco (vômito forçado, laxantes, regurgitação, etc.)
  - Ranking de pacientes por necessidade de atenção (score baseado em comportamentos)
  - Navegação direta para o diário do paciente
  - **Análises por paciente (Fase 3.2):** Sentimentos, quantidade consumida, calendário de frequência
  - **Análises avançadas (Fase 3.3):** Tendências agregadas (atual vs anterior), refeições puladas por tipo, correlação sentimentos em refeições puladas
- **Configurações:** Adaptado do app paciente + seção de Assinatura + **exclusão de conta** (requisito Apple para apps com login): fluxo in-app com confirmação; remove dados do clínico no Firestore (`clinicians/*`, `clinician_codes`, `users/{uid}` se existir), tokens de push, avatar no Storage e usuário no Firebase Auth. **ID de Suporte** (Firebase UID) na secção Suporte quando logado — copiável; alinhado ao `SessionLogger` e tags Sentry `user` / `support_id` — ver [modules/features/settings/docs/support-id.md](modules/features/settings/docs/support-id.md).
- **Design system:** `ui_kit` em uso (AppColors, AppTextStyles, UiCard, etc.).
- **i18n:** pt-BR, en, es via package `yummy_log_l10n`; nome do app e textos de assinatura/Pro alinhados à identidade **Clinicians** (stores + strings nativas Android por locale).
- **Firebase:** App do clínico registrado no projeto **app-yummy-log-diary**.
- **Notificações push:** Implementado fluxo completo:
  - `ClinicianNotificationService` registra token FCM em `clinicians/{uid}/notification_tokens`
  - Cloud Function `notifyCliniciansOnNewMeal` dispara ao criar refeição em `users/{patientId}/meals`
  - Preferências em `clinicians/{uid}/preferences/notification`: `pushEnabled`, `pushMode`; UI na aba Configurações (Alertas, switches)
  - FCM: refeição **com** risco → título/corpo de alerta; **sem** risco → “Nova entrada no diário” (vale no modo todas e no só-risco)
  - Busca clínicos via `connections` (clinicianUid) e envia push conforme preferência
  - Ao tocar na notificação, app navega para `/patients/:patientId/diary`
  - Config iOS por ambiente (dev/stg/prod) em `ios/Runner/config/`; plists no `.gitignore`

---

## Decisões recentes

- **App Rating:** Regras de elegibilidade, triggers, UI do modal, origens (`origin`) e pontos de integração estão documentados em [docs/APP_RATING.md](docs/APP_RATING.md).
- **Analytics:** Integração com `package_analytics` / `package_firebase_analytics` (mobile-foundation), observer de rotas, vínculo `setUserId`/`reset` com auth — ver [docs/ANALYTICS.md](docs/ANALYTICS.md).
- **Observabilidade (Sentry + session logger):** `launchClinicianApp` chama `SentryFlutter.init` e, no `appRunner`, `initPersistence` → `registerSessionLogger` → `registerCrashReporterIfNeeded` (`SessionLoggerErrorReporter` → só `SessionLogger.error`) → auth/sync/DI → `bootstrap`. Em `bootstrap`, `FlutterError`, `PlatformDispatcher` e **`BlocObserver.onError`** enviam para `SessionLogger` quando registado. `SessionLoggerConfig.appVersion` inclui build number (`version+build`). Erros de sessão chegam ao Sentry via `session_sentry` (`SentrySessionClient`, fingerprint estável; `beforeSend` para compra cancelada). Utilizador no Sentry: `init_session_logger_user_binding` com `AuthUser.uid` (mesmo valor do ID de Suporte na UI). Ver [docs/OBSERVABILITY.md](docs/OBSERVABILITY.md) e [lib/core/observability/README.md](lib/core/observability/README.md).
- **Oferta Grátis vs Pro (2026-03-20):** Ver [docs/MONETIZATION_REVENUECAT.md](docs/MONETIZATION_REVENUECAT.md) — Insights: **teaser** no grátis e dashboard **completo** no Pro; **push** para todos com login; **formulário de comportamento** no grátis; preços mantidos com revisão trimestral.
- **Limite de pacientes:** Plano gratuito permite até 2 pacientes; Pro é ilimitado.
- **Preços Pro:** R$ 24,90/mês ou R$ 179,90/ano (economia de 40%).
- **Rotas full-screen:** `/patients/:patientId/diary`, `/patients/:patientId/form-config` e `/plans` ficam fora do `StatefulShellRoute` para não mostrar tab bar.
- **Filtragem client-side:** Refeições deletadas (`deletedAt != null`) são filtradas no cliente para evitar índice composto no Firestore.
- **Swipe-to-remove:** Confirmação via bottom sheet antes de remover paciente.
- **Login NÃO obrigatório:** Usuário pode navegar pelo app sem login. Login é solicitado apenas ao tentar convidar pacientes.
- **Mesmo projeto Firebase:** Compartilha Firestore e Auth com o app paciente para acesso às mesmas coleções.
- **Bundle ID:** `com.yummylogdiaryforclinicians.app` (produção), `.dev` e `.stg` para flavors.
- **Exclusão de conta — gap de dados:** documentos em `users/{patientId}/connections` que referenciam o `clinicianUid` excluído **não são apagados pelo app do clínico** (regras Firestore: só o paciente escreve nessa subcoleção). **Backlog:** Cloud Function disparada ao apagar o usuário no Auth (ex.: extensão *Delete User Data* ou trigger administrativo) para limpar/atualizar conexões afetadas e evitar vínculos órfãos no app do paciente. Ver [docs/BACKEND_CONECTAR.md](docs/BACKEND_CONECTAR.md) § “Exclusão de conta do clínico”.

---

## Bloqueios

Nenhum no momento.

---

## Próximos passos (prioridade)

1. **RevenueCat em produção:** Entitlement `clinicians_pro`, offering default, produtos nas lojas; `REVENUECAT_API_KEY` no `.env.prod` / `.env.dev` (Fastlane → `--dart-define`, ver [docs/MONETIZATION_REVENUECAT.md](docs/MONETIZATION_REVENUECAT.md)).
2. **Cloud Function — limpeza pós-exclusão do clínico:** ao remover o usuário do Firebase Auth, executar rotina admin que percorre `users/*/connections` (ou índice/alternativa) e remove ou marca conexões cujo `clinicianUid` seja o UID deletado (requisito de produto/integridade; revisão Apple já coberta pelo fluxo in-app atual). Detalhes em [docs/BACKEND_CONECTAR.md](docs/BACKEND_CONECTAR.md).
3. **Exportar relatórios:** PDF com resumo do paciente para consultas.
4. **Manutenção:** validar deep links de push e fluxo de convite após alterações de branding/l10n.

---

## Referências

- [docs/ROADMAP.md](docs/ROADMAP.md) – Fases e entregáveis
- [docs/OBSERVABILITY.md](docs/OBSERVABILITY.md) – Session logger, Sentry, ID de Suporte
- [modules/features/settings/docs/support-id.md](modules/features/settings/docs/support-id.md) – ID de Suporte (detalhe de produto/UI)
- [docs/BACKEND_CONECTAR.md](docs/BACKEND_CONECTAR.md) – Estrutura Firestore, fluxo de notificações push e vínculo paciente–clínico
- [docs/FIREBASE_SETUP_CLINICIANS.md](docs/FIREBASE_SETUP_CLINICIANS.md) – Configurar Firebase (registrar app do clínico)
- [REQUIREMENTS.md](REQUIREMENTS.md) – Requisitos v1/v2/v3
