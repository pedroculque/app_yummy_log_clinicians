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
- **Monetização:** Sistema de planos implementado:
  - Plano Gratuito: limite de 2 pacientes
  - Plano Pro: pacientes ilimitados (R$ 24,90/mês ou R$ 179,90/ano)
  - Seção "Assinatura" na tela de configurações
  - `PlansPage` com UI de upgrade
- **Insights:** Feature `insights_feature` implementada com:
  - Dashboard resumo (pacientes ativos, registros do período, alertas)
  - Seletor de período (7 dias, 30 dias, 90 dias)
  - Data/hora da última atualização
  - Alertas de comportamentos de risco (vômito forçado, laxantes, regurgitação, etc.)
  - Ranking de pacientes por necessidade de atenção (score baseado em comportamentos)
  - Navegação direta para o diário do paciente
  - **Análises por paciente (Fase 3.2):** Sentimentos, quantidade consumida, calendário de frequência
  - **Análises avançadas (Fase 3.3):** Tendências agregadas (atual vs anterior), refeições puladas por tipo, correlação sentimentos em refeições puladas
- **Configurações:** Adaptado do app paciente + seção de Assinatura.
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

- **Limite de pacientes:** Plano gratuito permite até 2 pacientes; Pro é ilimitado.
- **Preços Pro:** R$ 24,90/mês ou R$ 179,90/ano (economia de 40%).
- **Rotas full-screen:** `/patients/:patientId/diary`, `/patients/:patientId/form-config` e `/plans` ficam fora do `StatefulShellRoute` para não mostrar tab bar.
- **Filtragem client-side:** Refeições deletadas (`deletedAt != null`) são filtradas no cliente para evitar índice composto no Firestore.
- **Swipe-to-remove:** Confirmação via bottom sheet antes de remover paciente.
- **Login NÃO obrigatório:** Usuário pode navegar pelo app sem login. Login é solicitado apenas ao tentar convidar pacientes.
- **Mesmo projeto Firebase:** Compartilha Firestore e Auth com o app paciente para acesso às mesmas coleções.
- **Bundle ID:** `com.yummylogdiaryforclinicians.app` (produção), `.dev` e `.stg` para flavors.

---

## Bloqueios

Nenhum no momento.

---

## Próximos passos (prioridade)

1. **RevenueCat em produção:** Entitlement `clinicians_pro`, offering default, produtos nas lojas; `REVENUECAT_API_KEY` no `.env.prod` / `.env.dev` (Fastlane → `--dart-define`, ver [docs/MONETIZATION_REVENUECAT.md](docs/MONETIZATION_REVENUECAT.md)).
2. **Exportar relatórios:** PDF com resumo do paciente para consultas.
3. **Manutenção:** validar deep links de push e fluxo de convite após alterações de branding/l10n.

---

## Referências

- [docs/ROADMAP.md](docs/ROADMAP.md) – Fases e entregáveis
- [docs/BACKEND_CONECTAR.md](docs/BACKEND_CONECTAR.md) – Estrutura Firestore, fluxo de notificações push e vínculo paciente–clínico
- [docs/FIREBASE_SETUP_CLINICIANS.md](docs/FIREBASE_SETUP_CLINICIANS.md) – Configurar Firebase (registrar app do clínico)
- [REQUIREMENTS.md](REQUIREMENTS.md) – Requisitos v1/v2/v3
