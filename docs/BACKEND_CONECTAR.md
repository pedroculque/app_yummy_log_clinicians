# Backend Conectar – Vínculo paciente–nutricionista

Documento que descreve a estrutura Firestore e o fluxo de vínculo entre paciente (app Yummy Log) e nutricionista (app do nutricionista, projeto separado).

**Relacionamento:** 1 paciente pode ter **N clínicos**; 1 clínico pode ter **N pacientes**.

---

## Formato do código de convite (invite code)

- **Tamanho:** exatamente **6 caracteres**.
- **Caracteres:** apenas letras (A–Z) e dígitos (0–9), sempre em **maiúsculas**.
- **Exemplo:** `ABC123`, `NUTRI1`.
- **Unicidade:** o ID do documento em `clinician_codes` é o próprio código; cada código pertence a um único clínico.
- No app do paciente, o campo usa formatador (só alfanumérico, máx. 6) e validação antes de enviar; no backend o código é normalizado (trim, maiúsculas, só A–Z e 0–9) para lookup e persistência. Ver `ClinicianInviteCode` em `sync_foundation`.

---

## Visão geral

1. O **paciente** (app Yummy Log) digita um **código de 6 caracteres** na aba Conectar.
2. O app normaliza o código e resolve na coleção `clinician_codes` para obter o UID do clínico.
3. O app cria o vínculo em duas frentes:
   - **Paciente:** documento em `users/{patientId}/connections/{connectionId}` (com `clinicianUid` preenchido).
   - **Clínico:** documento em `clinicians/{clinicianUid}/patients/{patientId}` (permite ao app do nutricionista listar pacientes e, pelas regras, ler `users/{patientId}/meals` e `users/{patientId}/connections`).

---

## Coleções Firestore

### `clinician_codes/{code}`

- **ID do documento:** o código de convite normalizado (6 caracteres, A–Z e 0–9, maiúsculas; ex.: `ABC123`). Deve ser **único** por clínico.
- **Campos:**
  - `clinicianUid` (string, obrigatório): Firebase Auth UID do nutricionista.
  - `displayName` (string, opcional): nome exibido ao paciente após o vínculo.
- **Quem escreve:** apenas o dono do código (`request.auth.uid == clinicianUid`). No app do nutricionista, o profissional cria/atualiza o documento com seu código.
- **Quem lê:** qualquer usuário autenticado (para o paciente resolver o código ao vincular).

### `clinicians/{clinicianId}/patients/{patientId}`

- **Caminho:** subcoleção `patients` do documento do clínico (por exemplo `clinicians/uid_do_nutri/patients/uid_do_paciente`).
- **Campos sugeridos:**
  - `patientId` (string): UID do paciente.
  - `linkedAt` (timestamp): data/hora do vínculo.
- **Quem escreve:** apenas o paciente (`request.auth.uid == patientId`) pode criar/atualizar/deletar o próprio documento (adicionar-se ou remover-se da lista do clínico).
- **Quem lê:** apenas o clínico (`request.auth.uid == clinicianId`) para listar seus pacientes.

### `users/{userId}/connections/{connectionId}` (já existente)

- Mantido pelo app do paciente (sync). Após o backend Conectar, o documento pode incluir `clinicianUid` e `displayName` vindos de `clinician_codes`.

### `users/{patientId}/form_config/behavior`

- **Caminho:** documento único em `users/{patientId}/form_config/behavior`.
- **Descrição:** Configuração do formulário de comportamento do paciente. O clínico define quais perguntas de comportamento aparecem no formulário "Adicionar comida" do app do paciente.
- **Campos:** `sectionEnabled`, `behaviors` (mapa behaviorId → boolean), `updatedAt`, `updatedBy`, `updatedByDisplayName`, `changeLog`.
- **Quem escreve:** clínicos vinculados ao paciente (`exists(clinicians/(auth.uid)/patients/(patientId))`).
- **Quem lê:** o próprio paciente (`auth.uid == patientId`) e clínicos vinculados.
- Ver [BEHAVIOR_FORM_CONFIG.md](BEHAVIOR_FORM_CONFIG.md) para detalhes.

### `clinicians/{clinicianUid}/notification_tokens/{token}`

- **Caminho:** subcoleção de tokens FCM do clínico.
- **Campos:**
  - `token` (string, obrigatório): token FCM do dispositivo.
  - `platform` (string, opcional): `ios`, `android`, etc.
  - `createdAt` / `updatedAt` (timestamp): controle do registro.
- **Quem escreve:** o app do clínico ao autenticar e obter permissão de notificação.
- **Quem lê:** Cloud Function de notificação para enviar push quando houver nova entrada.
- **Limpeza:** se o FCM responder `registration-token-not-registered` ou `invalid-registration-token`, a function **apaga** o documento desse token (evita multicast para registro morto; o device válido volta a receber após reabrir o app e registrar token de novo).

### `clinicians/{clinicianUid}/preferences/notification`

