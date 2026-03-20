# Monetização — RevenueCat (YummyLog for Clinicians)

Integração com [RevenueCat](https://www.revenuecat.com/) via pacote `purchases_flutter` e módulo `modules/foundation/subscription`.

## O que foi implementado

- Configuração do SDK no startup (`configureRevenueCat`), após Firebase Auth.
- Chaves públicas por loja via `--dart-define` (sem commit de secrets).
- `SubscriptionEntitlementCubit` (singleton no `get_it`): sincroniza `Purchases.logIn` / `logOut` com o UID do Firebase Auth; expõe `isPro`.
- Entitlement esperado: **`clinicians_pro`** (constante `kCliniciansProEntitlementId`).
- Tela de planos: compra mensal/anual a partir do *offering* atual (`PackageType.monthly` / `annual`).
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

- App **iOS** ligado ao **Bundle ID do build** que estás a correr (ex.: flavor **development** usa `.dev` — no RevenueCat tem de existir essa app ou os IAP têm de estar associados ao bundle correto).
- Sem avisos vermelhos em **Products** (identifier errado ou não encontrado na loja).

### Simulador

Muitas vezes o simulador **não** recebe IAP reais até propagação completa. Opções:

1. **StoreKit Configuration** no Xcode: ficheiro `.storekit` com os **mesmos Product IDs** → *Scheme → Run → Options → StoreKit Configuration* → correr o app.
2. **Dispositivo físico** + utilizador **Sandbox** (App Store Connect → Users and Access → Sandbox).

Documentação: [rev.cat/sdk-troubleshooting](https://rev.cat/sdk-troubleshooting).

## Segurança

O desbloqueio no cliente segue o `CustomerInfo` do RevenueCat. Para regras críticas no backend (ex.: Firestore), considere webhooks ou extensão RevenueCat → Firebase no futuro.
