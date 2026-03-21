# YummyLog for Clinicians

App para profissionais de saúde acompanharem os diários alimentares de seus pacientes.

---

## Visão do Produto

O **YummyLog for Clinicians** permite que nutricionistas, psicólogos e outros profissionais de saúde:

1. **Convidem pacientes** através de um código de 6 caracteres
2. **Visualizem o diário alimentar** dos pacientes vinculados (read-only)
3. **Configurem o formulário de comportamento** por paciente (quais perguntas aparecem no form "Adicionar comida")
4. **Acompanhem sentimentos** associados às refeições
5. **Identifiquem comportamentos de risco** (vômito forçado, laxantes, etc.)
6. **Analisem métricas** de frequência e padrões alimentares via dashboard de Insights

### Modelo de Negócio

| Plano | Limite | Preço |
|-------|--------|-------|
| **Gratuito** | 2 pacientes | R$ 0 |
| **Pro Mensal** | Ilimitado | R$ 24,90/mês |
| **Pro Anual** | Ilimitado | R$ 179,90/ano (economia ~40%) |

O app funciona em conjunto com o **YummyLog** (app do paciente), compartilhando o mesmo backend Firebase.

---

## Stack Técnica

| Camada | Tecnologia |
|--------|------------|
| **Framework** | Flutter 3.41+ |
| **Estado** | BLoC / Cubit |
| **Navegação** | go_router (StatefulShellRoute) |
| **DI** | get_it |
| **Backend** | Firebase (Auth, Firestore) |
| **Observabilidade** | `package_session_logger`, Sentry (`session_sentry`), Firebase Analytics |
| **UI** | ui_kit (design system compartilhado) |
| **i18n** | yummy_log_l10n (pt, en, es) |

---

## Estrutura do Projeto

```
app_yummy_log_clinicians/
├── lib/
│   ├── app/                    # App widget, cubits globais
│   ├── core/
│   │   ├── auth/               # Inicialização do Firebase Auth
│   │   ├── di/                 # Injeção de dependências (get_it)
│   │   ├── observability/      # launch + Sentry, session logger, CrashReporter
│   │   └── router/             # go_router, tab bar shell
│   └── main_*.dart             # Entry points por flavor
├── modules/
│   ├── features/
│   │   ├── patients/           # Lista de pacientes, diário, código de convite
│   │   ├── insights/           # Dashboard, alertas, análises por paciente e avançadas
│   │   └── settings/           # Configurações, planos, login/logout
│   └── foundation/
│       ├── auth/               # AuthRepository, LoginPage
│       ├── persistence/        # Sembast (cache local)
│       └── sync/               # Firestore connection
├── modules/shared/
│   ├── feature_contract/       # Interface YummyLogFeature, CrashReporter
│   ├── meal_domain/            # MealEntry
│   ├── session_sentry/         # SessionClient → Sentry (reutilizável)
│   └── yummy_log_l10n/         # Localizações
└── docs/                       # Documentação
```

---

## Especificações

| Item | Valor |
|------|-------|
| **Nome do app** | YummyLog for Clinicians |
| **Bundle ID** | `com.yummylogdiaryforclinicians.app` |
| **Flavors** | development (`.dev`), staging (`.stg`), production |
| **Login** | Google (Android + iOS), Apple (iOS only) |
| **Firebase** | Mesmo projeto do app paciente |

---

## Fluxo Principal

1. **Usuário abre o app** → vai direto para a tab bar (aba Pacientes)
2. **Aba Pacientes (sem login)** → mostra empty state visual
3. **Clica em "CONVIDAR PACIENTE"** → alerta pede login, direciona para Configurações
4. **Faz login nas Configurações** → volta para Pacientes
5. **Clica em "CONVIDAR PACIENTE"** → bottom sheet com código (se limite não atingido)
6. **Limite atingido (2 pacientes)** → dialog de upgrade para Pro
7. **Compartilha código** → paciente insere no app dele
8. **Paciente aparece na lista** → tap no card ou "ACOMPANHAR"
9. **Visualiza diário** → timeline ou calendário, refeições, sentimentos (read-only)
10. **Configurar formulário** → botão no card ou no header do diário → tela com toggles por comportamento
11. **Remover paciente** → swipe para esquerda no card, confirma no bottom sheet

---

## Documentação

| Documento | Descrição |
|-----------|-----------|
| [REQUIREMENTS.md](REQUIREMENTS.md) | Requisitos por versão (C1–C36 + backlog C37) |
| [STATE.md](STATE.md) | Posição atual, decisões, próximos passos |
| [docs/ROADMAP.md](docs/ROADMAP.md) | Fases de desenvolvimento |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | Arquitetura técnica |
| [docs/OBSERVABILITY.md](docs/OBSERVABILITY.md) | Session logger, Sentry, CrashReporter, ID de Suporte ↔ UID |
| [modules/features/settings/docs/support-id.md](modules/features/settings/docs/support-id.md) | ID de Suporte (Firebase UID), UI, i18n, Sentry |
| [docs/APP_RATING.md](docs/APP_RATING.md) | Regras de avaliação na loja (triggers, modal, origens) |
| [docs/ANALYTICS.md](docs/ANALYTICS.md) | Analytics mobile-foundation (Firebase, rotas, utilizador) |
| [docs/BACKEND_CONECTAR.md](docs/BACKEND_CONECTAR.md) | Estrutura Firestore |

---

## Links

- **App do paciente:** `/Users/pedroculque/dev-mobile/app_yummy_log`
- **UI Kit:** `https://github.com/pedroculque/flutter_ui_kit`
- **Firebase Console:** (configurar)
