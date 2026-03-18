# /status - Project Status

Mostra o status atual do projeto **Yummy Log** (app do paciente).

## Instruções

1. Leia `docs/ROADMAP.md` (fase atual, entregáveis, próximos passos).
2. Execute `git log --oneline -10`.
3. Execute `git status`.
4. Liste o status dos **packages** e do app (conforme estrutura em `docs/ARCHITECTURE.md`).

## Output Esperado

```
📊 Yummy Log - Status do Projeto

## Fase Atual
[Ler de docs/ROADMAP.md – ex.: Fase 1 MVP (Diário local)]

## Packages e features

| Módulo / package | Descrição | Status |
|------------------|-----------|--------|
| modules/shared/feature_contract | Contrato YummyLogFeature | ✅ |
| modules/features/diary | Feature Diário + Adicionar refeição | ✅ shell / 🟡 conteúdo |
| modules/features/conectar | Feature Conectar com nutricionista | ✅ shell / 🔴 fluxo |
| modules/features/settings | Feature Configurações (Login, etc.) | ✅ shell / 🔴 login |
| lib/ (app) | Router (go_router), DI (get_it), shell (3 abas) | ✅ |

Status: ✅ implementado | 🟡 em progresso | 🔴 planejado

## Tab bar
Diário | Conectar | Configurações (StatefulShellRoute + 3 branches)

## Últimos Commits
[git log --oneline -5]

## Arquivos Modificados
[git status --short]

## Próximos Passos
[Sugestão baseada em docs/ROADMAP.md – ex.: persistência local, fluxo Adicionar refeição, design system]
```

## Referências

- `docs/ROADMAP.md` – Fases (MVP, Auth, Conectar, Sync).
- `docs/ARCHITECTURE.md` – Estrutura (modules/shared/, features/, go_router, get_it).
- `docs/PROJETO_YUMMY_LOG.md` – Escopo, tab bar, features.

## Responda em Português (pt-BR)
