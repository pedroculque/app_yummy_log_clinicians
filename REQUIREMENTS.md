# Requisitos – YummyLog for Clinicians (App do Clínico)

Escopo por versão e requisitos de produto/UX. Rastreabilidade por identificador (C1, C2, …).  
Referência: [docs/ROADMAP.md](docs/ROADMAP.md), [PROJECT.md](PROJECT.md).

---

## Visão por versão

| Versão | Escopo | Status |
|--------|--------|--------|
| **v1** | MVP: tab bar, código de convite, lista de pacientes, empty state visual | Em desenvolvimento |
| **v2** | Visualizar diário do paciente (read-only) | Planejado |
| **v3** | Insights e métricas dos pacientes | Planejado |

---

## Requisitos funcionais (v1 – MVP)

| ID | Descrição | Status |
|----|-----------|--------|
| C1 | **Tab bar com 3 abas:** Pacientes, Insights, Configurações. | ✅ |
| C2 | **Login opcional:** usuário pode navegar sem login; login solicitado ao convidar. | ✅ |
| C3 | **Alerta de login:** ao convidar sem login, mostra alerta e direciona para Configurações. | ✅ |
| C4 | **Código de convite:** clínico pode gerar código de 6 caracteres para pacientes se vincularem. | ✅ |
| C5 | **Compartilhar código:** opções de compartilhar via SMS, WhatsApp, E-mail ou copiar. | ✅ |
| C6 | **Lista de pacientes:** exibir pacientes vinculados com nome, foto, idade, data de vínculo. | ✅ |
| C7 | **Empty state visual:** ícone, título, descrição e feature chips quando não há pacientes. | ✅ |
| C8 | **Botão ACOMPANHAR:** ao tocar, navegar para o diário do paciente (v2). | Pendente |
| C9 | **Configurações:** idioma, aparência (tema), sobre, suporte, login/logout. | ✅ |
| C10 | **Insights placeholder:** tela "Em breve" na aba Insights. | ✅ |

---

## Requisitos funcionais (v2 – Diário do Paciente)

| ID | Descrição | Prioridade |
|----|-----------|------------|
| C11 | **Visualizar diário:** tela read-only com calendário e cards de refeição do paciente. | Alta |
| C12 | **Detalhe da refeição:** ver detalhes de uma refeição específica (foto, sentimento, etc). | Alta |
| C13 | **Header com nome:** exibir nome do paciente no topo da tela de diário. | Média |

---

## Requisitos funcionais (v3 – Insights)

| ID | Descrição | Prioridade |
|----|-----------|------------|
| C14 | **Dashboard:** visão geral dos pacientes (quantidade, atividade recente). | Média |
| C15 | **Estatísticas:** frequência de registros, distribuição de sentimentos. | Média |
| C16 | **Gráficos:** visualizações de dados ao longo do tempo. | Baixa |

---

## Fora de escopo (v1)

- Edição de refeições do paciente (app é read-only para o clínico).
- Perfil completo do clínico (nome, CRN, bio, etc).
- Notificações push.
- Chat com paciente.

---

## Especificações técnicas

| Item | Valor |
|------|-------|
| **Nome do app** | YummyLog for Clinicians |
| **Bundle ID (iOS/Android)** | `com.yummylogdiaryforclinicians.app` |
| **Firebase** | Mesmo projeto do app paciente (compartilha Firestore/Auth) |
| **Login** | Google (Android + iOS), Apple (iOS only) |
| **Idiomas** | pt-BR, en, es |

---

## Referências

- [docs/ROADMAP.md](docs/ROADMAP.md) – Fases e entregáveis
- [STATE.md](STATE.md) – Posição atual e próximos passos
- [PROJECT.md](PROJECT.md) – Visão do produto
- App do paciente: `/Users/pedroculque/dev-mobile/app_yummy_log`
