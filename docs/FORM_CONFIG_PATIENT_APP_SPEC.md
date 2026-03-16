# Especificação: Leitura da config do formulário de comportamento (app do paciente)

Documento para implementação no **app do paciente** (`app_yummy_log`). O **app do clínico** já grava a configuração em Firestore; o app do paciente deve **apenas ler** e usar para exibir (ou ocultar) a seção "Comportamento" no formulário "Adicionar comida".

---

## 1. Onde ler

| Item | Valor |
|------|--------|
| **Path Firestore** | `users/{currentUserId}/form_config/behavior` |
| **Coleção** | `form_config` (subcoleção de `users/{userId}`) |
| **ID do documento** | `behavior` (string literal) |
| **Quem escreve** | Apenas clínicos vinculados ao paciente (app do clínico). |
| **Quem lê** | O próprio paciente (`auth.uid == userId`). As regras Firestore já permitem leitura pelo dono do documento. |

Ou seja: no app do paciente, use o **UID do usuário logado** como `userId` e leia o documento em:

```
users/<currentUserUid>/form_config/behavior
```

---

## 2. Estrutura do documento (Firestore)

O documento é um mapa com os seguintes campos (todos escritos pelo app do clínico):

| Campo | Tipo | Obrigatório | Descrição |
|-------|------|-------------|-----------|
| `sectionEnabled` | boolean | Não (default: considerar `true` se ausente) | Se `false`, o app do paciente **não deve exibir** a seção de comportamento. |
| `behaviors` | map&lt;string, boolean&gt; | Não (default: `{}`) | Chave = ID do comportamento; valor = `true` para "mostrar no formulário", `false` para ocultar. **Só exibir perguntas cuja chave existe e valor é `true`.** |
| `updatedAt` | string (ISO 8601) ou Timestamp | Não | Data da última alteração (informativo; opcional exibir no app paciente). |
| `updatedBy` | string | Não | UID do clínico que alterou. |
| `updatedByDisplayName` | string | Não | Nome do clínico (informativo). |
| `changeLog` | array de objetos | Não | Histórico de alterações; não é necessário para a lógica de exibição. |

**Exemplo de documento:**

```json
{
  "sectionEnabled": true,
  "behaviors": {
    "hiddenFood": true,
    "regurgitated": false,
    "forcedVomit": true,
    "ateInSecret": true,
    "usedLaxatives": true
  },
  "updatedAt": "2025-03-15T12:00:00.000Z",
  "updatedBy": "clinicianUid123",
  "updatedByDisplayName": "Dr. Maria Silva",
  "changeLog": []
}
```

**Parsing:**  
- Se o documento **não existir** (get retorna null ou snapshot.exists == false), tratar como "config não definida".  
- `updatedAt` no Firestore pode vir como `Timestamp`; converter para `DateTime` se for exibir.  
- Se `sectionEnabled` estiver ausente, considerar `true` para compatibilidade.  
- Se `behaviors` estiver ausente ou vazio, considerar que **nenhum** comportamento deve ser exibido (ou, conforme regra de negócio, nenhum = não mostrar a seção).

---

## 3. Regras de exibição no formulário "Adicionar comida"

Aplicar **nesta ordem**:

1. **Documento não existe** → **não exibir** a seção "Comportamento".
2. **Documento existe e `sectionEnabled == false`** → **não exibir** a seção "Comportamento".
3. **Documento existe, `sectionEnabled == true`** → exibir a seção "Comportamento", mas **apenas** as perguntas cujo ID está em `behaviors` **e** `behaviors[id] == true`.

Ou seja:  
- Não mostrar a seção = paciente não vê nenhuma pergunta de comportamento.  
- Mostrar a seção = mostrar só as perguntas habilitadas no mapa `behaviors` (valor `true`).

Ordem sugerida das perguntas na UI: usar a ordem definida no app do clínico (MVP: `hiddenFood`, `regurgitated`, `forcedVomit`, `ateInSecret`, `usedLaxatives`). Filtrar por `behaviors[id] == true` e manter essa ordem.

