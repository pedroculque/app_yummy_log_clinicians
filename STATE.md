# Estado do Projeto – YummyLog for Clinicians

Documento de estado atual: posição, decisões recentes, bloqueios e próximos passos. Ver [docs/ROADMAP.md](docs/ROADMAP.md) para fases e [REQUIREMENTS.md](REQUIREMENTS.md) para requisitos.

---

## Posição atual

- **Fase:** 1 (MVP) em desenvolvimento.
- **Tab bar:** 3 abas (Pacientes, Insights, Configurações) com `StatefulShellRoute.indexedStack`.
- **Auth:** Login **NÃO é obrigatório** para acessar o app. Login é solicitado apenas quando o usuário tenta convidar pacientes (mostra alerta e direciona para Configurações).
- **Pacientes:** Feature `patients_feature` implementada com:
  - Empty state visual (ícone, título, descrição, feature chips)
  - Bottom sheet de convite com código de 6 caracteres
  - Compartilhamento via SMS, WhatsApp, E-mail
  - Copiar código com feedback "Copiado com sucesso!"
  - Lista de pacientes (cards com avatar, nome, idade, data, condição)
  - Botão "ACOMPANHAR" (navegação para diário pendente)
  - Alerta de login necessário ao tentar convidar sem estar logado
- **Insights:** Feature `insights_feature` criada como placeholder ("Em breve").
- **Configurações:** Adaptado do app paciente, removida seção "Conectar com nutricionista".
- **Design system:** `ui_kit` em uso (AppColors, AppTextStyles, UiCard, UiAutoWidthButton, etc.).
- **i18n:** pt-BR, en, es via package `yummy_log_l10n`.
- **Firebase:** App do clínico registrado no projeto **app-yummy-log-diary**; `google-services.json` e `GoogleService-Info.plist` configurados para `com.yummylogdiaryforclinicians.app`.

---

## Decisões recentes

- **Login NÃO obrigatório:** Usuário pode navegar pelo app sem login. Login é solicitado apenas ao tentar convidar pacientes.
- **Fluxo de login:** Ao clicar em "CONVIDAR PACIENTE" sem estar logado, mostra alerta explicativo e direciona para aba de Configurações.
- **Mesmo projeto Firebase:** Compartilha Firestore e Auth com o app paciente para acesso às mesmas coleções.
- **Bundle ID:** `com.yummylogdiaryforclinicians.app` (produção), `.dev` e `.stg` para flavors.
- **Código de convite:** Usa a mesma estrutura `clinician_codes/{code}` do backend existente.
- **Sem sync local:** App do clínico não precisa de sync offline-first (dados vêm direto do Firestore).
- **Empty state visual:** Tela de pacientes vazia mostra ícone, título, descrição e feature chips para explicar o valor do app.

---

## Bloqueios

Nenhum no momento.

---

## Próximos passos (prioridade)

1. **Testar fluxo completo:** Login → gerar código → paciente vincular → ver na lista.
2. **Implementar navegação para diário:** Botão "ACOMPANHAR" → tela de diário do paciente (Fase 2).
3. **Adaptar diary_feature:** Criar versão read-only para visualizar diário do paciente.
4. **Implementar Insights:** Dashboard com métricas dos pacientes (Fase 3).

---

## Referências

- [docs/ROADMAP.md](docs/ROADMAP.md) – Fases e entregáveis
- [docs/FIREBASE_SETUP_CLINICIANS.md](docs/FIREBASE_SETUP_CLINICIANS.md) – Configurar Firebase (registrar app do clínico)
- [REQUIREMENTS.md](REQUIREMENTS.md) – Requisitos v1/v2/v3
- App do paciente: docs/BACKEND_CONECTAR.md – Estrutura Firestore compartilhada
