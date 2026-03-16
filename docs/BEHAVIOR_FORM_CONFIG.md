# Configuração do formulário de comportamento (clínico)

Especificação da feature que permite ao **clínico** configurar quais perguntas de **comportamento** aparecem no formulário "Adicionar comida" do **paciente**. A seção de comportamento no app do paciente só é exibida (e apenas os itens habilitados) quando o paciente está vinculado a um clínico que configurou o formulário.

---

## Objetivo

- O clínico entra no contexto de um paciente e acessa uma tela para **customizar o formulário** desse paciente.
- Nessa tela: lista de **comportamentos** agrupados por categoria, cada um com **toggle** (mostrar / ocultar).
- Apenas comportamentos **habilitados** pelo clínico aparecem na seção "Comportamento" do formulário "Adicionar comida" no app do paciente.
- Se o clínico não configurou (ou desabilitou a seção), o paciente não vê a seção de comportamento.

---

## Fluxo no app do clínico

1. Clínico está na **lista de pacientes** ou na **tela do diário do paciente**.
2. **Entrada:** botão ou ação do tipo **"Configurar formulário"** / **"Comportamentos do formulário"** (por paciente).
3. Ao tocar, abre uma **tela full screen** (ou modal) com:
   - Título: ex.: **"Comportamentos para o formulário"**.
   - Lista de **cards** agrupados por categoria (ver lista abaixo).
   - Em cada card: **nome do comportamento** + **toggle** (mostrar / ocultar).
   - Opcional: toggle global **"Habilitar seção de comportamento"** (se desligado, o paciente não vê nenhum comportamento).
4. Ao alterar toggles, o app persiste no Firestore (ex.: debounce ou botão "Salvar").
5. Voltar fecha a tela e retorna à lista ou ao diário do paciente.

**Onde colocar o botão (definido):**

- **Nos dois:** no **card do paciente** (lista) e no **header da tela do diário do paciente**. Em ambos os lugares, mesma ação: abrir a tela "Comportamentos para o formulário".

---

## Catálogo de comportamentos (proposto)

Categorias e itens para exibir na tela de configuração (textos podem ser ajustados e traduzidos via l10n).

### Métodos compensatórios

| Chave (ID)              | Label (pt)                     |
|-------------------------|--------------------------------|
| `forcedVomit`           | Vômito auto induzido           |
| `usedLaxatives`         | Uso de laxante                |
| `diuretics`             | Uso de diurético              |
| `otherMedication`       | Outras medicações             |
| `compensatoryExercise`  | Exercício físico compensatório|
| `chewAndSpit`           | Mastigar e cuspir             |

### Restrição alimentar

| Chave (ID)        | Label (pt)           |
|-------------------|----------------------|
| `intermittentFast` | Jejum intermitente   |
| `skipMeal`         | Pular refeição       |

### Exagero alimentar

| Chave (ID)     | Label (pt)          |
|----------------|---------------------|
| `bingeEating`  | Compulsão alimentar |

### Outros

| Chave (ID)       | Label (pt)        |
|------------------|-------------------|
| `ateInSecret`    | Comer escondido   |
| `guiltAfterEating`| Culpa após comer  |
| `calorieCounting`| Contagem de calorias |
| `bodyChecking`   | Checagem corporal |
| `bodyWeighing`   | Pesagem corporal  |
| `hiddenFood`     | Escondeu comida   |
| `regurgitated`   | Regurgitação      |

**Nota:** Os 6 comportamentos já existentes no `MealEntry` são: `hiddenFood`, `regurgitated`, `forcedVomit`, `ateInSecret`, `usedLaxatives`, `diuretics`. A timeline do app clínico (diário do paciente) lê esses campos do Firestore e exibe as tags de comportamento. Na **Fase 1 (MVP)** da feature, pode-se expor esses 6 na tela de configuração (mostrar/ocultar). Na **Fase 2**, incluir o restante do catálogo e estender o modelo de dados do paciente (novos campos ou mapa em `MealEntry`) e o formulário no app do paciente.

---

## Modelo de dados (Firestore)

### Onde salvar

- **Documento:** subcoleção `form_config`, documento com id `behavior`: path completo `users/{patientId}/form_config/behavior`.
- **Motivo:** o **app do paciente** precisa ler essa configuração ao exibir o formulário "Adicionar comida". O paciente só tem acesso a `users/{patientId}/...`.
- **Escrita:** qualquer **clínico** que tenha o paciente vinculado pode alterar. Vários clínicos podem editar a mesma config; a última escrita prevalece. Na tela de config, exibir um **log de alterações** (quem alterou e quando) para boa UX e transparência.

### Estrutura sugerida do documento

```json
{
  "sectionEnabled": true,
  "updatedAt": "2025-03-15T12:00:00Z",
  "updatedBy": "clinicianUid",
  "updatedByDisplayName": "Dr. Maria Silva",
  "behaviors": {
    "forcedVomit": true,
    "usedLaxatives": true,
    "hiddenFood": true,
    "regurgitated": false,
    "ateInSecret": true
  },
  "changeLog": [
    { "at": "2025-03-15T12:00:00Z", "by": "clinicianUid", "displayName": "Dr. Maria Silva" },
    { "at": "2025-03-14T09:30:00Z", "by": "otherClinicianUid", "displayName": "Dr. João Santos" }
  ]
}
```

