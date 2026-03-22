# Estado do Projeto – YummyLog for Clinicians

Documento de estado atual: posição, decisões recentes, bloqueios e próximos passos. Ver [docs/ROADMAP.md](docs/ROADMAP.md) para fases e [REQUIREMENTS.md](REQUIREMENTS.md) para requisitos.

---

## Posição atual

- **Pacotes:** `meal_domain` concentra `MealEntry` (patients, insights, sync, diary). Módulo `conectar` removido (fluxo do clínico é convite em `patients_feature`).
- **Fase:** Fase 3 (Insights **3.1–3.4**) concluída: dashboard, análises por paciente (3.2), análises avançadas (3.3) e notificações push (3.4).
- **Tab bar:** 3 abas (Pacientes, Insights, Configurações) com `StatefulShellRoute.indexedStack`.
- **Auth:** Login **NÃO é obrigatório** para acessar o app. Login é solicitado apenas quando o usuário tenta convidar pacientes.
- **Pacientes:** Feature `patients_feature` implementada com:
  - Header com saudação personalizada (nome do clínico); foto do clínico alinhada à **Conta**: escuta em tempo real `users/{uid}`; se existir `photoUrl` no Firestore, prioriza essa URL (fonte de verdade após upload; o Auth pode ficar desatualizado). `CachedNetworkImage` usa `cacheKey` derivado de `updatedAt` do doc para invalidar cache quando o ficheiro no Storage é sobrescrito no mesmo path
  - Lista de pacientes (cards com avatar/foto de perfil ou iniciais, nome destacado, data de vínculo); fotos remotas com **cache em disco** (`CachedNetworkImage`) e placeholder a carregar (evita “círculo branco”)
  - Swipe-to-remove com confirmação via bottom sheet
  - Tap no card → abre diário do paciente
  - Botão "CONVIDAR PACIENTE" (bloqueado se limite atingido)
  - **Partilha do código:** WhatsApp (`wa.me`), SMS e e-mail (`mailto`) via `url_launcher`, com fallback `Share`; cópia para clipboard
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
  - **Persistência automática** (debounce) ao alterar toggles; indicador no app bar
  - **`bingeEating` (compulsão):** opt-in — padrão desligado para configs novas / chave ausente no mapa (alinhamento com app paciente recomendado)
  - Persistência em `users/{patientId}/form_config/behavior`
  - Histórico de alterações (quem alterou e quando)
- **Monetização:** Sistema de planos implementado (RevenueCat + paywall); **oferta comercial** em [docs/MONETIZATION_REVENUECAT.md](docs/MONETIZATION_REVENUECAT.md):
  - Grátis: até 2 pacientes; formulário de comportamento e push (com login); **Insights em teaser** (7 dias, KPIs; prévia limitada: até 3 alertas, 2 em “Precisam de atenção”, 1 análise por paciente; sem operacional/prioridade clínica expandida; CTA para `/plans`)
  - Pro: pacientes ilimitados; Insights **completo** (7/30/90 dias, todas as secções e rotas de análise); preços R$ 24,90/mês ou R$ 179,90/ano (rever trimestralmente)
  - Paywall: bullets focam escala + insights Pro + push (diário e formulário **não** são vendidos como exclusivos Pro)
  - Seção "Assinatura" e `PlansPage`; ecrã Pro ativo menciona dashboard de insights completo
- **Insights:** Feature `insights_feature` com `SubscriptionEntitlementCubit`; **Pro** vê:
  - Dashboard resumo, seletor 7/30/90 dias, operacional, prioridade clínica, alertas, ranking, análises por paciente e avançadas
  - **Grátis:** mesmos dados agregados só para **7 dias** no repositório; UI: resumo + teaser + prévias truncadas + cartão do que resta no Pro (ver `MONETIZATION_REVENUECAT.md`)
- **Configurações:** Adaptado do app paciente + seção de Assinatura + **exclusão de conta** (requisito Apple para apps com login): fluxo in-app com confirmação; remove dados do clínico no Firestore (`clinicians/*`, `clinician_codes`, `users/{uid}` se existir), tokens de push, avatar no Storage e usuário no Firebase Auth. **ID de Suporte** (Firebase UID) na secção Suporte quando logado — copiável; alinhado ao `SessionLogger` e tags Sentry `user` / `support_id` — ver [modules/features/settings/docs/support-id.md](modules/features/settings/docs/support-id.md).
- **Design system:** `ui_kit` em uso (AppColors, AppTextStyles, UiCard, etc.).
- **i18n:** pt-BR, en, es via package `yummy_log_l10n`; nome do app e textos de assinatura/Pro alinhados à identidade **Clinicians** (stores + strings nativas Android por locale).
- **Firebase:** App do clínico registrado no projeto **app-yummy-log-diary**.
- **Notificações push:** Fluxo completo:
  - `ClinicianNotificationService` regista token FCM em `clinicians/{uid}/notification_tokens` (simulador iOS **não** obtém APNS → sem token)
  - **`app_badge_plus`:** repõe o badge do ícone a **0** ao abrir a app / resume / ao tratar notificação aberta
  - Cloud Functions (ver [docs/BACKEND_CONECTAR.md](docs/BACKEND_CONECTAR.md)):
    - `notifyCliniciansOnNewMeal` — nova refeição
    - `onClinicianPatientLinked` — paciente vinculado (push ao clínico)
    - `onClinicianPatientRemoved` — remove `users/{patientId}/connections` com mesmo `clinicianUid` (Admin) e push ao clínico quando some `clinicians/.../patients/...`
  - Preferências: `pushEnabled`, `pushMode` (`all` / `critical_only`)
  - FCM refeição: **com** risco → alerta; **sem** risco → “Nova entrada no diário” (em `critical_only`, só a crítica dispara)
  - Toque na notificação → conforme `eventType`: `patient_unlinked` → `/patients`; caso contrário → `/patients/:patientId/diary` (`getInitialMessage` + `onMessageOpenedApp`)
  - Config iOS por ambiente em `ios/Runner/config/`; plists no `.gitignore`