- **Campos:** `pushEnabled` (`bool`, padrão `true` se omitido); `pushMode` (`string`): `all` ou `critical_only`; `updatedAt` (timestamp).
- **Quem escreve:** o próprio clínico (app, aba Configurações → Alertas).
- **Quem lê:** Cloud Function ao decidir se envia push para aquele clínico.

Se `pushEnabled === false`, **nenhum** push é enviado a esse clínico. Se `pushMode == 'critical_only'` (e notificações ligadas), a function só envia quando a refeição tiver comportamento de risco (booleans + `behaviorFlags`). Sem documento: notificações **ligadas**, modo **todas** as entradas.

---

## Fluxo de notificações push

Quando um paciente registra uma nova refeição, cada clínico vinculado pode receber push conforme sua preferência. O fluxo é:

1. **Paciente cria refeição** → documento em `users/{patientId}/meals/{mealId}`.
2. **Cloud Function dispara** → `notifyCliniciansOnNewMeal` (trigger `onCreate`).
3. **Function busca clínicos** → lê `users/{patientId}/connections` e extrai `clinicianUid` de cada conexão com `status !== 'removed'`.
4. **Para cada clínico** → lê `clinicians/{clinicianUid}/preferences/notification`. Se `pushMode == 'critical_only'` e a refeição **não** tem comportamento de risco → **não envia** para esse clínico.
5. **Tokens FCM** → lê `clinicians/{clinicianUid}/notification_tokens`.
6. **Envia FCM** → texto depende se a refeição é considerada **com risco** (mesma lógica de booleans + `behaviorFlags` na function). Independente de `pushMode` ser `all` ou `critical_only`: se houver risco, usa cópia de alerta; senão, genérica.
7. **data:** `patientId`, `patientName`, `mealType`, `eventType: 'new_meal_entry'`, `criticalOnly` (`'true'` / `'false'`).
8. **Clínico toca na notificação** → app abre e navega conforme `eventType` no payload (ver abaixo).

### Textos da notificação (FCM)

| Situação | Título | Corpo |
|----------|--------|--------|
| Refeição **com** comportamento de risco | `Alerta: comportamento de risco` | `Alerta: {displayName} registrou comportamento de risco nesta refeição.` |
| Refeição **sem** risco | `Nova entrada no diário` | `{displayName} registrou uma nova refeição.` |

O app do clínico é responsável por:
- **Configurações:** `NotificationPushPreferencesRepository` grava `pushEnabled` e `pushMode` em `preferences/notification` (aba Alertas).
- **`ClinicianNotificationService`:** permissão, token FCM, logout remove token, deep link por `eventType`, **`app_badge_plus`** (badge do ícone reposto a 0 ao iniciar, ao voltar ao foreground e ao abrir notificação). Re-sync ao voltar ao foreground e ao reabrir o shell após login; evita ficar preso após APNS atrasado no iOS (contador de retries reiniciado no login e no resume).

---

## Cloud Functions: vínculo paciente–clínico

Além de `notifyCliniciansOnNewMeal`, o backend inclui triggers na subcoleção **`clinicians/{clinicianUid}/patients/{patientId}`**:

| Function | Trigger | Comportamento |
|----------|---------|---------------|
| **`onClinicianPatientRemoved`** | `onDelete` do doc `clinicians/.../patients/...` | Com SDK **Admin**, apaga em `users/{patientId}/connections` todos os documentos cujo campo `clinicianUid` coincide com o clínico dono do path. Em seguida envia FCM ao clínico com `eventType: 'patient_unlinked'` (sincroniza UX quando o **paciente** remove o vínculo; o clínico não pode escrever em `users/.../connections`). |
| **`onClinicianPatientLinked`** | `onCreate` do mesmo path | Push ao clínico com `eventType: 'patient_linked'` (paciente acabou de vincular-se). |

**Payload útil para o app:** `eventType` (`new_meal_entry` \| `patient_linked` \| `patient_unlinked`), `patientId`, e campos opcionais (`patientName`, etc., conforme implementação em `functions/src/index.ts`).

**Navegação no app ao tocar na notificação:**

- `patient_unlinked` → `/patients` (lista).
- `new_meal_entry` e `patient_linked` → `/patients/:patientId/diary` (com query `criticalOnly` quando aplicável às refeições).

**Simulador iOS:** o token APNS/FCM costuma **não** ser obtido; push e testes reais exigem dispositivo físico.

---

### Regras de leitura para o clínico

As regras em `firestore.rules` já permitem:

- **Leitura de refeições do paciente:** `users/{patientId}/meals/{mealId}` → permitido se existir `clinicians/(auth.uid)/patients/(patientId)`.
- **Leitura de conexões do paciente:** `users/{patientId}/connections/{connectionId}` → mesma condição.

Ou seja: quando existe documento em `clinicians/{clinicianUid}/patients/{patientId}`, o clínico com UID `clinicianUid` pode ler meals e connections daquele paciente.

---

## Fluxo no app do paciente (Yummy Log)

