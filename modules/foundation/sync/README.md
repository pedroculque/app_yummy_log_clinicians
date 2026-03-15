# sync_foundation

Sincronização offline-first para o Yummy Log: fila persistente, push/pull com Firestore, upload de fotos, resolução de conflitos e indicador de status para UI.

## Funcionalidades

- **SyncService:** orquestra push (local → Firestore) e pull (Firestore → local) com watchers em tempo real.
- **SyncQueue:** fila persistente (Sembast) com retry automático e contagem de tentativas.
- **PhotoUploadService:** upload/download de fotos para Firebase Cloud Storage.
- **ConflictResolver:** resolução de conflitos last-write-wins baseada em `updatedAt`.
- **SyncCubit / SyncIndicator:** estado de sync exposto via BLoC para a UI.
- **Connectivity listener:** auto-sync ao reconectar (debounce 800ms).

## Quick Start

```dart
// No init do app (após Firebase.initializeApp e auth)
registerSyncFoundation(getIt); // registra SyncService, SyncQueue, SyncCubit

final syncService = getIt<SyncService>();
syncService.start(); // inicia watchers e timer

// Enfileirar operações (chamado pelos repositórios)
await syncService.enqueueMeal(mealEntry);
await syncService.enqueueConnection(connectionJson);

// Sync manual
final result = await syncService.sync();

// Na UI
BlocBuilder<SyncCubit, SyncState>(
  builder: (context, state) => SyncIndicator(state: state),
)
```

## Arquitetura

```
┌─────────────────────────────────────────────────────────────────┐
│                         SyncService                             │
│  • Escuta AuthRepository (ativa/desativa por login)             │
│  • Escuta Connectivity (auto-sync ao reconectar)                │
│  • Timer periódico (30s por padrão)                             │
├─────────────────────────────────────────────────────────────────┤
│  PUSH (local → Firestore)         │  PULL (Firestore → local)   │
│  • SyncQueue (Sembast)            │  • Watchers (snapshots)     │
│  • Retry com max attempts         │  • Merge last-write-wins    │
│  • PhotoUploadService             │  • Download de fotos        │
└─────────────────────────────────────────────────────────────────┘
```

## Documentação

| Documento | Descrição |
|-----------|-----------|
| [ROADMAP.md](../../../docs/ROADMAP.md) | Fase 4 – Sync |
| [STATE.md](../../../STATE.md) | Decisões de sync, SyncQueue, conflitos |

## Estrutura

```
lib/
├── sync_foundation.dart           # Barrel export
└── src/
    ├── sync_service.dart          # Orquestrador principal
    ├── sync_queue.dart            # Interface da fila
    ├── sembast_sync_queue.dart    # Implementação Sembast
    ├── sync_operation.dart        # Modelo de operação (create/update/delete)
    ├── sync_config.dart           # Configurações (interval, retries, etc.)
    ├── sync_result.dart           # Resultado de sync
    ├── sync_status.dart           # Status do serviço (idle, syncing, error)
    ├── conflict_resolver.dart     # Estratégias de conflito
    ├── photo_upload_service.dart  # Upload/download Cloud Storage
    ├── meal_sync_remote.dart      # Interface Firestore meals
    ├── firestore_meal_remote.dart # Implementação Firestore meals
    ├── connection_sync_remote.dart    # Interface Firestore connections
    ├── firestore_connection_remote.dart # Implementação Firestore connections
    ├── user_document_writer.dart      # Interface para doc do usuário
    ├── firestore_user_document_writer.dart # Cria/atualiza users/{uid}
    ├── clinician_link_service.dart    # Vínculo paciente-nutricionista
    ├── clinician_invite_code.dart     # Modelo de código de convite
    ├── sync_init.dart             # Registro no GetIt
    └── presentation/
        ├── cubit/
        │   ├── sync_cubit.dart    # Cubit para UI
        │   └── sync_state.dart    # Estados (initial, syncing, completed, error)
        └── widget/
            └── sync_indicator.dart # Widget indicador de status
```

## Configuração (SyncConfig)

| Parâmetro | Padrão | Descrição |
|-----------|--------|-----------|
| `autoSyncEnabled` | `true` | Habilita sync automático por timer |
| `syncIntervalSeconds` | `30` | Intervalo do timer |
| `maxRetries` | `3` | Tentativas máximas por operação |
| `retryDelaySeconds` | `5` | Delay entre retries |
| `batchSize` | `50` | Tamanho do batch (futuro) |
| `conflictStrategy` | `lastWriteWins` | Estratégia de conflito |
| `syncOnConnectivity` | `true` | Sync ao reconectar |
| `syncOnAppResume` | `true` | Sync ao voltar do background |

## Fluxo de Dados

### Push (local → Firestore)
1. Repositório chama `enqueueMeal()` ou `enqueueConnection()`
2. Operação salva na SyncQueue (Sembast)
3. Timer ou connectivity trigger chama `push()`
4. Para cada operação: executa, faz upload de foto se necessário, remove da fila
5. Se falhar: incrementa attempts, mantém na fila até `maxRetries`

### Pull (Firestore → local)
1. Watchers escutam `users/{uid}/meals` e `users/{uid}/connections`
2. Ao receber snapshot: merge com dados locais (last-write-wins)
3. Se foto remota sem arquivo local: download automático

## Internacionalização

Módulo foundation sem strings de UI. O `SyncIndicator` usa strings do `yummy_log_l10n`.

## Dependências

- `cloud_firestore`, `firebase_storage` – backend remoto
- `connectivity_plus` – detecção de rede
- `sembast` – fila persistente
- `flutter_bloc` – SyncCubit
- `auth_foundation`, `persistence_foundation`, `diary_feature` – módulos internos

## Referências

- [REQUIREMENTS.md](../../../REQUIREMENTS.md) – v6 (Sync)
- [STATE.md](../../../STATE.md) – decisões de sync
- [docs/ROADMAP.md](../../../docs/ROADMAP.md) – Fase 4
