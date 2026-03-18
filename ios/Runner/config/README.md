# Firebase config por flavor

Os arquivos `GoogleService-Info.plist` **não estão no repositório**. Cada dev deve baixá-los do Firebase Console e colocar localmente.

## Como obter

1. Acesse [Firebase Console](https://console.firebase.google.com) → projeto **app-yummy-log-diary**
2. Para cada app iOS (Dev, Prod, Stg), baixe o `GoogleService-Info.plist`
3. Coloque em:
   - `dev/GoogleService-Info.plist` — app **YummyLog for Clinicians Dev** (`.app.dev`)
   - `prod/GoogleService-Info.plist` — app **YummyLog for Clinicians Prd** (`.app`)
   - `stg/GoogleService-Info.plist` — app **YummyLog for Clinicians Stg** (`.app.stg`)

## Estrutura esperada

```
config/
├── dev/
│   └── GoogleService-Info.plist
├── prod/
│   └── GoogleService-Info.plist
└── stg/
    └── GoogleService-Info.plist
```
