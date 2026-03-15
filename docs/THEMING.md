# Tema e aparência – Yummy Log (App Paciente)

Este documento descreve como o tema está configurado no **Yummy Log** e como alinhá-lo ao design do Figma.

---

## Visão geral

- **Estado atual:** O tema é definido em **`lib/app/view/app.dart`**: `MaterialApp` com `ThemeData` (Material 3, `appBarTheme`). Não há ainda arquivo dedicado de design system nem modo escuro.
- **Design de referência:** O Figma (Projeto YummyLog – Copy) define cores (Primary, Secondary, Success, Alert, Error, Neutral, Gray; Primary Light `#7D86E1`), tipografia (Headlines, estilos de texto) e componentes. Ver [PROJETO_YUMMY_LOG.md](PROJETO_YUMMY_LOG.md#21-design-system-referência-para-o-app).
- **Dependência:** O projeto usa o pacote **`ui_kit`** (git); quando o tema do app for evoluído, cores e tipografia devem seguir o Figma e, se o `ui_kit` expuser tokens ou tema (ex.: `ColorScheme`, temas claro/escuro), utilizá-los aqui como base.

---

## Onde está o quê

| Item | Local | Descrição |
|------|--------|-----------|
| Tema do app | `lib/app/view/app.dart` | `MaterialApp.theme` com `ThemeData(useMaterial3: true, appBarTheme: ...)`. Único ponto de definição hoje. |
| Design system (Figma) | [PROJETO_YUMMY_LOG.md](PROJETO_YUMMY_LOG.md) | Cores, tipografia, componentes a replicar no app. |
| Pacote de UI | `ui_kit` (pubspec.yaml) | Dependência git; usar para manter consistência visual quando houver tokens/tema disponíveis. |

**Evolução sugerida:** Ao implementar o design system do Figma, criar um módulo ou arquivo dedicado (ex.: `lib/theme/app_theme.dart` ou `lib/app/theme.dart`) que defina `ThemeData` claro (e depois escuro) a partir das cores e tipografia do Figma, e injetar em `app.dart`. Se o `ui_kit` oferecer helpers (ex.: `UiKitTheme`, `DesignSystemConfig`), utilizá-los nesse ponto.

---

## Boas práticas

1. **Cores e tipografia:** Usar sempre `Theme.of(context).colorScheme` e `Theme.of(context).textTheme` (ou extensões/helpers do `ui_kit`, se disponíveis) para respeitar o tema ativo e facilitar suporte a modo escuro no futuro.
2. **Material 3:** O app já usa `useMaterial3: true`; preferir componentes e tokens do Material 3 quando aplicável.
3. **Consistência com o Figma:** Ao adicionar novas telas ou componentes, seguir as cores (Primary, Secondary, Success, etc.) e estilos de texto definidos no Figma; documentar qualquer token customizado no próprio `app_theme` ou no design system.
4. **Modo escuro:** Ainda não implementado. Quando for priorizado (ex.: em Configurações), definir `MaterialApp.darkTheme` e um mecanismo de preferência (ex.: `ThemeModeCubit` + persistência); ver [ROADMAP.md](ROADMAP.md) para fases futuras.

---

## Referências

- [PROJETO_YUMMY_LOG.md](PROJETO_YUMMY_LOG.md) – Design system (seção 2.1), escopo do app
- [ROADMAP.md](ROADMAP.md) – Fase 1 (Design system no MVP)
- Pacote `ui_kit` – documentação no repositório do pacote para tokens e tema, se disponível
