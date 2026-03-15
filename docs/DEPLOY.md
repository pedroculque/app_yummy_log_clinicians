# Deploy & Code Signing

Documentação completa sobre deploy iOS e gerenciamento de certificados.

## Índice

- [Estrutura](#estrutura)
- [Pré-requisitos](#pré-requisitos)
- [Deploy Rápido](#deploy-rápido)
- [Firebase CLI (regras e projeto)](#firebase-cli-regras-e-projeto)
- [Certificados e Profiles](#certificados-e-profiles)
- [Conformidade de exportação (criptografia)](#conformidade-de-exportação-criptografia)
- [Troubleshooting](#troubleshooting)
- [Variáveis de Ambiente](#variáveis-de-ambiente)
- [Referências](#referências)

---

## Estrutura

```
app_yummy_log/
├── deploy.sh                    # Script principal de deploy (iOS + Android)
├── fastlane/
│   ├── GeneralFastfile          # Lanes compartilhadas (build, upload, supply, etc)
│   ├── CommonFastfile           # Funções comuns
│   └── NotificationFastfile     # Notificações (Slack, etc)
├── ios/fastlane/
│   ├── Fastfile                 # Lanes iOS (dev, prod)
│   ├── Appfile                  # Configuração do app
│   ├── Matchfile                # Configuração do match (certificados)
│   └── README.md
└── android/fastlane/
    └── Fastfile                 # Lanes Android (dev, prod → Google Play)
```

### Arquivos Principais

| Arquivo | Descrição |
|---------|-----------|
| `deploy.sh` | Script interativo para deploy (escolhe dev/prod; roda iOS e Android em sequência) |
| `ios/fastlane/Fastfile` | Define lanes `dev` e `prod` para iOS (TestFlight / App Store) |
| `android/fastlane/Fastfile` | Define lanes `dev` e `prod` para Android (Firebase App Distribution / Google Play) |
| `ios/fastlane/Matchfile` | Configuração do repositório de certificados |
| `ios/fastlane/Appfile` | Bundle ID, Team ID, Apple ID |
| `fastlane/GeneralFastfile` | Lanes compartilhadas: build, upload, supply, match |

---

## Pré-requisitos

### 1. Ferramentas

**Ruby 3.2+** é necessário para o deploy iOS (as dependências do fastlane exigem Ruby >= 3.2). O Ruby do sistema no macOS (2.6) não é compatível.

No macOS com Homebrew, adicione ao `~/.zshrc`:

```bash
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
```

Depois recarregue o terminal (`source ~/.zshrc`) e instale as gems:

```bash
cd ios && bundle install
```

### 2. Variáveis de Ambiente

Crie os arquivos `.env` na raiz do projeto:

```bash
# .env (comum)
KEYCHAIN_NAME=Temp.keychain
KEYCHAIN_PASSWORD=sua_senha_keychain

# .env.prod (produção)
TARGET=lib/main_production.dart
SPLIT_DEBUG_INFOPATH=build/app/outputs/symbols
APP_STORE_CONNECT_KEY_ID=xxx
APP_STORE_CONNECT_ISSUER_ID=xxx
APP_STORE_CONNECT_KEY_CONTENT=xxx

# .env.dev (desenvolvimento)
TARGET=lib/main_development.dart
FIREBASE_IOS_APP_ID=xxx
GOOGLE_APPLICATION_CREDENTIALS=path/to/service-account.json
```

### 3. SSH Config para GitHub

O repositório de certificados usa um alias SSH. Configure em `~/.ssh/config`:

```
Host github.com-pessoal
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_rsa_pessoal
  IdentitiesOnly yes
```

---

## Deploy Rápido

### Deploy Completo

```bash
# Na raiz do projeto
sh deploy.sh

# Escolha:
# [1] dev  - iOS: Firebase App Distribution | Android: Firebase App Distribution
# [2] prod - iOS: TestFlight / App Store | Android: Google Play (supply)
```

### O que o deploy faz (em ordem)

O script roda **primeiro iOS**, depois **Android**. Para cada plataforma:

1. `update_gem` - Atualiza gems do bundler
2. `clean_project` - `flutter clean` + `flutter pub get`
3. `load_env` - Carrega variáveis de ambiente
4. `increment_app_build_number` - **Incrementa automaticamente o build number no `pubspec.yaml`**
5. `connect_app_store` - Conecta à App Store Connect API
6. `rematch` - Baixa certificados e profiles
7. `flutter_build` - Build do Flutter (**prod**: com `--obfuscate` e `--split-debug-info`)
8. `build_ios_and_export_ipa` - Gera o IPA
9. **Só prod**: `upload_crashlytics_symbols` - Envia Dart symbols ao Firebase Crashlytics (stack traces legíveis)
10. **Só prod**: `upload_sentry_symbols` - Envia Dart symbols ao Sentry (sentry_dart_plugin)
11. Upload:
   - **iOS dev**: Firebase App Distribution
   - **iOS prod**: TestFlight
   - **Android dev**: Firebase App Distribution
   - **Android prod**: Google Play (via `supply`; track configurável por `SUPPLY_TRACK`)

### Ofuscação e symbols (produção)

No deploy **prod**, o build usa:

- `--obfuscate` – ofusca o código Dart (recomendado para produção).
- `--split-debug-info=<SPLIT_DEBUG_INFOPATH>` – gera os arquivos de symbols na pasta definida em `.env.prod`.

Os Dart symbols são enviados a:

- **Firebase Crashlytics**: via `firebase crashlytics:symbols:upload`. Requer Firebase CLI (`npm install -g firebase-tools`) e `FIREBASE_IOS_APP_ID` em `.env.prod`.
- **Sentry**: via `sentry_dart_plugin` (roda `dart run sentry_dart_plugin` após o build). Requer `SENTRY_ORG`, `SENTRY_PROJECT` e `SENTRY_AUTH_TOKEN` em `.env.prod`. O plugin usa o mesmo diretório de symbols e o `obfuscation.map.json` (gerado com `--save-obfuscation-map`) para títulos de issue legíveis.

A pasta de symbols e o `obfuscation.map.json` estão no `.gitignore`; para debug de uma versão antiga, guarde uma cópia por release.

### Build Number Automático

O build number é incrementado automaticamente a cada deploy no `pubspec.yaml`:

```yaml
# Antes do deploy
version: 1.0.0+30

# Depois do deploy
version: 1.0.0+31
```

O fastlane lê o arquivo, extrai o build number atual, incrementa e salva.

### Firebase CLI (regras e projeto)

Os recursos Firebase (Firestore, Storage) usam o **projeto** `app-yummy-log-diary`. Para não depender de um projeto padrão (`firebase use`), use sempre a flag `--project` nos comandos.

**Pré-requisito:** [Firebase CLI](https://firebase.google.com/docs/cli) instalado (`npm install -g firebase-tools`) e login (`firebase login`).

| Comando | Descrição |
|--------|-----------|
| `firebase deploy --project app-yummy-log-diary --only firestore:rules` | Publica apenas as regras do Firestore (`firestore.rules`). Use após alterar regras de segurança. |
| `firebase deploy --project app-yummy-log-diary --only storage` | Publica apenas as regras do Storage (`storage.rules`). |
| `firebase deploy --project app-yummy-log-diary` | Publica Firestore e Storage (regras). |

**Exemplo – só regras do Firestore:**

```bash
firebase deploy --project app-yummy-log-diary --only firestore:rules
```

**Definir projeto padrão (opcional):** `firebase use app-yummy-log-diary`. Depois pode usar `firebase deploy --only firestore:rules` sem `--project`.

### Android e Google Play (produção)

No deploy **prod**, o Android gera um **AAB** (`build/app/outputs/bundle/productionRelease/app-production-release.aab`) e o Fastlane envia para a Play Store com a ação `supply`.

- **Track**: controlado por `SUPPLY_TRACK` em `.env.prod`. Valores: `internal`, `alpha`, `beta`, `production`. O default no código é `internal`; para publicar direto em produção, defina `SUPPLY_TRACK=production`.
- **Credenciais**: é necessária uma [conta de serviço](https://developers.google.com/android-publisher/getting_started) da Play Console com permissão para publicar. Configure no `.env.prod`:
  - `SUPPLY_JSON_KEY_FILE=caminho/para/play-store-service-account.json` ou
  - `SUPPLY_JSON_KEY_DATA` com o conteúdo JSON da chave (útil em CI).
- **Keystore**: o AAB deve ser assinado. Use variáveis de ambiente no `.env.prod` ou o arquivo `android/key.properties` (veja [Criar o keystore de upload](#criar-o-keystore-de-upload-android)).
- **Primeiro upload:** a API do Google Play (e o `supply`) só funcionam para apps **já existentes** na Play Console. Se aparecer `Package not found: com.yummylogdiary.app`, crie o app em [Play Console](https://play.google.com/console) (se ainda não existir) e faça o **primeiro** envio do AAB manualmente (Produção ou Teste interno → Criar nova versão → enviar o AAB). Depois disso o Fastlane conseguirá enviar as próximas versões.

**API Google Play no projeto da conta de serviço:** o projeto do Google Cloud associado ao JSON da conta de serviço precisa ter a **Google Play Android Developer API** ativada. Se aparecer `PERMISSION_DENIED: Google Play Android Developer API has not been used in project XXXXX before or it is disabled`:

1. Abra o [Google Cloud Console](https://console.cloud.google.com/) e selecione o projeto cujo ID está no JSON da conta de serviço (campo `project_id`).
2. Vá em **APIs e serviços** → **Biblioteca** (ou use o link que a mensagem de erro fornece).
3. Pesquise por **Google Play Android Developer API** e clique em **Ativar**.
4. Aguarde alguns minutos e rode o deploy novamente.

Para rodar só o deploy Android: `cd android && fastlane prod`.

#### Criar o keystore de upload (Android)

O **upload keystore** é o arquivo (`.jks` ou `.keystore`) que a Play Store usa para identificar suas versões. Crie **uma vez** e guarde em local seguro (backup); se perder, não conseguirá atualizar o app com a mesma conta.

**1. Gerar o keystore (uma vez)**

Na raiz do projeto. Se o sistema não tiver Java no PATH, use o JDK do Android Studio:

```bash
# Com Java no PATH:
keytool -genkey -v -keystore android/upload-keystore.jks -storetype JKS \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload

# Se der "Unable to locate a Java Runtime", use o keytool do Android Studio (macOS):
"/Applications/Android Studio.app/Contents/jbr/Contents/Home/bin/keytool" -genkey -v \
  -keystore android/upload-keystore.jks -storetype JKS \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```

- O comando pede **senha do keystore** e **senha da chave** (podem ser iguais).
- Pedirá nome, unidade, organização etc.; pode preencher ou usar valores genéricos.
- O arquivo `android/upload-keystore.jks` fica no projeto; ele já está ignorado pelo git via `**/android/*.jks` ou você pode adicionar `upload-keystore.jks` ao `.gitignore`. **Faça backup em local seguro.**

**2. Configurar no projeto**

**Opção A – Arquivo `android/key.properties`** (recomendado para máquina local)

Crie `android/key.properties` (não commitar; já está no `.gitignore`):

```properties
storePassword=SUA_SENHA_KEYSTORE
keyPassword=SUA_SENHA_DA_CHAVE
keyAlias=upload
storeFile=upload-keystore.jks
```

Se o keystore estiver em outro diretório, use caminho absoluto em `storeFile` ou caminho relativo ao diretório `android/`.

**Opção B – Variáveis de ambiente** (útil para CI ou `.env.prod`)

No `.env.prod` ou no ambiente antes do build:

```bash
ANDROID_KEYSTORE_PATH=/caminho/absoluto/para/upload-keystore.jks
ANDROID_KEYSTORE_ALIAS=upload
ANDROID_KEYSTORE_PASSWORD=senha_do_keystore
ANDROID_KEYSTORE_PRIVATE_KEY_PASSWORD=senha_da_chave
```

**3. Conferir**

Com `key.properties` ou variáveis configuradas, rode:

```bash
cd android && flutter build appbundle --flavor production --target lib/main_production.dart
```

O AAB assinado estará em `build/app/outputs/bundle/productionRelease/`.

---

## Certificados e Profiles

### Repositório de Certificados

O projeto **reaproveita** o mesmo repositório de certificados para vários apps do mesmo time:

- **Repositório:** [yummy_log_app_certificates_and_profiles](https://github.com/pedroculque/yummy_log_app_certificates_and_profiles)
- **Clone via SSH:** `git@github.com-pessoal:pedroculque/yummy_log_app_certificates_and_profiles.git`

O Match guarda **certificados** (por tipo: development, distribution) e **provisioning profiles** (por bundle ID). Ao rodar `match` com os bundle IDs do app, ele **só adiciona** os novos perfis; **não apaga** os que já existem para outros apps. Pode usar o mesmo repo para vários projetos (ex.: app paciente e app clínicos).

**Importante:** não rode `fastlane match nuke` a menos que queira revogar **todos** os certificados do repositório (afeta outros apps que usam o mesmo repo). Para renovar só um certificado expirado, prefira as etapas da seção [Renovar Certificados Expirados](#renovar-certificados-expirados).

#### Estrutura atual do repo (análise)

O repositório [yummy_log_app_certificates_and_profiles](https://github.com/pedroculque/yummy_log_app_certificates_and_profiles) hoje contém:

| Pasta | Conteúdo |
|-------|----------|
| `certs/development/` | Um certificado de desenvolvimento (`.cer` + `.p12`) — **compartilhado** por todos os apps do time |
| `certs/distribution/` | Um certificado de distribuição — **compartilhado** por todos os apps |
| `profiles/development/` | Profiles do app paciente (ex.: `Development_com.yummylogdiary.app.dev.mobileprovision`) |
| `profiles/adhoc/` | Profiles do app paciente (ex.: `AdHoc_com.yummylogdiary.app.stg.mobileprovision`) |
| `profiles/appstore/` | Profiles do app paciente (ex.: `AppStore_com.yummylogdiary.app.mobileprovision`, etc.) |

**Uso pelo app clínicos sem impacto nos outros apps:**

- **Certificados:** O Match **reutiliza** o mesmo certificado de development e o mesmo de distribution. Não são criados certificados novos; os existentes continuam a ser usados por todos os projetos.
- **Provisioning profiles:** O Match **só adiciona** novos arquivos `.mobileprovision` para os bundle IDs do app clínicos (`com.yummylogdiaryforclinicians.app`, `.dev`, `.stg`). Os profiles já existentes (app paciente) **não são alterados nem removidos**.
- **Conclusão:** Usar este repo para o YummyLog for Clinicians é seguro: apenas novos profiles são criados e commitados; certificados e profiles dos outros apps permanecem intactos.

### App Identifiers (YummyLog for Clinicians)

| Bundle ID | Ambiente | Tipo Match |
|-----------|----------|------------|
| `com.yummylogdiaryforclinicians.app` | Produção | App Store |
| `com.yummylogdiaryforclinicians.app.dev` | Desenvolvimento | Development |
| `com.yummylogdiaryforclinicians.app.stg` | Staging | Ad Hoc |

### Primeira vez: criar certificados e profiles do app clínicos

Se o repositório de certificados ainda **não** tem perfis para os bundle IDs acima, faça uma vez:

**1. Registrar os App IDs no Apple Developer Portal**

1. Acesse [Apple Developer → Identifiers](https://developer.apple.com/account/resources/identifiers/list).
2. Crie três **App IDs** (tipo “App”), um para cada bundle ID:
   - `com.yummylogdiaryforclinicians.app`
   - `com.yummylogdiaryforclinicians.app.dev`
   - `com.yummylogdiaryforclinicians.app.stg`
3. Em cada um, ative as capabilities que o app usa (ex.: **Sign in with Apple**, **Push Notifications** se for usar).

**2. Variáveis de ambiente**

Na raiz do projeto, confira (ou crie) `.env` com:

- `MATCH_PASSWORD` – senha que criptografa os certificados no repositório Git (quem for rodar match precisa saber).
- `KEYCHAIN_NAME` e `KEYCHAIN_PASSWORD` – keychain local (ex.: `Temp.keychain`).
- Opcional: `MATCH_USERNAME` e `FASTLANE_TEAM_ID` (Apple ID e Team ID); senão, o Matchfile usa os valores padrão.

**3. Rodar Match pela primeira vez (criar e enviar ao repo)**

A partir da pasta **ios** do projeto (para usar o `Matchfile` do app clínicos).

**Opção A – um comando (recomendado):**

```bash
cd ios
bundle exec fastlane match_init
```

A lane `match_init` (em `fastlane/GeneralFastfile`) roda `match` para os três tipos (development, adhoc, appstore) e envia os certificados e profiles ao repositório.

**Opção B – por tipo:**

```bash
cd ios

# Gera certificado de desenvolvimento + 3 provisioning profiles (.app, .dev, .stg)
bundle exec fastlane match development

# Gera certificado de distribuição Ad Hoc + 3 profiles
bundle exec fastlane match adhoc

# Gera certificado de distribuição App Store + 3 profiles
bundle exec fastlane match appstore
```

Em cada comando o Match pode pedir a **senha do repositório** (se não estiver em `MATCH_PASSWORD`) e **2FA da Apple**. No primeiro run ele **cria** os certificados e os profiles e **envia** ao repositório `yummy_log_app_certificates_and_profiles`.

**4. Depois disso (uso normal)**

Para só **baixar** certificados já existentes (por exemplo antes de buildar):

```bash
cd ios
bundle exec fastlane certificates
```

Ou, por tipo:

```bash
bundle exec fastlane match development --readonly
bundle exec fastlane match adhoc --readonly
bundle exec fastlane match appstore --readonly
```

### Comandos Match

```bash
cd ios

# Baixar certificados existentes (readonly)
fastlane match appstore --readonly
fastlane match adhoc --readonly
fastlane match development --readonly

# Criar novos certificados (quando expiram)
fastlane match appstore --force
fastlane match adhoc --force
fastlane match development --force

# Baixar todos os certificados (lane do projeto)
fastlane certificates

# ⚠️ NUCLEAR: Remove TODOS os certificados do repo (afeta outros apps que usam o mesmo repo!)
# Só use se for realmente revogar tudo. Para renovar um cert expirado, veja a seção abaixo.
# fastlane match nuke distribution
# fastlane match nuke development
# fastlane match appstore --force
```

### Renovar Certificados Expirados

Quando o certificado expira, você verá:

```
Your certificate 'XXXXX.cer' is not valid, please check end date and renew it if necessary
```

**Solução:**

```bash
cd ios

# 1. Remove certificados antigos
fastlane match nuke distribution

# 2. Confirma com 'y' quando perguntar

# 3. Cria novos certificados
fastlane match appstore --force

# 4. Volta e faz deploy
cd ..
sh deploy.sh
```

### Senhas Necessárias

| Senha | Descrição | Onde configurar |
|-------|-----------|-----------------|
| Match passphrase | Criptografa certificados no Git | Prompt ou `MATCH_PASSWORD` |
| Keychain password | Senha do keychain local | `.env` ou prompt |
| Apple ID 2FA | Código de verificação Apple | Prompt (6 dígitos) |

---

## Conformidade de exportação (criptografia)

O app usa **apenas criptografia isenta**: TLS/HTTPS (SO e SDKs) para Firebase, OAuth e rede. Não há algoritmos próprios nem bibliotecas de criptografia customizada.

- No questionário da Apple, marque: **"Nenhum dos algoritmos mencionados acima"**.
- O `Info.plist` já contém `ITSAppUsesNonExemptEncryption = false` para dispensar a configuração no App Store Connect.

Documentação detalhada: [ENCRYPTION.md](ENCRYPTION.md).

---

## Troubleshooting

### Erro: Certificate not valid

```bash
[!] Your certificate 'XXXXX.cer' is not valid
```

**Solução:** Renovar certificados (ver seção acima)

### Erro: Repository not found (SSH)

```bash
ERROR: Repository not found.
fatal: Could not read from remote repository.
```

**Solução:** Verificar SSH config e alias `github.com-pessoal`

```bash
# Testar conexão
ssh -T git@github.com-pessoal

# Se falhar, verificar ~/.ssh/config
```

### Erro: could not read Username for 'https://github.com' (CI)

```bash
fatal: could not read Username for 'https://github.com': No such device or address
# ao rodar flutter pub get no GitHub Actions
```

**Causa:** O projeto depende do repositório privado `flutter_ui_kit` via git. O CI não tem credenciais para clonar.

**Solução:** Usamos [webfactory/ssh-agent](https://github.com/marketplace/actions/webfactory-ssh-agent) com uma **Deploy Key** (chave SSH) no repo privado:

1. **Gerar chave SSH** (sem passphrase, para o CI):
   ```bash
   ssh-keygen -t ed25519 -a 100 -f deploy_key -N ""
   ```
2. **No repositório `flutter_ui_kit`:** Settings → Deploy keys → Add deploy key. Colar o conteúdo de `deploy_key.pub`. Dar apenas **Read**.
3. **No repositório app_yummy_log:** Settings → Secrets and variables → Actions → New repository secret. Nome: `SSH_PRIVATE_KEY`, Valor: conteúdo do ficheiro **privado** `deploy_key` (incluindo `-----BEGIN ... PRIVATE KEY-----` e `-----END ... PRIVATE KEY-----`).

O workflow `.github/workflows/main.yaml` carrega essa chave no `ssh-agent` e configura o Git para usar SSH ao clonar do GitHub, para que `flutter pub get` consiga aceder ao `flutter_ui_kit`.

**Resumo:** chave **pública** no repo de onde se clona (`flutter_ui_kit`); chave **privada** no repo onde corre o CI (`app_yummy_log`), em Secrets.

### Erro: Permission denied (publickey) no CI

```text
git@github.com: Permission denied (publickey).
fatal: Could not read from remote repository.
```

**Causa:** O CI está a usar SSH para clonar, mas a chave não é aceite. Verificar:

1. **Secret `SSH_PRIVATE_KEY`** (repo **app_yummy_log** → Settings → Secrets and variables → Actions): o valor deve ser o conteúdo **inteiro** do ficheiro da chave privada (`deploy_key`), incluindo as linhas `-----BEGIN ...` e `-----END ...`, sem espaços extra no início/fim.
2. **Deploy key** (repo **flutter_ui_kit** → Settings → Deploy keys): deve existir uma entrada com a chave **pública** (`deploy_key.pub`). A chave é válida apenas para este repositório.
3. Se o passo "Verify SSH key loaded" falhar com "The agent has no identities", o secret está vazio ou a chave não foi carregada (formato/cópia incorreta).

Para copiar a chave privada para o clipboard: `cat deploy_key | pbcopy`.

### Erro: Bundler version ou Ruby incompatível

```bash
Could not find 'bundler' (...)
# ou
connection_pool requires ruby version >= 3.2.0, which is incompatible with the current version, ruby 2.6.x
```

**Solução:** O deploy iOS exige **Ruby 3.2+**. Adicione ao `~/.zshrc`:

```bash
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
```

Depois: `source ~/.zshrc && cd ios && bundle install`.

### Erro: Keychain password incorrect

```bash
security: SecKeychainItemSetAccessWithPassword: The user name or passphrase you entered is not correct.
```

**Solução:** Use a senha do seu usuário macOS (login do sistema)

### Erro: 2FA Required

```bash
Two-factor Authentication (6 digits code) is enabled
```

**Solução:** Digite o código 2FA do seu dispositivo Apple

---

## Variáveis de Ambiente

### Produção (.env.prod)

| Variável | Descrição |
|----------|-----------|
| `TARGET` | Entry point: `lib/main_production.dart` |
| `SPLIT_DEBUG_INFOPATH` | Pasta dos Dart symbols (ex: `build/app/outputs/symbols`). **Obrigatório** para prod (ofuscação). |
| `FIREBASE_IOS_APP_ID` | Firebase App ID do iOS (ex: `1:123:ios:abc`) para upload de symbols no Crashlytics. Se não definido, o upload é pulado. |
| `SENTRY_ORG` | Slug da organização no Sentry (ex: `minha-org`). Para upload de symbols via sentry_dart_plugin. |
| `SENTRY_PROJECT` | Slug do projeto no Sentry (ex: `yummy-log`). |
| `SENTRY_AUTH_TOKEN` | Auth token do Sentry (Settings → Auth Tokens). Se não definidos, o upload de symbols para Sentry é pulado. |
| `APP_STORE_CONNECT_KEY_ID` | Key ID da API App Store Connect |
| `APP_STORE_CONNECT_ISSUER_ID` | Issuer ID da API |
| `APP_STORE_CONNECT_KEY_CONTENT` | Conteúdo da chave privada (base64) |
| **Android / Google Play** | |
| `SUPPLY_TRACK` | Track do Play Console: `internal`, `alpha`, `beta` ou `production`. Default: `internal`. Para publicar em produção use `production`. |
| Conta de serviço Play | O `supply` usa credenciais via [conta de serviço](https://docs.fastlane.tools/actions/supply/#setup). Configure `SUPPLY_JSON_KEY_DATA` (JSON da chave) ou `SUPPLY_JSON_KEY_FILE` no `.env.prod` (ou variáveis de ambiente) para upload na Play Store. |

### Desenvolvimento (.env.dev)

| Variável | Descrição |
|----------|-----------|
| `TARGET` | Entry point: `lib/main_development.dart` |
| `FIREBASE_IOS_APP_ID` | App ID do Firebase para iOS |
| `FIREBASE_ANDROID_APP_ID` | App ID do Firebase para Android (Firebase App Distribution) |
| `GOOGLE_APPLICATION_CREDENTIALS` | Path para service account JSON (Firebase e, se configurado, Play Console) |

### Comum (.env)

| Variável | Descrição |
|----------|-----------|
| `KEYCHAIN_NAME` | Nome do keychain temporário |
| `KEYCHAIN_PASSWORD` | Senha do keychain |
| `MATCH_PASSWORD` | Senha para criptografia do match (opcional) |

---

## Lanes Disponíveis

### iOS (ios/fastlane/Fastfile)

```bash
cd ios

# Deploy para Firebase App Distribution
fastlane dev

# Deploy para TestFlight
fastlane prod

# Baixar certificados
fastlane certificates
```

### Lanes Internas (fastlane/GeneralFastfile)

| Lane | Descrição |
|------|-----------|
| `clean_project` | Flutter clean + pub get |
| `flutter_build` | Build do Flutter (prod: com ofuscação e split-debug-info) |
| `build_ios_and_export_ipa` | Gera IPA |
| `upload_crashlytics_symbols` | Envia Dart symbols ao Firebase Crashlytics (prod) |
| `upload_sentry_symbols` | Envia Dart symbols ao Sentry via sentry_dart_plugin (prod) |
| `rematch` | Sincroniza certificados |
| `upload_store` | Upload para TestFlight |
| `uploading_firebase_distribution` | Upload para Firebase |
| `connect_app_store` | Conecta à API App Store Connect |
| `update_gem` | Atualiza bundler |

---

## Referências

- [Fastlane Docs](https://docs.fastlane.tools/)
- [Match - Code Signing](https://docs.fastlane.tools/actions/match/)
- [App Store Connect API](https://developer.apple.com/documentation/appstoreconnectapi)
- [Firebase App Distribution](https://firebase.google.com/docs/app-distribution)

---

## Checklist de Deploy

### Primeira vez no projeto

- [ ] Configurar Ruby 3.2+ (adicionar `export PATH="/opt/homebrew/opt/ruby/bin:$PATH"` ao `~/.zshrc`)
- [ ] Configurar SSH para GitHub (`~/.ssh/config`)
- [ ] Criar arquivos `.env`, `.env.dev`, `.env.prod`
- [ ] Rodar `cd ios && bundle install`
- [ ] Baixar certificados: `fastlane certificates`

### Deploy regular

- [ ] Verificar que está na branch correta
- [ ] Rodar `sh deploy.sh`
- [ ] Escolher ambiente (dev/prod)
- [ ] Inserir 2FA se solicitado

### Certificado expirado

- [ ] `cd ios`
- [ ] `fastlane match nuke distribution`
- [ ] `fastlane match appstore --force`
- [ ] `cd .. && sh deploy.sh`
