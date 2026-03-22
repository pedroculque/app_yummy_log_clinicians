# Regras de segurança do Firestore (projeto compartilhado)

Este documento descreve o **modelo de acesso** implementado em [`firestore.rules`](../firestore.rules) no repositório do **app do clínico**. As mesmas regras são publicadas no projeto Firebase **`app-yummy-log-diary`**, compartilhado com o **app do paciente** (Yummy Log).

**Objetivo:** explicar leituras cruzadas em `users/{userId}` (perfil: `displayName`, `photoUrl`, etc.), o vínculo em `clinicians/.../patients/...`, e onde procurar quando aparece `permission-denied`.

---

## Onde está o código e como publicar

| Item | Detalhe |
|------|---------|
| **Arquivo no repo** | `firestore.rules` (raiz do repositório `app_yummy_log_clinicians`) |
| **Projeto Firebase** | `app-yummy-log-diary` |
| **Deploy** | `firebase deploy --project app-yummy-log-diary --only firestore:rules` (ver também [DEPLOY.md](DEPLOY.md)) |

Alterações locais **não** entram em produção até o deploy das regras.

---

## Contexto: por que `users/{userId}` precisa de mais de “só o dono”

### App do paciente (Conectar)

Na tela **Conectar**, o paciente precisa mostrar **nome e foto** do profissional. Parte dos dados vem de `clinician_codes/{code}`; em muitos casos `photoUrl` (e detalhes de perfil) estão apenas no documento raiz **`users/{clinicianUid}`**.

Se a regra fosse **apenas** `request.auth.uid == userId`, o paciente autenticado **não** poderia ler `users/{clinicianUid}` → fallback de perfil falhava.

**Solução:** permitir **leitura** de `users/{userId}` quando existir vínculo **`clinicians/{userId}/patients/{request.auth.uid}`** — aqui `userId` é o UID do **clínico** e `request.auth.uid` é o UID do **paciente**.

### App do clínico (lista de pacientes, diário)

O app dos clínicos faz **`get()`** em **`users/{patientId}`** para montar nome, `photoUrl`, etc. A condição acima **não** concede isso: ela só cobre paciente → documento do clínico.

Foi necessária uma regra **espelhada:** leitura de `users/{userId}` quando existir **`clinicians/{request.auth.uid}/patients/{userId}`** — `request.auth.uid` é o **clínico** e `userId` é o **paciente**.

Sem essa segunda condição, o cliente registra erros como:

`[cloud_firestore/permission-denied] … ao ler users/{patientId}`

(Ex.: `FirestorePatientsRepository.watchPatients`.)

---

## Documento raiz `users/{userId}` — matriz de acesso

Todas as condições abaixo são **`allow read`** aditivas (basta uma ser verdadeira). **Escrita** do documento raiz continua **só para o dono**.

| Quem | Condição (resumo) | Finalidade |
|------|-------------------|------------|
| **Dono** | `request.auth.uid == userId` | Perfil próprio; leitura e escrita (conforme `firestore.rules`) |
| **Paciente** | Existe `clinicians/{userId}/patients/{request.auth.uid}` | `userId` = clínico; paciente lê perfil do profissional (ex.: Conectar) |
| **Clínico** | Existe `clinicians/{request.auth.uid}/patients/{userId}` | `userId` = paciente; clínico lê perfil do paciente (lista, UI) |

**Privacidade:** em ambos os casos de leitura cruzada, o cliente Firestore pode ler o **documento inteiro** `users/{userId}`, não apenas `displayName`/`photoUrl`. Se no futuro houver campos sensíveis só para o dono, convém separar em outro path ou subcoleção com regras mais restritas.

---

## Consistência com outras regras do mesmo arquivo

O mesmo critério de vínculo (`exists(…/clinicians/{clinicianUid}/patients/{patientId})`) já aparece em:

- **`users/{patientId}/connections/{connectionId}`** — clínico vinculado pode **ler** conexões do paciente
- **`users/{patientId}/meals/{mealId}`** — clínico vinculado pode **ler** refeições do paciente

O documento raiz **`users/{userId}`** segue a **mesma ideia de confiança**: só quem tem vínculo explícito em `clinicians/.../patients/...` acessa dados do outro lado.

**Não alterado** por este desenho (salvo outras mudanças no arquivo): `clinician_codes`, `clinicians/{clinicianId}/**` genérico, `users/.../meals` do dono, regras de `form_config` se estiverem noutro `match` no projeto.

---

## Firebase Storage (fotos de perfil) — não confundir com Firestore

As imagens costumam estar em paths como **`users/{uid}/profile/...`**. Regras do **Storage** são um ficheiro separado (`storage.rules` no backend).

- Pedidos **HTTP** (ex.: `NetworkImage` / URL direta) **não** enviam `request.auth` do Firebase → podem receber **403** mesmo com regra Firestore correta.
- O app do paciente pode precisar do **SDK do Storage** (com sessão autenticada) para ler a pasta de perfil do clínico, com regras Storage que validem vínculo (por exemplo checando documento no Firestore).

Isto é **independente** da leitura do **documento** `users/{uid}` no Firestore (campos `photoUrl`, etc.).

---

## Checklist de diagnóstico (`permission-denied`)

1. Confirmar no log se o path é **`users/{algumUid}`** (documento raiz) ou subcoleção (`meals`, `connections`, `form_config`, …).
2. Se for **`users/{patientId}`** com utilizador **clínico:** verificar se existe **`clinicians/{clinicianAuthUid}/patients/{patientId}`** no console (vínculo real).
3. Se for **`users/{clinicianUid}`** com utilizador **paciente:** verificar **`clinicians/{clinicianUid}/patients/{patientAuthUid}`**.
4. Confirmar que as regras **deployadas** no projeto `app-yummy-log-diary` correspondem ao `firestore.rules` do repo (deploy recente).
5. Para fotos: distinguir erro **Firestore** vs **Storage** (403 em URL HTTP).

---

## Referências

- [`firestore.rules`](../firestore.rules) — fonte da verdade sintática
- [BACKEND_CONECTAR.md](BACKEND_CONECTAR.md) — coleções, vínculo paciente–clínico, push, Cloud Functions
- [DEPLOY.md](DEPLOY.md) — comandos `firebase deploy` (Firestore, Storage, Functions)
- [FIREBASE_SETUP_CLINICIANS.md](FIREBASE_SETUP_CLINICIANS.md) — app do clínico no mesmo projeto Firebase
- [BEHAVIOR_FORM_CONFIG.md](BEHAVIOR_FORM_CONFIG.md) — `form_config` (regras resumidas; perfil global em `FIRESTORE_RULES.md`)
