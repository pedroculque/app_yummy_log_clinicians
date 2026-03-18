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

---

## Fluxo de notificações push

Quando um paciente registra uma nova refeição, o clínico vinculado recebe uma notificação push. O fluxo é:

1. **Paciente cria refeição** → documento em `users/{patientId}/meals/{mealId}`.
2. **Cloud Function dispara** → `notifyCliniciansOnNewMeal` (trigger `onCreate`).
3. **Function busca clínicos** → lê `users/{patientId}/connections` e extrai `clinicianUid` de cada conexão com `status !== 'removed'`.
4. **Para cada clínico** → lê `clinicians/{clinicianUid}/notification_tokens` e obtém os tokens FCM.
5. **Envia FCM** → `admin.messaging().sendEachForMulticast()` com:
   - **notification:** título "Nova entrada no diário", body "{nome} registrou uma nova refeição".
   - **data:** `patientId`, `patientName`, `mealType`, `eventType: 'new_meal_entry'`.
6. **Clínico toca na notificação** → app abre e navega para `/patients/{patientId}/diary`.

O app do clínico (`ClinicianNotificationService`) é responsável por:
- Solicitar permissão de notificação.
- Obter e persistir o token FCM em `clinicians/{uid}/notification_tokens/{token}`.
- Remover o token ao fazer logout.
- Tratar `onMessageOpenedApp` e `getInitialMessage` para navegar ao diário.

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

## Referências

- [firestore.rules](../firestore.rules) – regras de `clinician_codes`, `clinicians/.../patients` e `form_config`
- [BEHAVIOR_FORM_CONFIG.md](BEHAVIOR_FORM_CONFIG.md) – Configuração do formulário de comportamento
- [sync_foundation](../modules/foundation/sync) – `ClinicianLinkService` (resolve código, add/remove paciente)
- [ROADMAP.md](ROADMAP.md) – Fases e entregáveis