---

## 4. MVP – Os 5 comportamentos atuais (mapeamento para MealEntry)

No MVP, o app do clínico configura apenas estes 5 IDs. Cada um corresponde a um campo já existente no modelo de refeição (MealEntry ou equivalente) do app do paciente:

| ID do comportamento (chave em `behaviors`) | Campo no MealEntry / modelo de refeição | Descrição (label) sugerida (pt) |
|-------------------------------------------|----------------------------------------|----------------------------------|
| `hiddenFood` | `hiddenFood` (bool) | Escondeu comida |
| `regurgitated` | `regurgitated` (bool) | Regurgitação |
| `forcedVomit` | `forcedVomit` (bool) | Vômito auto induzido |
| `ateInSecret` | `ateInSecret` (bool) | Comer escondido |
| `usedLaxatives` | `usedLaxatives` (bool) | Uso de laxante |

**Implementação:**  
- No formulário "Adicionar comida", após decidir que a seção deve ser exibida, iterar sobre os IDs habilitados (por exemplo na ordem acima) e, para cada um, exibir o controle (checkbox/toggle) correspondente.  
- Ao salvar a refeição, persistir os valores nos **campos já existentes** do MealEntry; não é necessário criar novos campos no MVP.

---

## 5. Fluxo recomendado no app do paciente

1. **Ao abrir (ou antes de exibir) o formulário "Adicionar comida":**
   - Obter o UID do usuário logado (`currentUserId`).
   - Fazer **get** (ou **snapshots** se quiser atualização em tempo real) em `users/<currentUserId>/form_config/behavior`.

2. **Decisão de exibição:**
   - Se o documento não existe → não mostrar seção de comportamento.
   - Se existe e `sectionEnabled != true` → não mostrar seção.
   - Se existe e `sectionEnabled == true` → construir a lista de perguntas: todos os `id` em `behaviors` com `behaviors[id] == true`, na ordem desejada (ex.: hiddenFood, regurgitated, forcedVomit, ateInSecret, usedLaxatives).

3. **Renderização:**
   - Exibir a seção "Comportamento" apenas se a lista de perguntas habilitadas não for vazia (opcional: mesmo com lista vazia pode mostrar o título da seção; o critério mínimo é `sectionEnabled == true`).
   - Para cada ID habilitado, exibir um controle (checkbox/toggle) e ao salvar mapear para o campo correto do MealEntry.

4. **Persistência:**
   - Salvar a refeição com os campos booleanos já existentes do MealEntry (`hiddenFood`, `regurgitated`, `forcedVomit`, `ateInSecret`, `usedLaxatives`). O app do paciente **não escreve** em `form_config`; apenas lê.

---

## 6. Resumo para o agente

- **Ler:** `users/{currentUserId}/form_config/behavior` (documento único, id `behavior`).
- **Não exibir seção** se: documento não existe **ou** `sectionEnabled == false`.
- **Exibir seção** apenas quando documento existe **e** `sectionEnabled == true`; mostrar **somente** as perguntas com `behaviors[id] == true`.
- **MVP:** 5 comportamentos — `hiddenFood`, `regurgitated`, `forcedVomit`, `ateInSecret`, `usedLaxatives`; mapear para os campos já existentes do MealEntry ao salvar.
- **Escrita:** o app do paciente **não** escreve em `form_config`; apenas lê e usa para mostrar/ocultar e filtrar as perguntas do formulário.

---

## 7. Referência cruzada

- Spec completa (clínico + paciente): no repo do app do clínico, arquivo `docs/BEHAVIOR_FORM_CONFIG.md`.
- Regras Firestore para `form_config`: o paciente tem **read** em `users/{userId}/form_config` quando `auth.uid == userId`; **write** apenas para clínicos vinculados (já configurado no projeto compartilhado).