- `sectionEnabled`: se `false`, o app do paciente não mostra a seção de comportamento.
- `behaviors`: mapa `behaviorId -> boolean` (true = mostrar no formulário).
- `updatedAt` / `updatedBy` / `updatedByDisplayName`: última alteração (exibir na UI: "Alterado por X em [data]").
- `changeLog`: array com as últimas N alterações (ex.: 5–10), mais recente primeiro. Cada item: `at` (ISO 8601), `by` (UID), `displayName` (nome do clínico para exibição). Ao salvar, adicionar entrada no início e truncar ao tamanho máximo.

Se o documento não existir, o app do paciente **não exibe** a seção de comportamento (o paciente só vê comportamentos se um clínico tiver configurado).

---

## Múltiplos clínicos

- **Todos os clínicos** vinculados ao paciente podem alterar a config (última escrita prevalece).
- Para transparência e boa UX: na tela de config, exibir **log de alterações** — "Última alteração por [nome] em [data]" e, opcionalmente, histórico com as últimas N alterações (quem e quando). Campos `updatedByDisplayName`, `updatedAt` e `changeLog` no Firestore suportam isso.

---

## Regras Firestore (resumo)

- **Leitura** de `users/{patientId}/form_config`: usuário autenticado seja o próprio paciente (`auth.uid == patientId`) **ou** um clínico que tenha esse paciente na lista (`exists(clinicians/(auth.uid)/patients/(patientId))`).
- **Escrita** em `users/{patientId}/form_config`: qualquer clínico que tenha o paciente vinculado (`exists(clinicians/(auth.uid)/patients/(patientId))`). Todos podem alterar; usar `changeLog` para registrar quem alterou e quando.

---

## App do paciente (escopo no outro repo – app_yummy_log)

A lógica será implementada no app do paciente em breve.

- **Regra central:** o paciente **não vê** a seção de comportamento se o clínico **não tiver configurado** (documento `form_config` inexistente ou `sectionEnabled != true`).
- Ao abrir o formulário "Adicionar comida", o app do paciente:
  1. Lê o documento `users/{currentUserId}/form_config/behavior` (subcoleção `form_config`, doc `behavior`).
  2. Se o documento **não existir** ou `sectionEnabled != true` → **não exibe** a seção "Comportamento".
  3. Se existir e `sectionEnabled == true`, monta a lista de perguntas apenas para as chaves em `behaviors` com valor `true`.
  4. Persiste as respostas nos campos já existentes de `MealEntry` (e, na Fase 2, nos novos campos ou mapa conforme catálogo).

---

## Fases de implementação sugeridas

| Fase | Escopo | App clínico | App paciente | Firestore |
|------|--------|-------------|--------------|-----------|
| **1 (MVP)** | Só os 5 comportamentos atuais | Tela de config com lista de cards + toggles; salvar em `users/{patientId}/form_config` | Ler config; mostrar seção e perguntas somente dos habilitados | Doc `form_config` + regras |
| **2** | Catálogo completo | Incluir todos os itens do catálogo; categorias (Métodos compensatórios, etc.) | Novos campos ou mapa em MealEntry; formulário dinâmico por config | Mesmo doc; chaves estendidas |

---

## UI sugerida (app do clínico)

- **Tela:** "Comportamentos para o formulário" (título).
- **Subtítulo:** "Paciente: [Nome do paciente]".
- **Toggle global:** "Habilitar seção de comportamento no formulário do paciente" (controla `sectionEnabled`).
- **Lista:** agrupada por categoria (ex.: "Métodos compensatórios", "Restrição alimentar", …). Cada categoria é um bloco com título; dentro, cards (ou list tiles) com:
  - Nome do comportamento.
  - Switch (mostrar / ocultar).
- **Persistência:** ao mudar um toggle, atualizar Firestore (com debounce, ex.: 500 ms) ou botão "Salvar" que grava tudo.
- **Log de alterações (UX):** na própria tela de config, exibir quem alterou e quando, por exemplo:
  - Texto em destaque: **"Última alteração: por [nome do clínico] em [data/hora]"** (dados de `updatedByDisplayName` e `updatedAt`).
  - Opcional: seção expansível ou lista **"Histórico de alterações"** com as últimas entradas de `changeLog` (ex.: "Dr. Maria Silva – 15/03/2025 12:00", "Dr. João Santos – 14/03/2025 09:30"). Assim fica claro que vários clínicos podem editar e quando foi a última mudança.

---

## Referências

- [BACKEND_CONECTAR.md](BACKEND_CONECTAR.md) – Estrutura `clinicians/.../patients` e regras.
- [ROADMAP.md](ROADMAP.md) – Fase "Configuração do formulário de comportamento".
- `MealEntry` (diary_feature) – Campos atuais: `hiddenFood`, `regurgitated`, `forcedVomit`, `ateInSecret`, `usedLaxatives`.
- `modules/features/patients` – Lista de pacientes, diário do paciente; ponto de entrada do botão "Configurar formulário".
