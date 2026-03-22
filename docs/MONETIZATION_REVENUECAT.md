# Monetização — RevenueCat (YummyLog for Clinicians)

Integração com [RevenueCat](https://www.revenuecat.com/) via pacote `purchases_flutter` e módulo `modules/foundation/subscription`.

Este documento junta **configuração técnica** (SDK, chaves, lojas) e **oferta comercial** acordada com o produto — para a equipa e para alinhar texto da App Store / Play com o que o app faz (ou vai fazer).

---

## Oferta: Grátis vs Pro (YummyLog Clínicos)

### Nomes e preços (referência)

| | Detalhe |
|---|--------|
| **Entitlement (RevenueCat + código)** | `clinicians_pro` |
| **Preço na UI (l10n)** | R\$ 24,90/mês · R\$ 179,90/ano (trial 7 dias nos textos) |
| **Preço cobrado** | O definido nos produtos da **App Store Connect** / **Google Play** (deve coincidir com a comunicação pública) |

### Estado atual no **código** (março/2026)

Hoje só existe **gate** explícito de assinatura para **limite de pacientes**:

| Funcionalidade | Plano grátis | Pro (`isPro`) |
|----------------|--------------|---------------|
| **Número de pacientes vinculados** | Máx. **2** (`SubscriptionLimits.maxFreePatients`) | **Ilimitado** (sem verificação de teto no cliente) |
| **Aba Pacientes** (lista, convite, diário read-only, swipe remover) | Sim (até 2) | Sim |
| **Diário do paciente** (timeline, calendário, detalhes, tags de risco) | Sim (para os pacientes que tens) | Sim |
| **Configurar formulário de comportamento** por paciente | Sim | Sim |
| **Aba Insights** (dashboard, métricas, gráficos, ranking, 3.2 / 3.3) | **Teaser:** KPIs + **7 dias**; sem operacional/prioridade/alertas/ranking/análise por paciente; rotas Pro mostram upsell | **Completo** (7/30/90 dias, todas as secções) |
| **Notificações push** (novas entradas / alertas de risco) | **Sim** (se login + prefs; não há `isPro` no fluxo) | Sim |
| **Tela de planos + restaurar compras** | Sim | Sim |

Ou seja: **tecnicamente**, o Pro compra sobretudo **escalar além de 2 pacientes**; o resto do valor é **percepção + paywall**, até haver mais gates no código (**Insights** — ver oferta alvo abaixo).

---

## Decisões tomadas (oferta) — 2026-03-20

Decisões de produto acordadas (**gate de Insights** implementado no cliente; ver tabela “Estado atual no código”).

| Tema | Decisão |
|------|---------|
| **Insights** | **Pro:** dashboard completo (métricas, períodos longos, ranking de atenção, análises 3.2 / 3.3). **Grátis:** **teaser** — resumo limitado (ex.: janela curta tipo 7 dias, poucos KPIs), **sem** o painel completo; sempre com **CTA** para subscrever. Objetivo: prova de valor sem ecrã vazio nem dar tudo de borla. |
| **Push** | Mantém-se para **todos os utilizadores com login** (grátis e Pro), com as preferências atuais. Rever no futuro se custo ou política de produto justificarem restringir ao Pro. |
| **Formulário de comportamento** | Mantém-se no **plano grátis** (até 2 pacientes), como gancho de valor clínico; Pro continua a pagar sobretudo por **escala de pacientes** + **Insights completo**. |
| **Preço** | Manter **R\$ 24,90/mês** e **R\$ 179,90/ano** (alinhado à UI e às lojas) ao introduzir os gates de Insights. **Rever** trimestralmente com métricas: conversão free→Pro, churn, custo médio Firebase/Functions por clínico ativo. |

### Oferta alvo (após implementar gate de Insights)

| Funcionalidade | Grátis | Pro |
|----------------|--------|-----|
| Pacientes | Máx. 2 | Ilimitado |
| Pacientes, diário, convites | Sim | Sim |
| Formulário de comportamento por paciente | Sim | Sim |
| Insights | **Teaser** + CTA | **Completo** |
| Push (com login) | Sim | Sim |

**Implementação técnica:** `InsightsCubit` usa `SubscriptionEntitlementCubit` (janela 7 dias no grátis; períodos 30/90 só Pro); teaser + CTA + `InsightsProUpsellPage` em rotas Pro; l10n pt/en/es. **Opcional:** regras Firestore/backend para enforcement forte.

### Mapa rápido: paywall vs código

Os bullets da `PlansPage` mencionam dashboard completo — após o gate, isso fica **coerente** com Pro; no grátis, o teaser deve usar copy honesta (“resumo” / “experimente o dashboard completo no plano Clínicos”). Até lá, a tabela “Estado atual no código” descreve o comportamento real.

---

## O que foi implementado

- Configuração do SDK no startup (`configureRevenueCat`), após Firebase Auth.
- Chaves públicas por loja via `--dart-define` (sem commit de secrets).
- `SubscriptionEntitlementCubit` (singleton no `get_it`): sincroniza `Purchases.logIn` / `logOut` com o UID do Firebase Auth; expõe `isPro`.
- Entitlement esperado: **`clinicians_pro`** (constante `kCliniciansProEntitlementId`).
- Tela de planos: compra mensal/anual a partir do *offering* atual (`PackageType.monthly` / `annual`); bullets de benefícios: pacientes ilimitados, dashboard de insights completo, análises avançadas por paciente, push (diário e formulário não são vendidos como diferenciais no paywall).
- Limite gratuito: **2 pacientes** quando `isPro` é falso (`SubscriptionLimits.maxFreePatients`).
- Restaurar compras nas Configurações.

## Configuração no RevenueCat

1. Criar projeto e associar app **iOS** e **Android** (mesmos bundle IDs do app clínico).
2. Criar produtos de assinatura nas lojas (mensal / anual) e importá-los no RevenueCat.
3. Criar entitlement **`clinicians_pro`** e vincular os produtos a esse entitlement.
4. Criar offering (ex.: **default**) com pacotes **monthly** e **annual** apontando para esses produtos.

Os preços exibidos na UI (R\$ 24,90 / R\$ 179,90) são informativos; o valor cobrado é o da loja.

## Build local / CI

### Padrão do projeto (`.env` + Fastlane)

O [fastlane/GeneralFastfile](../fastlane/GeneralFastfile) lê `REVENUECAT_API_KEY` do ambiente (após `load_env`: `.env` + `.env.dev` ou `.env.prod`) e passa ao Flutter:

`--dart-define=REVENUECAT_API_KEY=...`

No **`.env.prod`** (ou **`.env.dev`** para testes), use a chave pública da loja correspondente ao build:

- **iOS:** `REVENUECAT_API_KEY=appl_...`
- **Android:** `REVENUECAT_API_KEY=goog_...` (ou estenda o Fastfile para duas variáveis se quiser um único comando com ambas)

Opcionalmente você pode passar chaves específicas sem o alias unificado:

```bash
flutter run \
  --dart-define=REVENUECAT_APPLE_API_KEY=appl_xxx \
  --dart-define=REVENUECAT_GOOGLE_API_KEY=goog_xxx
```

Se nenhuma chave for resolvida, o app roda sem IAP: `isPro` falso e limite gratuito de pacientes aplica.

### Simulador / Run no Cursor ou VS Code

O [`.vscode/launch.json`](../.vscode/launch.json) usa **`--dart-define-from-file`** com ficheiros **`.env`** (suportado pelo Flutter):

| Perfil | Ficheiro |
|--------|----------|
| Launch development / staging | `.env.dev` |
| Launch production | `.env.prod` |

Em **`.env.dev`** e **`.env.prod`**, inclua a chave pública (mesma linha que o Fastlane usa):

```bash
REVENUECAT_API_KEY=appl_...
```

Use **`appl_...`** (iOS) ou **`goog_...`** (Android) conforme o dashboard RevenueCat → API keys.

Se aparecer *“Compras não estão configuradas neste build”*, confirme que o ficheiro existe na **raiz** do projeto, que a linha acima está correta e que fez **Run completo** (não só hot reload).

**Cuidado:** `--dart-define-from-file` incorpora as chaves do ficheiro no **binário** em tempo de compilação. Evite meter no mesmo ficheiro segredos que **não** devam ir para o app (ex.: tokens só de CI). Para só IAP no IDE, pode usar um `.env.dev` mínimo com `REVENUECAT_API_KEY` + o que o Dart precisar.

**Linha de comando (alternativa):**

```bash
flutter run --flavor development --target lib/main_development.dart \
  --dart-define-from-file=.env.dev
```

## iOS / Android

- **Android:** o plugin inclui permissão de faturamento; publique um *bundle* com produtos criados no Play Console.
- **iOS:** habilite **In-App Purchase** no target e use *sandbox* para testes.

## Erro: produtos não encontrados no App Store Connect

Mensagem do tipo: *“None of the products registered in the RevenueCat dashboard could be fetched from App Store Connect (or the StoreKit Configuration file…)”*.

A **chave RevenueCat já funciona**; o problema é a Apple **não devolver** os product IDs que o dashboard espera.

### Checklist App Store Connect

- Grupo de **subscrições** com produtos criados; **Product IDs** **iguais** aos do RevenueCat (Products).
- Contrato **Paid Applications** e configuração fiscal/bancária concluídos (IAP bloqueiam sem isto).
- Produtos no estado em que a Apple os expõe à app (não só rascunho sem fluxo completo).

### Checklist RevenueCat

- App **iOS** ligado ao **Bundle ID do build** que estás a correr. O flavor **development** usa `com.yummylogdiaryforclinicians.app.dev`; **staging** usa `com.yummylogdiaryforclinicians.app.stg`. Se no projeto RC só existir a app com bundle de **produção** (`com.yummylogdiaryforclinicians.app`), o SDK pede produtos para o bundle **.dev** / **.stg** e o erro *None of the products… could be fetched* mantém-se mesmo com `.storekit` correto. **Solução:** em RevenueCat → *Project settings → Apps*, adiciona uma app iOS por bundle (dev / stg / prod) e associa os **mesmos** produtos App Store (`clinicians_monthly`, `clinicians_annual`) a cada uma; ou testa IAP com build **production** no simulador até a app `.dev` existir no RC.
- Sem avisos vermelhos em **Products** (identifier errado ou não encontrado na loja).

### Simulador

Muitas vezes o simulador **não** recebe IAP reais até propagação completa. Opções:

1. **StoreKit Configuration** no Xcode: o ficheiro está em [`ios/YummyLogClinicians.storekit`](../ios/YummyLogClinicians.storekit) (à frente do `Runner.xcodeproj`, para o Xcode resolver o caminho do scheme sem ambiguidade). Formato igual ao `GrowthLog.storekit` do GrowthLog. Os schemes **`development`**, **`staging`**, **`production`** e **`Runner`** referenciam `YummyLogClinicians.storekit` em *Run*. Depois de mudar o StoreKit ou o scheme: `flutter clean`, apagar o app do simulador e voltar a correr. Confirma em *Edit Scheme → Run → Options* que **StoreKit Configuration** não está em *None*.
   - **Obrigatório:** os `productID` neste ficheiro têm de ser **exatamente** os mesmos que estão no RevenueCat e na App Store Connect. O catálogo atual no dashboard está alinhado com **`clinicians_monthly`** e **`clinicians_annual`** (ficheiro `YummyLogClinicians.storekit`). Se alterares os IDs na loja ou no RC, atualiza o `.storekit`; caso contrário o RC continua a falhar com *configuration error*.
2. **Dispositivo físico** + utilizador **Sandbox** (App Store Connect → Users and Access → Sandbox).

Documentação: [rev.cat/sdk-troubleshooting](https://rev.cat/sdk-troubleshooting).

## Segurança

O desbloqueio no cliente segue o `CustomerInfo` do RevenueCat. Para regras críticas no backend (ex.: Firestore), considere webhooks ou extensão RevenueCat → Firebase no futuro.
