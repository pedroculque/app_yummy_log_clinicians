# auth_foundation

Camada de autenticação do Yummy Log: interface de repositório e implementação com Firebase Auth (Google, Apple).

## Funcionalidades

- **AuthRepository:** stream de estado do usuário, login com Google e Apple, logout.
- **AuthUser:** modelo com `uid`, `email`, `displayName`, `photoUrl`.
- **Implementações:** `FirebaseAuthRepository` (produção), `StubAuthRepository` (testes/desenvolvimento).
- **AuthException:** exceção com `code` e `message` para tratamento na UI.

## Quick Start

```dart
// No init do app (ex.: após Firebase.initializeApp)
registerAuthFoundation(getIt); // registra AuthRepository (Firebase ou stub)

final repo = getIt<AuthRepository>();
Stream<AuthUser?> stream = repo.authStateChanges;
AuthUser? user = repo.currentUser;
await repo.signInWithGoogle();
await repo.signOut();
```

## Documentação

| Documento | Descrição |
|-----------|-----------|
| (a criar) | docs/architecture.md – interface, implementações, registro |
| (a criar) | docs/features.md – fluxos de login, erro |

## Estrutura

```
lib/
├── auth_foundation.dart        # Barrel (AuthRepository, AuthUser, AuthException)
└── src/
    ├── auth_repository.dart    # Interface + AuthUser + AuthException
    ├── firebase_auth_repository.dart  # Firebase Auth + Google + Apple
    └── stub_auth_repository.dart      # Implementação stub
```

## Dependências

- `firebase_core`, `firebase_auth`, `google_sign_in`, `sign_in_with_apple`, `get_it`

## Referências

- [REQUIREMENTS.md](../../../REQUIREMENTS.md) – v3 (Auth)
- [STATE.md](../../../STATE.md) – decisões de auth e init
