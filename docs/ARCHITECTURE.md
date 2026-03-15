# Arquitetura – YummyLog for Clinicians

Este documento descreve a arquitetura do app do clínico: **roteamento (go_router)** com tab bar, **injeção de dependências (get_it)** e **estrutura de módulos**.

---

## Stack técnica

| Responsabilidade | Pacote | Uso |
|------------------|--------|-----|
| **Roteamento e tab bar** | [go_router](https://pub.dev/packages/go_router) | Rotas declarativas; **StatefulShellRoute** para tab bar (Pacientes \| Insights \| Configurações). |
| **Injeção de dependências** | [get_it](https://pub.dev/packages/get_it) | Service locator: registrar repositórios, serviços e cubits no startup. |
| **Estado** | bloc / flutter_bloc | Cubits por feature; registrados no get_it ou fornecidos via contexto. |
| **Backend remoto** | [cloud_firestore](https://pub.dev/packages/cloud_firestore) | Firestore para leitura de pacientes e refeições. |
| **Autenticação** | [firebase_auth](https://pub.dev/packages/firebase_auth) | Google Sign-In e Apple Sign-In. |
| **UI compartilhada** | ui_kit (git) | Design system; tokens e componentes reutilizáveis. |

---

## go_router e tab bar

O app tem **3 abas** fixas: **Pacientes**, **Insights** e **Configurações**. Cada aba mantém sua própria pilha de navegação.

### Modelo com StatefulShellRoute

- **Shell:** um `StatefulShellRoute` com três **StatefulShellBranch** (um por aba).
- **Branch 0 – Pacientes:** rota base `/patients` e rotas filhas (ex.: `/patients/:id/diary`).
- **Branch 1 – Insights:** rota base `/insights`.
- **Branch 2 – Configurações:** rota base `/settings`.
- **Troca de aba:** `StatefulNavigationShell.goBranch(index)` no `BottomNavigationBar.onTap`.

### Login

Login **NÃO é obrigatório** para navegar pelo app. Quando o usuário tenta convidar pacientes sem estar logado:
1. Mostra um `AlertDialog` explicando que login é necessário
2. Direciona para a aba de Configurações (`context.go('/settings')`)
3. Usuário faz login nas Configurações
4. Volta para aba Pacientes e pode convidar

---

## get_it (injeção de dependências)

- **Instância global:** `getIt` em `lib/core/di/injection.dart`.
- **Configuração no startup:** `configureDependencies()` registra:
  - `PatientsFeature` → `PatientsRepository`, `PatientsCubit`
  - `InsightsFeature` → (placeholder)
  - `SettingsFeature` → `AuthCubit`
  - Cubits globais: `ThemeModeCubit`, `LocaleCubit`
- **Acesso:** `getIt<PatientsRepository>()`, `getIt<AuthRepository>()`, etc.

---

## Estrutura de módulos

```
modules/
├── features/
│   ├── patients/           # Feature principal
│   │   ├── lib/src/
│   │   │   ├── cubit/      # PatientsCubit, PatientsState
│   │   │   ├── data/       # Patient, PatientsRepository
│   │   │   ├── pages/      # PatientsPage
│   │   │   └── patients_feature.dart
│   │   └── pubspec.yaml
│   ├── insights/           # Placeholder
│   │   └── ...
│   └── settings/           # Configurações
│       ├── lib/src/
│       │   ├── cubit/      # AuthCubit, AuthState
│       │   ├── pages/      # SettingsPage
│       │   └── settings_feature.dart
│       └── pubspec.yaml
└── foundation/
    ├── auth/               # AuthRepository, LoginPage
    ├── persistence/        # Sembast (cache local)
    └── sync/               # Firestore utilities (do app paciente)
```

### Interface YummyLogFeature

Cada feature implementa:

```dart
abstract class YummyLogFeature {
  String get name;
  void registerDependencies(GetIt getIt);
  List<RouteBase> getRoutes(GetIt getIt, {GlobalKey<NavigatorState>? rootNavigatorKey});
}
```

---

## Fluxo de inicialização

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initPersistence(getIt);      // Sembast
  await initAuth(getIt);             // Firebase Auth
  configureDependencies();           // Features + cubits globais
  await getIt<ThemeModeCubit>().init();
  await getIt<LocaleCubit>().init();
  final router = createAppRouter();
  await bootstrap(() => App(router: router));
}
```

---

## Diferenças do app do paciente

| Aspecto | App Paciente | App Clínico |
|---------|--------------|-------------|
| **Login** | Opcional (pode usar offline) | Opcional (necessário para convidar) |
| **Sync** | Offline-first (Sembast + Firestore) | Online-only (Firestore direto) |
| **Escrita** | Cria/edita refeições | Read-only (visualiza refeições) |
| **Tab bar** | Diário, Conectar, Configurações | Pacientes, Insights, Configurações |

---

## Referências

- [go_router – StatefulShellRoute](https://pub.dev/documentation/go_router/latest/go_router/StatefulShellRoute-class.html)
- [get_it no pub.dev](https://pub.dev/packages/get_it)
- [BACKEND_CONECTAR.md](BACKEND_CONECTAR.md) – Estrutura Firestore
