# Roadmap - YummyLog for Clinicians (App do Clínico)

Este documento descreve o roadmap de desenvolvimento do **app do clínico** YummyLog for Clinicians. O app do paciente é um projeto separado (`app_yummy_log`).

---

## Visão Geral

O YummyLog for Clinicians é um aplicativo para **profissionais de saúde** (nutricionistas, psicólogos, etc.) acompanharem os diários alimentares de seus pacientes. O clínico gera um código de convite, o paciente insere o código no app dele, e o vínculo é criado. O clínico pode então visualizar (read-only) as refeições registradas pelo paciente.

**Login:** NÃO é obrigatório para navegar pelo app. Login é solicitado apenas quando o usuário tenta convidar pacientes.

---

## Fases de Desenvolvimento

### Fase 1: MVP (Pacientes + Convite) ✅

**Status:** Concluído

**Objetivo:** App funcional com código de convite e lista de pacientes.

| Feature | Descrição | Status |
|---------|-----------|--------|
| Shell do app | Tab bar: **Pacientes** \| **Insights** \| **Configurações** (3 abas) | ✅ |
| Login opcional | Firebase Auth (Google + Apple no iOS); login solicitado ao convidar | ✅ |
| Código de convite | Gerar código de 6 caracteres, salvar em `clinician_codes/{code}` | ✅ |
| Compartilhar código | Bottom sheet com opções: SMS, WhatsApp, E-mail, Copiar | ✅ |
| Lista de pacientes | Cards com avatar/iniciais, nome, data de vínculo | ✅ |
| Estado vazio | Empty state visual com ícone, descrição e feature chips | ✅ |
| Alerta de login | Ao convidar sem login, mostra alerta e direciona para Configurações | ✅ |
| Configurações | Idioma, aparência, sobre, suporte, login/logout | ✅ |
| Insights (placeholder) | Tela "Em breve" | ✅ |

**Entregáveis:**
- [x] Tab bar (3 abas: Pacientes, Insights, Configurações)
- [x] Feature `patients_feature` com código de convite
- [x] Feature `insights_feature` (placeholder)
- [x] Configurações adaptadas do app paciente
- [x] Empty state visual na aba Pacientes
- [x] Alerta de login ao convidar sem estar logado
- [x] Configurar Firebase (novo app) → ver [FIREBASE_SETUP_CLINICIANS.md](FIREBASE_SETUP_CLINICIANS.md)
- [x] Testar fluxo completo

---

### Fase 2: Visualizar Diário do Paciente 📖 ✅

**Status:** Concluído

**Objetivo:** Clínico pode visualizar (read-only) o diário alimentar de um paciente vinculado.

| Feature | Descrição | Status |
|---------|-----------|--------|
| Navegação | Tap no card ou botão "ACOMPANHAR" → tela de diário do paciente | ✅ |
| Timeline | Lista de refeições do dia com fotos, horários e sentimentos | ✅ |
| Day strip | Faixa horizontal com últimos 14 dias | ✅ |
| Calendário | Visão mensal com indicadores de dias com registros | ✅ |
| Cards de refeição | Tipo, horário, sentimento, foto (se houver) | ✅ |
| Conectores de tempo | Mostra intervalo entre refeições (alerta se > 4h) | ✅ |
| Header | Nome do paciente + "Diário" no topo | ✅ |
| Remover paciente | Swipe para esquerda no card para desvincular | ✅ |

**Entregáveis:**
- [x] `PatientDiaryPage` com timeline e calendário
- [x] `PatientMealsRepository` para buscar refeições do paciente
- [x] `PatientDiaryCubit` para gerenciar estado
- [x] Rota full-screen `/patients/:patientId/diary`
- [x] Swipe-to-remove com confirmação
- [x] UI melhorada para cards de pacientes

---

### Fase 2.1: Monetização 💰 ✅

**Status:** Concluído

**Objetivo:** Sistema de planos para limitar pacientes no plano gratuito.

