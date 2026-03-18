# Configurar Firebase – App do Clínico (YummyLog for Clinicians)

Este guia descreve como **registrar o app do clínico** no Firebase, usando o **mesmo projeto** do app do paciente (`app-yummy-log-diary`) para compartilhar Firestore e Auth.

**Status:** O app do clínico já está registrado no projeto **app-yummy-log-diary**. O `android/app/google-services.json` está no repositório. Os `GoogleService-Info.plist` do iOS **não estão no repositório** (ver `ios/Runner/config/README.md`): cada dev deve baixá-los do Firebase Console e colocar em `ios/Runner/config/{dev,stg,prod}/`. Use os passos abaixo se precisar refazer o registro ou adicionar flavors.

---

## Bundle IDs do app do clínico

- **Android (produção):** `com.yummylogdiaryforclinicians.app`
- **Android (staging):** `com.yummylogdiaryforclinicians.app.stg`
- **Android (development):** `com.yummylogdiaryforclinicians.app.dev`
- **iOS (produção):** `com.yummylogdiaryforclinicians.app`
- **iOS (development):** `com.yummylogdiaryforclinicians.app.dev`
- **iOS (staging):** `com.yummylogdiaryforclinicians.app.stg`

---

## Passo 1: Abrir o projeto no Firebase Console

1. Acesse [Firebase Console](https://console.firebase.google.com/).
2. Selecione o projeto **app-yummy-log-diary** (o mesmo do app do paciente).

---

## Passo 2: Adicionar o app Android do clínico

1. Na página do projeto, clique no ícone **Android** (ou “Adicionar app” → Android).
2. Preencha:
   - **Nome do app (Android):** `YummyLog for Clinicians` (ou outro nome de sua preferência).
   - **Nome do pacote Android:** `com.yummylogdiaryforclinicians.app`
     - Use exatamente este valor para o build de **produção**.
     - Os flavors `.dev` e `.stg` podem usar o mesmo `google-services.json` na maioria dos casos; se precisar de apps separados (ex.: Analytics por ambiente), repita este passo para `com.yummylogdiaryforclinicians.app.dev` e `com.yummylogdiaryforclinicians.app.stg`.
3. (Opcional) Preencha “Apelido do app” e “Debug signing certificate SHA-1” se for usar recursos que exijam.
4. Clique em **Registrar app**.
5. **Baixe** o arquivo `google-services.json`.
6. **Substitua** o arquivo existente em:
   ```
   android/app/google-services.json
   ```
7. Conclua o assistente (já temos o plugin no projeto). Se o assistente pedir para adicionar o plugin, o projeto já usa `com.google.gms.google-services` em `android/app/build.gradle.kts`.

---

## Passo 3: Adicionar o app iOS do clínico

1. No mesmo projeto Firebase, clique no ícone **iOS** (ou “Adicionar app” → iOS).
2. Preencha:
   - **ID do pacote iOS:** `com.yummylogdiaryforclinicians.app`
     - Use exatamente este valor para o build de **produção**.
     - Para flavors dev/stg, se quiser configs separadas, adicione depois `com.yummylogdiaryforclinicians.app.dev` e `com.yummylogdiaryforclinicians.app.stg`.
   - **Apelido do app:** `YummyLog for Clinicians` (opcional).
   - **App Store ID:** opcional.
3. Clique em **Registrar app**.
4. **Baixe** o arquivo `GoogleService-Info.plist`.
5. **Coloque** o arquivo em:
   ```
   ios/Runner/config/prod/GoogleService-Info.plist   # produção
   ios/Runner/config/dev/GoogleService-Info.plist   # development
   ios/Runner/config/stg/GoogleService-Info.plist   # staging
   ```
   Ver [ios/Runner/config/README.md](../ios/Runner/config/README.md) para detalhes. Os plists não estão no repositório (`.gitignore`).
6. Conclua o assistente. O Xcode usa o plist correto por scheme (dev/stg/prod).

---

## Passo 4: (Opcional) Apps para flavors dev/stg

Se quiser **configurações Firebase separadas** por ambiente (por exemplo, Analytics ou projetos diferentes):

- **Android:** repita o Passo 2 para:
  - `com.yummylogdiaryforclinicians.app.dev`
  - `com.yummylogdiaryforclinicians.app.stg`
- **iOS:** repita o Passo 3 para:
  - `com.yummylogdiaryforclinicians.app.dev`
  - `com.yummylogdiaryforclinicians.app.stg`

Para cada um, baixe o `google-services.json` ou `GoogleService-Info.plist` e use **build flavors / schemes** para escolher o arquivo correto por ambiente. Para a maioria dos casos, **um app Android e um app iOS** (produção) são suficientes.

---

## Passo 5: Notificações push (Cloud Messaging)

Para as notificações push funcionarem no iOS:

1. No Firebase Console → **Project Settings** → **Cloud Messaging** → **Apple app configuration**.
2. Faça upload da **APNs Authentication Key** (.p8) ou do certificado APNs do seu app.
3. No Xcode, habilite **Push Notifications** e **Background Modes → Remote notifications** (já configurado no projeto).

O app do clínico usa `firebase_messaging` e a Cloud Function `notifyCliniciansOnNewMeal` envia push quando um paciente registra nova refeição (texto de **alerta** se houver comportamento de risco na refeição, senão texto genérico). Ver [BACKEND_CONECTAR.md](BACKEND_CONECTAR.md).

---

## Passo 6: Verificar no projeto

1. Confirme que:
   - `android/app/google-services.json` contém `"package_name": "com.yummylogdiaryforclinicians.app"` (ou o package do flavor que você registrou).
   - `ios/Runner/config/*/GoogleService-Info.plist` contém `<key>BUNDLE_ID</key>` com o bundle correto (dev/stg/prod).
2. Rode o app:
   ```bash
   flutter run --flavor development -t lib/main_development.dart
   ```
   ou o flavor que estiver usando.
3. Teste **login** (Google/Apple) nas Configurações e **geração de código de convite** na aba Pacientes.

---

## Alternativa: FlutterFire CLI

Se preferir usar o [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/):

1. Instale: `dart pub global activate flutterfire_cli`
2. No diretório do projeto: `flutterfire configure`
3. Escolha o projeto **app-yummy-log-diary** e selecione as plataformas (Android, iOS).
4. O CLI pode **criar** novos apps no Firebase para os bundle IDs que o Flutter detectar no projeto (a partir do `build.gradle` e do Xcode). Confirme se os IDs criados são os do clínico (`com.yummylogdiaryforclinicians.app` etc.).
5. O CLI gera `lib/firebase_options.dart`; o projeto atual usa **apenas** `google-services.json` e `GoogleService-Info.plist` para inicializar o Firebase. Se usar `firebase_options.dart`, atualize `init_auth.dart` para:

   ```dart
   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
   ```

Se quiser manter o fluxo atual (sem `firebase_options.dart`), basta seguir os passos manuais acima e substituir os dois arquivos de config.

---

## Resumo

| Ação | Onde |
|------|------|
| Projeto Firebase | **app-yummy-log-diary** (mesmo do app do paciente) |
| Registrar app Android | Package: `com.yummylogdiaryforclinicians.app` |
| Registrar app iOS | Bundle ID: `com.yummylogdiaryforclinicians.app` |
| Colocar config Android | `android/app/google-services.json` |
| Colocar config iOS | `ios/Runner/config/{dev,stg,prod}/GoogleService-Info.plist` (ver config/README.md) |

Depois de substituir os arquivos e rodar o app, o login e o uso do Firestore (código de convite, lista de pacientes) devem funcionar com o app do clínico.
