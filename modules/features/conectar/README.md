# conectar_feature

Feature Conectar do Yummy Log: vincular o paciente a um nutricionista por código, com backend em Firestore.

## Funcionalidades

- **Tela Conectar:** entrada de código do nutricionista, validação no Firestore (`clinician_codes`) e feedback de sucesso/erro.
- **Backend:** resolução do código via `ClinicianLinkService`; criação de vínculo em `clinicians/{clinicianUid}/patients/{patientId}` para o app do nutricionista listar pacientes e ler diários.
- **Persistência:** conexão salva localmente (Sembast) e sincronizada em `users/{userId}/connections` com `clinicianUid`/`displayName` quando o código é válido.
- **Estado logado:** exibe se já está conectado e a qual profissional (quando aplicável).
- **Integração com auth:** usa `AuthRepository` para obter `userId` no link/remove; requer login para conectar.

## Quick Start

```dart
// Requer auth_foundation registrado
final feature = ConectarFeature();
feature.registerDependencies(getIt);
final routes = feature.getRoutes(getIt);

// Rota: /conectar
```

## Documentação

| Documento | Descrição |
|-----------|-----------|
| (a criar) | docs/architecture.md – ConectarCubit, ConnectionRepository |
| (a criar) | docs/features.md – fluxo de código, estados |

## Estrutura

```
lib/
├── conectar_feature.dart       # Barrel
└── src/
    ├── conectar_feature.dart   # YummyLogFeature: deps + rota /conectar
    ├── cubit/                  # ConectarCubit
    ├── data/                   # ConnectionRepository, LocalConnectionRepository
    └── pages/                  # ConectarPage
```

## Dependências

- `auth_foundation` – `AuthRepository`
- `sync_foundation` – `ClinicianLinkService` (resolver código, add/remove em `clinicians/.../patients`)
- `persistence_foundation` – `ConnectionLocalDataSource`
- `feature_contract`, `ui_kit`, `yummy_log_l10n`, `go_router`, `flutter_bloc`

## Referências

- [REQUIREMENTS.md](../../../REQUIREMENTS.md) – R1 (tab Conectar), v4 (Conectar com nutricionista)
- [docs/ROADMAP.md](../../../docs/ROADMAP.md) – fases do produto