1. Usuário logado acessa Conectar e informa o código.
2. App chama `ClinicianLinkService.resolveCode(code)` → lê `clinician_codes/{code}`.
3. Se o código não existir ou for inválido → exibe "Código inválido".
4. Se válido:
   - `ClinicianLinkService.addPatientToClinician(patientId, clinicianUid)` → cria `clinicians/{clinicianUid}/patients/{patientId}`.
   - `ConnectionRepository.linkWithCode(code, resolved: ...)` → persiste a conexão localmente (e sync envia para `users/{userId}/connections` com `clinicianUid`/`displayName`).
5. Ao desvincular: remove o documento em `clinicians/{clinicianUid}/patients/{patientId}` e o documento de conexão do paciente.

---

## O que o app do nutricionista precisa fazer

1. **Configurar formulário de comportamento:** para cada paciente vinculado, o clínico pode acessar a tela "Configurar formulário" e gravar em `users/{patientId}/form_config/behavior` quais comportamentos aparecem no formulário "Adicionar comida" do paciente.
2. **Criar/gerenciar código:** ao configurar seu perfil, o nutricionista cria ou atualiza um documento em `clinician_codes/{code}` com:
   - **ID do doc:** código de 6 caracteres (A–Z, 0–9, maiúsculas), ex.: `ABC123`. Deve ser único na coleção.
   - `clinicianUid`: seu Firebase Auth UID.
   - `displayName` (opcional): nome exibido para o paciente.
3. **Listar pacientes:** ler a subcoleção `clinicians/{seuUid}/patients` (cada doc id = `patientId`).
4. **Ler diário do paciente:** com o `patientId`, ler `users/{patientId}/meals` e, se necessário, `users/{patientId}/connections` (as regras permitem se existir o vínculo em `clinicians/{uid}/patients/{patientId}`).

---

## Exclusão de conta do clínico

**Remoção do paciente na lista do clínico (swipe / desvincular):** quando o documento `clinicians/{clinicianUid}/patients/{patientId}` é apagado (pelo fluxo do paciente ou equivalente), **`onClinicianPatientRemoved`** limpa as conexões do lado do paciente e pode enviar push — isto **não** substitui o backlog **C38** abaixo (exclusão da **conta Auth** do clínico).

**No app (implementado):** o fluxo in-app (requisito Apple para apps com login) remove, enquanto a sessão ainda é válida:

- Subcoleções e preferências em `clinicians/{clinicianUid}`,
- Documento do código em `clinician_codes/{code}` associado ao clínico,
- Documento `users/{clinicianUid}` se existir (perfil Firestore),
- Avatar em Storage (`users/{clinicianUid}/profile/...`),
- O registro do usuário no **Firebase Auth**.

**Gap (backlog — requisito C38):** os documentos em **`users/{patientId}/connections`** onde o paciente guardou o vínculo com o clínico (`clinicianUid`, etc.) **não são atualizados por esse fluxo**, porque as [regras do Firestore](../firestore.rules) permitem escrita nessa subcoleção apenas ao **próprio paciente**. Se o clínico excluir a conta:

- No app do paciente pode permanecer uma conexão apontando para um `clinicianUid` que já não existe no Auth (vínculo órfão), até o paciente remover manualmente ou até existir limpeza server-side.

**Implementação recomendada:** Cloud Function com privilégio de admin (SDK Admin) disparada quando o usuário do clínico é **apagado no Firebase Auth** — por exemplo [extensão *Delete User Data*](https://firebase.google.com/docs/extensions/official/delete-user-data) com caminhos customizados, ou função que escuta `auth.user().onDelete()` e:

1. Obtém a lista de `patientId` que estavam em `clinicians/{deletedUid}/patients` **antes** da exclusão (se a função rodar após o client já ter apagado essa subcoleção, usar **coleção de grupo** `collectionGroup('connections')` com filtro `clinicianUid == deletedUid`, se indexado, ou manter registro temporário de vínculos apenas para esse fim), ou
2. Para cada conexão afetada, deleta ou atualiza o documento em `users/{patientId}/connections/{connectionId}`.

O desenho exato depende de índices e de se a exclusão client-side remove `clinicians/.../patients` **antes** ou **depois** da chamada `deleteUser()`; hoje o client remove os dados do clínico **antes** de apagar o Auth, portanto uma função que só lê `clinicians/{uid}/patients` no trigger de Auth delete pode **não ver mais os pacientes**. Por isso a solução robusta costuma ser: **query `collectionGroup('connections')` onde `clinicianUid == uid`** (com [índice composto](https://firebase.google.com/docs/firestore/query-data/index-overview) se necessário) ou fila de “uids a limpar” gravada num passo anterior.

Documentação de produto: [STATE.md](../STATE.md), [REQUIREMENTS.md](../REQUIREMENTS.md) (**C38**).

---

## Referências

- [firestore.rules](../firestore.rules) – regras de `clinician_codes`, `clinicians/.../patients` e `form_config`
- [BEHAVIOR_FORM_CONFIG.md](BEHAVIOR_FORM_CONFIG.md) – Configuração do formulário de comportamento
- [sync_foundation](../modules/foundation/sync) – `ClinicianLinkService` (resolve código, add/remove paciente)
- [ROADMAP.md](ROADMAP.md) – Fases e entregáveis
