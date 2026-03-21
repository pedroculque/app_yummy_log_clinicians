# ID de Suporte (Configurações)

Documentação cruzada: [docs/OBSERVABILITY.md](../../../../docs/OBSERVABILITY.md) (observabilidade global), [docs/ARCHITECTURE.md](../../../../docs/ARCHITECTURE.md) (arranque e binding), [REQUIREMENTS.md](../../../../REQUIREMENTS.md) (C9).

## O que é

O **ID de Suporte** mostrado na secção **Suporte** em Configurações é o **UID do Firebase Auth** do utilizador autenticado — o mesmo valor que [`AuthUser.uid`](../../../foundation/auth/lib/src/auth_repository.dart) expõe após o login. Não é um código gerado só para suporte nem um hash de e-mail.

## Quando aparece

| Condição | Comportamento |
|----------|----------------|
| `AuthCubit` disponível na rota `/settings` | Secção Suporte é montada (inclui avaliar app). |
| Utilizador **não** autenticado | O cartão **ID de Suporte** não é exibido; mantém-se **Avaliar o app**. |
| Utilizador autenticado | Cartão com UID monoespaçado, botão **Copiar** e texto de ajuda (`supportIdHint`). |

Implementação: [`settings_page.dart`](../lib/src/pages/settings_page.dart) — `BlocBuilder<AuthCubit, AuthState>` à volta da secção Suporte; widget `_SupportCard`.

## Ligação com observabilidade

Quando o utilizador faz login ou já está logado, [`init_session_logger_user_binding`](../../../../lib/core/observability/init_session_logger_user_binding.dart) reage a `AuthRepository.authStateChanges` e chama `SessionLogger.setUser(user?.uid)`. O cliente Sentry (`SentrySessionClient`) propaga o mesmo identificador ao scope (utilizador Sentry + tags `user` e `support_id`), para cruzar erros no painel com o ID que o clínico copia no ecrã.

Documentação geral: [docs/OBSERVABILITY.md](../../../../docs/OBSERVABILITY.md).

## Internacionalização

| Chave | Uso |
|-------|-----|
| `supportIdLabel` | Título do cartão |
| `supportIdHint` | Subtítulo explicativo |
| `copySupportId` | Rótulo do botão Copiar |
| `supportIdCopied` | Mensagem do snackbar após copiar |
| `sectionSupport` | Título da secção |

Ficheiros ARB: `modules/shared/yummy_log_l10n/lib/l10n/arb/app_{pt,es,en}.arb`.
