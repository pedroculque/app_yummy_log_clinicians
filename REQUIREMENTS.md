# Requisitos – YummyLog for Clinicians (App do Clínico)

Escopo por versão e requisitos de produto/UX. Rastreabilidade por identificador (C1, C2, …).  
Referência: [docs/ROADMAP.md](docs/ROADMAP.md), [PROJECT.md](PROJECT.md).

---

## Visão por versão

| Versão | Escopo | Status |
|--------|--------|--------|
| **v1** | MVP: tab bar, código de convite, lista de pacientes, empty state visual | ✅ Concluído |
| **v2** | Visualizar diário do paciente (read-only) | ✅ Concluído |
| **v2.1** | Monetização: planos Free/Pro, limite de pacientes | ✅ Concluído |
| **v2.2** | Configuração do formulário de comportamento por paciente | ✅ Concluído |
| **v3** | Insights e métricas dos pacientes | ✅ Em andamento |

---

## Requisitos funcionais (v1 – MVP)

| ID | Descrição | Status |
|----|-----------|--------|
| C1 | **Tab bar com 3 abas:** Pacientes, Insights, Configurações. | ✅ |
| C2 | **Login opcional:** usuário pode navegar sem login; login solicitado ao convidar. | ✅ |
| C3 | **Alerta de login:** ao convidar sem login, mostra alerta e direciona para Configurações. | ✅ |
| C4 | **Código de convite:** clínico pode gerar código de 6 caracteres para pacientes se vincularem. | ✅ |
| C5 | **Compartilhar código:** opções de compartilhar via SMS, WhatsApp, E-mail ou copiar. | ✅ |
| C6 | **Lista de pacientes:** exibir pacientes vinculados com avatar/iniciais, nome, data de vínculo. | ✅ |
| C7 | **Empty state visual:** ícone, título, descrição e feature chips quando não há pacientes. | ✅ |
| C8 | **Navegação para diário:** tap no card ou botão "ACOMPANHAR" → diário do paciente. | ✅ |
| C9 | **Configurações:** idioma, aparência (tema), sobre, suporte, login/logout. | ✅ |
| C10 | **Insights placeholder:** tela "Em breve" na aba Insights. | ✅ |

---

## Requisitos funcionais (v2 – Diário do Paciente)

| ID | Descrição | Status |
|----|-----------|--------|
| C11 | **Visualizar diário:** tela read-only com timeline e calendário de refeições. | ✅ |
| C12 | **Day strip:** faixa horizontal com últimos 14 dias para navegação. | ✅ |
| C13 | **Modo calendário:** visão mensal com indicadores de dias com registros. | ✅ |
| C14 | **Cards de refeição:** tipo, horário, sentimento, foto (se houver). | ✅ |
| C15 | **Conectores de tempo:** mostra intervalo entre refeições (alerta se > 4h). | ✅ |
| C16 | **Header com nome:** nome do paciente + "Diário" no topo. | ✅ |
| C17 | **Remover paciente:** swipe para esquerda no card com confirmação. | ✅ |

---

## Requisitos funcionais (v2.1 – Monetização)

| ID | Descrição | Status |
|----|-----------|--------|
| C18 | **Limite de pacientes:** plano gratuito permite até 2 pacientes. | ✅ |
| C19 | **Bloqueio de convite:** ao atingir limite, mostra dialog de upgrade. | ✅ |
| C20 | **Seção Assinatura:** card em configurações com plano atual, contagem e progresso. | ✅ |
| C21 | **Tela de planos:** UI com benefícios Pro, seletor Anual/Mensal, preços. | ✅ |
| C22 | **Integração IAP:** RevenueCat ou nativo para compras. | Pendente |

---

## Requisitos funcionais (v2.2 – Configuração do formulário de comportamento)

| ID | Descrição | Status |
|----|-----------|--------|
| C22a | **Entrada na config:** botão "Configurar formulário" no card do paciente e no header do diário. | ✅ |
| C22b | **Tela de comportamentos:** lista de cards por categoria com toggle mostrar/ocultar. | ✅ |
| C22c | **Toggle global:** habilitar/desabilitar toda a seção de comportamento no form do paciente. | ✅ |
| C22d | **Persistência:** salvar config em `users/{patientId}/form_config/behavior` (clínico escreve; paciente lê). | ✅ |
| C22e | **Histórico de alterações:** exibir quem alterou e quando. | ✅ |

---

## Requisitos funcionais (v3 – Insights)

| ID | Descrição | Prioridade | Status |
|----|-----------|------------|--------|
| C23 | **Dashboard resumo:** cards com total de pacientes, registros do período, alertas ativos. | Alta | ✅ |
| C24 | **Alertas de risco:** lista de comportamentos de risco (vômito forçado, laxantes, regurgitação, esconder comida, comer em segredo). | Alta | ✅ |
| C25 | **Ranking de atenção:** lista de pacientes ordenada por necessidade de atenção (score baseado em comportamentos de risco, sentimentos negativos, baixa frequência). | Alta | ✅ |
| C26 | **Análise de sentimentos:** distribuição de sentimentos por paciente (últimos 7/30 dias). | Média | Pendente |
| C27 | **Frequência de registros:** calendário de calor e média de refeições/dia por paciente. | Média | Pendente |
| C28 | **Quantidade consumida:** distribuição de `amountEaten` por paciente para identificar restrição. | Média | Pendente |
| C29 | **Análise por refeição:** quais refeições são mais puladas, correlação com sentimentos. | Baixa | Pendente |
| C30 | **Filtros de período:** 7 dias, 30 dias, 90 dias. | Média | ✅ |

---

## Requisitos funcionais (v3.1 – Diário Detalhado)

| ID | Descrição | Prioridade | Status |
|----|-----------|------------|--------|
| C31 | **Tags de comportamentos:** cards de refeição mostram tags coloridas de comportamentos de risco. | Alta | ✅ |
| C32 | **Chips de detalhes:** cards mostram quantidade comida, onde comeu, se comeu acompanhado. | Alta | ✅ |
| C33 | **Detalhe da refeição:** tap no card abre bottom sheet com todos os detalhes (read-only). | Alta | ✅ |
| C34 | **Borda de alerta:** cards com comportamentos de risco têm borda vermelha/laranja. | Média | ✅ |

---

## Fora de escopo (atual)

- Edição de refeições do paciente (app é read-only para o clínico).
- Perfil completo do clínico (nome, CRN, bio, etc).
- Chat com paciente.
- Exportar relatórios (PDF).

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