| Feature | Descrição | Status |
|---------|-----------|--------|
| Limite de pacientes | Plano gratuito: máximo 2 pacientes | ✅ |
| Bloqueio de convite | Ao atingir limite, mostra dialog de upgrade | ✅ |
| Seção Assinatura | Card na tela de configurações com progresso | ✅ |
| Tela de planos | UI com benefícios Pro, seletor Anual/Mensal | ✅ |
| Preços | R$ 19,90/mês ou R$ 149,90/ano (economia de 37%) | ✅ |

**Entregáveis:**
- [x] `PlansPage` com UI de upgrade
- [x] `_SubscriptionSection` na `SettingsPage`
- [x] Lógica de limite em `_showInviteSheet`
- [x] Rota full-screen `/plans`

**Pendente:**
- [ ] Integração com in-app purchases (RevenueCat ou nativo)

---

### Fase 2.2: Configuração do formulário de comportamento 📋

**Status:** Planejado

**Objetivo:** O clínico pode configurar, por paciente, quais perguntas de **comportamento** aparecem no formulário "Adicionar comida" do paciente. A seção de comportamento no app do paciente só é exibida (e apenas os itens habilitados) quando o clínico configurou o formulário para esse paciente.

| Feature | Descrição | Status |
|---------|-----------|--------|
| Entrada na config | Botão "Configurar formulário" no card do paciente ou no header do diário | Pendente |
| Tela de comportamentos | Lista de cards por categoria (Métodos compensatórios, Restrição, etc.) com toggle mostrar/ocultar | Pendente |
| Toggle global | Habilitar/desabilitar toda a seção de comportamento no form do paciente | Pendente |
| Persistência | Salvar config em `users/{patientId}/form_config` (clínico escreve; paciente lê) | Pendente |
| Regras Firestore | Clínico pode escrever em `form_config` apenas para pacientes vinculados | Pendente |

**MVP (Fase 2.2.1):** Apenas os 5 comportamentos atuais do `MealEntry` (hiddenFood, regurgitated, forcedVomit, ateInSecret, usedLaxatives) com toggle cada um.

**Fase 2.2.2 (futuro):** Catálogo completo (vômito, laxante, diurético, exercício compensatório, mastigar e cuspir, jejum, pular refeição, compulsão, comer escondido, culpa, contagem de calorias, checagem/pesagem corporal, etc.) e extensão do modelo no app do paciente.

**Entregáveis:**
- [ ] Rota full-screen `/patients/:patientId/form-config` (ou equivalente)
- [ ] Tela "Comportamentos para o formulário" com categorias e toggles
- [ ] Repositório/serviço para ler e gravar `users/{patientId}/form_config`
- [ ] Documento de especificação: [BEHAVIOR_FORM_CONFIG.md](BEHAVIOR_FORM_CONFIG.md)
- [ ] App do paciente: ler config e exibir seção/comportamentos conforme config (escopo em outro repo)

---

### Fase 3: Insights e Métricas 📊

**Status:** Fase 3.1 concluída ✅

**Objetivo:** Dashboard com métricas e visualizações dos dados dos pacientes para apoio à decisão clínica.

#### Fase 3.1 - MVP Insights (Alta prioridade) ✅

| Feature | Descrição | Status |
|---------|-----------|--------|
| Dashboard resumo | Cards: pacientes ativos, registros do período, alertas ativos | ✅ |
| Seletor de período | 7 dias, 30 dias, 90 dias | ✅ |
| Última atualização | Data/hora da última carga de dados | ✅ |
| Alertas de risco | Lista de comportamentos de risco detectados (vômito, laxantes, etc.) | ✅ |
| Ranking de atenção | Pacientes ordenados por necessidade de atenção | ✅ |
| Tags no diário | Cards de refeição com tags de comportamentos de risco | ✅ |
| Detalhes da refeição | Bottom sheet com todos os dados (read-only) | ✅ |

#### Fase 3.2 - Análises por Paciente (Média prioridade)

| Feature | Descrição | Status |
|---------|-----------|--------|
| Análise de sentimentos | Gráfico de distribuição de sentimentos | Pendente |
| Frequência de registros | Calendário de calor, média refeições/dia | Pendente |
| Quantidade consumida | Distribuição de `amountEaten` | Pendente |