---

## Decisões recentes

- **Auth / avatares:** `FirebaseAuthRepository.authStateChanges` usa **`userChanges`** do Firebase Auth. **`AuthCubit`** (Configurações) funde sempre com `users/{uid}` via `UserProfileReader.readSnapshot` e **`watchSnapshot`** (outro dispositivo altera a foto → UI atualiza). `UserAvatar` aceita `networkImageCacheKey` (upload bust ou `updatedAt` do Firestore) para não mostrar imagem antiga em cache quando o path no Storage é reutilizado. Cabeçalho de **Pacientes** segue o mesmo doc com listener + token de cache.
- **App Rating:** Regras de elegibilidade, triggers, UI do modal, origens (`origin`) e pontos de integração estão documentados em [docs/APP_RATING.md](docs/APP_RATING.md).
- **Analytics:** Integração com `package_analytics` / `package_firebase_analytics` (mobile-foundation), observer de rotas, vínculo `setUserId`/`reset` com auth — ver [docs/ANALYTICS.md](docs/ANALYTICS.md).
- **Observabilidade (Sentry + session logger):** `launchClinicianApp` chama `SentryFlutter.init` e, no `appRunner`, `initPersistence` → `registerSessionLogger` → `registerCrashReporterIfNeeded` (`SessionLoggerErrorReporter` → só `SessionLogger.error`) → auth/sync/DI → `bootstrap`. Em `bootstrap`, `FlutterError`, `PlatformDispatcher` e **`BlocObserver.onError`** enviam para `SessionLogger` quando registado. `SessionLoggerConfig.appVersion` inclui build number (`version+build`). Erros de sessão chegam ao Sentry via `session_sentry` (`SentrySessionClient`, fingerprint estável; `beforeSend` para compra cancelada). Utilizador no Sentry: `init_session_logger_user_binding` com `AuthUser.uid` (mesmo valor do ID de Suporte na UI). Ver [docs/OBSERVABILITY.md](docs/OBSERVABILITY.md) e [lib/core/observability/README.md](lib/core/observability/README.md).
- **Oferta Grátis vs Pro (2026-03):** [docs/MONETIZATION_REVENUECAT.md](docs/MONETIZATION_REVENUECAT.md) — gate de Insights no cliente; paywall alinhado (sem vender diário/form como Pro).
- **Limite de pacientes:** Plano gratuito permite até 2 pacientes; Pro é ilimitado.
- **Preços Pro:** R$ 24,90/mês ou R$ 179,90/ano (economia de 40%).
- **Rotas full-screen:** `/patients/:patientId/diary`, `/patients/:patientId/form-config` e `/plans` ficam fora do `StatefulShellRoute` para não mostrar tab bar.
- **Filtragem client-side:** Refeições deletadas (`deletedAt != null`) são filtradas no cliente para evitar índice composto no Firestore.
- **Swipe-to-remove:** Confirmação via bottom sheet antes de remover paciente.
- **Login NÃO obrigatório:** Usuário pode navegar pelo app sem login. Login é solicitado apenas ao tentar convidar pacientes.
- **Mesmo projeto Firebase:** Compartilha Firestore e Auth com o app paciente para acesso às mesmas coleções.
- **Bundle ID:** `com.yummylogdiaryforclinicians.app` (produção), `.dev` e `.stg` para flavors.
- **Remoção paciente (lista do clínico):** ao apagar `clinicians/{clinicianUid}/patients/{patientId}`, a CF **`onClinicianPatientRemoved`** limpa `users/{patientId}/connections` onde `clinicianUid` coincide (SDK Admin).
- **Exclusão de conta do clínico (Auth delete) — gap C38:** conexões em `users/{patientId}/connections` **não** são limpas só pelo fluxo in-app de apagar conta (ordem client vs dados em `clinicians/.../patients`). **Backlog:** CF em `auth.user().onDelete()` ou extensão *Delete User Data* com `collectionGroup('connections')` filtrado por `clinicianUid`. Ver [docs/BACKEND_CONECTAR.md](docs/BACKEND_CONECTAR.md).

---

## Bloqueios

Nenhum no momento.

---

## Próximos passos (prioridade)

1. **RevenueCat em produção:** Entitlement `clinicians_pro`, offering default, produtos nas lojas; `REVENUECAT_API_KEY` no `.env.prod` / `.env.dev` (Fastlane → `--dart-define`, ver [docs/MONETIZATION_REVENUECAT.md](docs/MONETIZATION_REVENUECAT.md)).
2. **Cloud Function — limpeza pós-exclusão Auth (C38):** quando o utilizador clínico é apagado no Firebase Auth, limpar conexões órfãs (ver acima); distinto da remoção de paciente na lista, já coberta por `onClinicianPatientRemoved`.
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
