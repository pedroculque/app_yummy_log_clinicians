# YummyLog for Clinicians – App do Clínico

![coverage][coverage_badge]
[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![License: MIT][license_badge]][license_link]

App para **profissionais de saúde** acompanharem os diários alimentares de seus pacientes. O clínico gera um código de convite, o paciente insere no app dele, e o vínculo é criado. O clínico pode então visualizar (read-only) as refeições registradas.

> **Este repositório é o app do clínico.** O app do paciente está em `/Users/pedroculque/dev-mobile/app_yummy_log`.

---

## Funcionalidades

- **Lista de pacientes** — Cards com avatar, nome, idade, data de vínculo
- **Código de convite** — Gerar código de 6 caracteres para pacientes se vincularem
- **Compartilhar código** — SMS, WhatsApp, E-mail ou copiar
- **Visualizar diário** — Calendário, refeições e sentimentos do paciente (read-only)
- **Insights** — Métricas e estatísticas dos pacientes (em desenvolvimento)
- **Login opcional** — Firebase Auth (Google + Apple no iOS); necessário para convidar
- **Internacionalização** — pt-BR, en, es
- **Design system** — `ui_kit` (AppColors, AppTextStyles, UiCard, etc.)

---

## Stack

| Tecnologia | Uso |
|------------|-----|
| **Flutter** | ^3.41.0 (SDK Dart ^3.11.0) |
| **Bloc / Cubit** | Gerenciamento de estado |
| **go_router** | Navegação (StatefulShellRoute + tab bar) |
| **get_it** | Injeção de dependências |
| **Cloud Firestore** | Leitura de pacientes e refeições |
| **Firebase Auth** | Login Google/Apple (`auth_foundation`) |
| **ui_kit** | Design system (git: pedroculque/flutter_ui_kit) |
| **Very Good CLI** | Estrutura do projeto, análise, testes |

---

## Estrutura do Projeto

```
app_yummy_log_clinicians/
├── lib/                          # App principal (bootstrap, router, DI)
│   ├── app/                      # App widget, cubits globais
│   ├── core/
│   │   ├── auth/                 # Inicialização auth
│   │   ├── di/                   # get_it injection
│   │   └── router/               # go_router (app_router, app_shell)
│   └── l10n/                     # Localizações do app host
├── modules/
│   ├── features/
│   │   ├── patients/             # Lista de pacientes, código de convite
│   │   ├── insights/             # Métricas e dashboard (placeholder)
│   │   └── settings/             # Configurações (login, preferências)
│   └── foundation/
│       ├── auth/                 # AuthRepository (Firebase)
│       ├── persistence/          # Sembast (cache local)
│       └── sync/                 # Utilitários Firestore
├── packages/
│   ├── feature_contract/         # Interface base YummyLogFeature
│   └── yummy_log_l10n/           # Localizações (pt, en, es)
├── docs/                         # Documentação detalhada
│   ├── ARCHITECTURE.md
│   ├── BACKEND_CONECTAR.md
│   ├── ROADMAP.md
│   └── THEMING.md
├── PROJECT.md                    # Visão do produto
├── REQUIREMENTS.md               # Requisitos v1–v3 (C1–C16)
└── STATE.md                      # Estado atual, decisões, próximos passos
```

---

## Navegação

```
┌──────────────────────────────────────────────────────────────────────────┐
│                         Tab Bar (3 abas)                                 │
├──────────────────────┬──────────────────────┬────────────────────────────┤
│  Tab: Pacientes      │  Tab: Insights       │  Tab: Configurações        │
│  • Empty state       │  • Dashboard         │  • Login/Logout            │
│  • Código de convite │  • Estatísticas      │  • Idioma, Aparência       │
│  • Lista pacientes   │  • Gráficos          │  • Sobre, Suporte          │
│  • ACOMPANHAR →      │                      │                            │
├──────────────────────┴──────────────────────┴────────────────────────────┤
│  Full screen (acima da tab bar):                                         │
│  • Diário do paciente (/patients/:id/diary)                              │
│  • Detalhe da refeição (/patients/:id/diary/entry/:entryId)              │
└──────────────────────────────────────────────────────────────────────────┘
```

---

## Getting Started

### Pré-requisitos

- Flutter ^3.41.0
- [Very Good CLI](https://github.com/VeryGoodOpenSource/very_good_cli)

### Instalação

```sh
# Instalar dependências de todos os módulos
./pub_get_all.sh
```

### Executar

O projeto usa 3 flavors: **development**, **staging** e **production**.

```sh
# Development
flutter run --flavor development --target lib/main_development.dart

# Staging
flutter run --flavor staging --target lib/main_staging.dart

# Production
flutter run --flavor production --target lib/main_production.dart
```

_Funciona em iOS e Android._

---

## Testes

```sh
very_good test --coverage --test-randomize-ordering-seed random
```

```sh
# Gerar relatório de cobertura
genhtml coverage/lcov.info -o coverage/
open coverage/index.html
```

### Bloc Lints

```sh
dart run bloc_tools:bloc lint .
```

---

## Internacionalização

Idiomas suportados: **pt-BR**, **en**, **es**.

As strings ficam no package `yummy_log_l10n` em `packages/yummy_log_l10n/lib/l10n/arb/`.

```sh
# Gerar localizações
flutter gen-l10n --arb-dir="packages/yummy_log_l10n/lib/l10n/arb"
```

---

## Documentação

| Documento | Descrição |
|-----------|-----------|
| [PROJECT.md](PROJECT.md) | Visão do produto, stack, estrutura |
| [STATE.md](STATE.md) | Posição atual, decisões recentes, próximos passos |
| [REQUIREMENTS.md](REQUIREMENTS.md) | Requisitos v1–v3 (C1–C16) |
| [docs/ROADMAP.md](docs/ROADMAP.md) | Fases de desenvolvimento e prioridades |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | go_router, get_it, módulos |
| [docs/BACKEND_CONECTAR.md](docs/BACKEND_CONECTAR.md) | Estrutura Firestore compartilhada |
| [docs/THEMING.md](docs/THEMING.md) | Tema e design system |

---

## Status do Projeto

| Fase | Descrição | Status |
|------|-----------|--------|
| **v1 – MVP** | Tab bar, código de convite, lista de pacientes, empty state | 🔄 Em desenvolvimento |
| **v2 – Diário** | Visualizar diário do paciente (read-only) | ⬜ Planejado |
| **v3 – Insights** | Dashboard com métricas e estatísticas | ⬜ Planejado |

---

## Especificações

| Item | Valor |
|------|-------|
| **Nome do app** | YummyLog for Clinicians |
| **Bundle ID** | `com.yummylogdiaryforclinicians.app` |
| **Firebase** | Mesmo projeto do app paciente |

---

[coverage_badge]: coverage_badge.svg
[flutter_localizations_link]: https://api.flutter.dev/flutter/flutter_localizations/flutter_localizations-library.html
[internationalization_link]: https://flutter.dev/docs/development/accessibility-and-localization/internationalization
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
[very_good_cli_link]: https://github.com/VeryGoodOpenSource/very_good_cli
