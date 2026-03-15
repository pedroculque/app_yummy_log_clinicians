# Roadmap - YummyLog for Clinicians (App do Clínico)

Este documento descreve o roadmap de desenvolvimento do **app do clínico** YummyLog for Clinicians. O app do paciente é um projeto separado (`app_yummy_log`).

---

## Visão Geral

O YummyLog for Clinicians é um aplicativo para **profissionais de saúde** (nutricionistas, psicólogos, etc.) acompanharem os diários alimentares de seus pacientes. O clínico gera um código de convite, o paciente insere o código no app dele, e o vínculo é criado. O clínico pode então visualizar (read-only) as refeições registradas pelo paciente.

**Login:** NÃO é obrigatório para navegar pelo app. Login é solicitado apenas quando o usuário tenta convidar pacientes.

---

## Fases de Desenvolvimento

### Fase 1: MVP (Pacientes + Convite) 🎯

**Status:** Em desenvolvimento

**Objetivo:** App funcional com código de convite e lista de pacientes.

| Feature | Descrição | Status |
|---------|-----------|--------|
| Shell do app | Tab bar: **Pacientes** \| **Insights** \| **Configurações** (3 abas) | ✅ |
| Login opcional | Firebase Auth (Google + Apple no iOS); login solicitado ao convidar | ✅ |
| Código de convite | Gerar código de 6 caracteres, salvar em `clinician_codes/{code}` | ✅ |
| Compartilhar código | Bottom sheet com opções: SMS, WhatsApp, E-mail, Copiar | ✅ |
| Lista de pacientes | Cards com avatar, nome, idade, data de vínculo | ✅ |
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
- [ ] Testar fluxo completo

---

### Fase 2: Visualizar Diário do Paciente 📖

**Status:** Planejado

**Objetivo:** Clínico pode visualizar (read-only) o diário alimentar de um paciente vinculado.

| Feature | Descrição | Status |
|---------|-----------|--------|
| Navegação | Botão "ACOMPANHAR" → tela de diário do paciente | Pendente |
| Calendário | Visão mensal com dias que têm registros destacados | Pendente |
| Day strip | Faixa horizontal de dias + lista de refeições | Pendente |
| Cards de refeição | Tipo, horário, sentimento, foto (se houver) | Pendente |
| Detalhe da refeição | Tela full screen com todos os dados | Pendente |
| Header | Nome do paciente no topo | Pendente |

**Dependências:** Fase 1 concluída.

---

### Fase 3: Insights e Métricas 📊

**Status:** Planejado

**Objetivo:** Dashboard com métricas e visualizações dos dados dos pacientes.

| Feature | Descrição | Status |
|---------|-----------|--------|
| Dashboard | Visão geral: quantidade de pacientes, atividade recente | Pendente |
| Estatísticas por paciente | Frequência de registros, sentimentos mais comuns | Pendente |
| Gráficos | Visualizações ao longo do tempo | Pendente |
| Filtros | Por período, por paciente | Pendente |

**Dependências:** Fase 2 concluída.

---

## Estrutura do app (navegação)

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

## Estrutura Firestore (compartilhada com app paciente)

| Coleção | Descrição | Acesso do clínico |
|---------|-----------|-------------------|
| `clinician_codes/{code}` | Código de convite → `clinicianUid`, `displayName` | Escrita (próprio código) |
| `clinicians/{clinicianId}/patients/{patientId}` | Lista de pacientes vinculados | Leitura |
| `users/{patientId}/meals/{mealId}` | Refeições do paciente | Leitura (se vinculado) |
| `users/{patientId}/connections/{connectionId}` | Conexões do paciente | Leitura (se vinculado) |

Ver [BACKEND_CONECTAR.md](BACKEND_CONECTAR.md) para detalhes das regras de segurança.

---

## Prioridades

### Alta (próximos passos)

1. **Testar fluxo completo** – Login, gerar código, paciente vincular.
2. **Fase 2** – Visualizar diário do paciente.

### Média

3. **Fase 3** – Insights e métricas.

### Baixa

4. Notificações push (quando paciente registra refeição).
5. Chat com paciente.

---

## Referências

- [REQUIREMENTS.md](../REQUIREMENTS.md) – Requisitos por versão
- [STATE.md](../STATE.md) – Posição atual
- [FIREBASE_SETUP_CLINICIANS.md](FIREBASE_SETUP_CLINICIANS.md) – Config Firebase (app do clínico)
- [BACKEND_CONECTAR.md](BACKEND_CONECTAR.md) – Estrutura Firestore e regras
- App do paciente: `/Users/pedroculque/dev-mobile/app_yummy_log`
