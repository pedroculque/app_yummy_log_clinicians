# Criptografia no Yummy Log

Documentação sobre o uso de criptografia no app, para conformidade de exportação (App Store Connect / Apple).

## Resposta para a Apple (Export Compliance)

**O app utiliza apenas criptografia isenta (exempt):**

- **Nenhum dos algoritmos mencionados acima** — ou seja:
  - Não implementa algoritmos de criptografia próprios ou não aceitos como padrão (IEEE, IETF, ITU, etc.).
  - Não utiliza algoritmos de criptografia padrão “em vez de” ou “além de” a criptografia do sistema operacional.

O Yummy Log **usa exclusivamente** a criptografia fornecida pelo sistema operacional (iOS/Android) e pelos SDKs que se apoiam nas APIs do SO para comunicação e autenticação.

---

## O que o app usa

| Uso | Tecnologia | Criptografia |
|-----|------------|--------------|
| Autenticação | Firebase Auth, Google Sign-In, Sign in with Apple | TLS/HTTPS (stack do SO e SDKs) |
| Backend / dados remotos | Cloud Firestore, Firebase Storage | TLS/HTTPS (Firebase SDK → APIs do SO) |
| Persistência local | Sembast (arquivos no sandbox) | Sem criptografia própria; proteção do sandbox/Data Protection do SO quando aplicável |

Nenhum pacote de criptografia customizada (ex.: `pointycastle`, `crypto` para cifras próprias) é utilizado. Não há implementação de AES, RSA, SHA customizados ou outros algoritmos além dos usados internamente pelo SO e pelos SDKs para HTTPS/TLS e fluxos OAuth.

---

## Declaração no Info.plist (iOS)

Para dispensar o questionário de conformidade de exportação no App Store Connect, o projeto declara no `Info.plist`:

- **Chave:** `ITSAppUsesNonExemptEncryption`
- **Valor:** `false`

Isso indica que o app **não** utiliza criptografia não isenta (apenas HTTPS/TLS e recursos de criptografia do SO considerados isentos).

Referência: [Complying with Encryption Export Regulations](https://developer.apple.com/documentation/security/complying-with-encryption-export-regulations).

---

## Resumo para formulários

- **Tipos de algoritmos:** Apenas os usados pelo SO e por bibliotecas padrão para TLS/HTTPS e OAuth (sem algoritmos próprios ou não padronizados).
- **Opção correta no questionário:** “Nenhum dos algoritmos mencionados acima”.
- **Documentação adicional:** Não é necessária quando apenas criptografia isenta é usada; o `Info.plist` com `ITSAppUsesNonExemptEncryption = false` basta para ignorar a configuração de conformidade no App Store Connect.