#### Fase 3.3 - Análises Avançadas (Baixa prioridade)

| Feature | Descrição | Status |
|---------|-----------|--------|
| Análise por refeição | Refeições puladas, correlação com sentimentos | Pendente |
| Tendências agregadas | Comparativo temporal (semana atual vs anterior) | Pendente |

**Dependências:** Fase 2 concluída.

**Dados utilizados:**
- `Patient`: id, name, photoUrl, linkedAt
- `MealEntry`: mealType, dateTime, feelingLabel, amountEaten, hiddenFood, regurgitated, forcedVomit, ateInSecret, usedLaxatives, whereAte, ateWithOthers, description, feelingText

---

## Estrutura do app (navegação)

```
┌──────────────────────────────────────────────────────────────────────────┐
│                         Tab Bar (3 abas)                                 │
├──────────────────────┬──────────────────────┬────────────────────────────┤
│  Tab: Pacientes      │  Tab: Insights       │  Tab: Configurações        │
│  • Header saudação   │  • Dashboard         │  • Assinatura (Free/Pro)   │
│  • Lista pacientes   │  • Estatísticas      │  • Login/Logout            │
│  • Swipe → remover   │  • Gráficos          │  • Idioma, Aparência       │
│  • Tap → diário      │                      │  • Sobre, Suporte          │
│  • Convidar paciente │                      │                            │
├──────────────────────┴──────────────────────┴────────────────────────────┤
│  Full screen (acima da tab bar):                                         │
│  • Diário do paciente (/patients/:id/diary) — Timeline + Calendário      │
│  • Configurar formulário (/patients/:id/form-config) — Comportamentos     │
│  • Tela de planos (/plans) — Upgrade para Pro                            │
└──────────────────────────────────────────────────────────────────────────┘
```

---

## Estrutura Firestore (compartilhada com app paciente)

| Coleção | Descrição | Acesso do clínico |
|---------|-----------|-------------------|
| `clinician_codes/{code}` | Código de convite → `clinicianUid`, `displayName` | Escrita (próprio código) |
| `clinicians/{clinicianId}/patients/{patientId}` | Lista de pacientes vinculados | Leitura |
| `users/{patientId}/meals/{mealId}` | Refeições do paciente | Leitura (se vinculado) |
| `users/{patientId}/connections/{connectionId}` | Conexões do paciente | Leitura (se vinculado) |
| `users/{patientId}/form_config` | Config do formulário de comportamento (clínico grava; paciente lê) | Escrita (clínico vinculado); leitura (paciente) |

Ver [BACKEND_CONECTAR.md](BACKEND_CONECTAR.md) e [BEHAVIOR_FORM_CONFIG.md](BEHAVIOR_FORM_CONFIG.md) para detalhes.

---

## Prioridades

### Alta (próximos passos)

1. **Configuração do formulário de comportamento** – Clínico configura, por paciente, quais comportamentos aparecem no form "Adicionar comida". Ver [BEHAVIOR_FORM_CONFIG.md](BEHAVIOR_FORM_CONFIG.md).
2. **Integração In-App Purchases** – RevenueCat ou nativo para planos Pro.
3. **Fase 3** – Insights e métricas (3.2, 3.3).

### Média

4. Notificações push (quando paciente registra nova entrada).

---

## Referências

- [REQUIREMENTS.md](../REQUIREMENTS.md) – Requisitos por versão
- [STATE.md](../STATE.md) – Posição atual
- [BEHAVIOR_FORM_CONFIG.md](BEHAVIOR_FORM_CONFIG.md) – Configuração do formulário de comportamento (clínico)
- [FIREBASE_SETUP_CLINICIANS.md](FIREBASE_SETUP_CLINICIANS.md) – Config Firebase (app do clínico)
- [BACKEND_CONECTAR.md](BACKEND_CONECTAR.md) – Estrutura Firestore e regras
- App do paciente: `/Users/pedroculque/dev-mobile/app_yummy_log`
