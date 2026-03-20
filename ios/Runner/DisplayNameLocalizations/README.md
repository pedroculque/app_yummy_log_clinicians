# Nome do app no launcher (iOS)

Pastas `prod`, `dev`, `stg` espelham o flavor (`Debug-production` → `prod`, etc.).

Em cada uma há `en.lproj`, `pt.lproj`, `es.lproj` com `InfoPlist.strings` e a chave `CFBundleDisplayName`.

O target **Runner** copia o conjunto certo na fase de build **Copy Localized Display Name** (depois de **Resources**).

O `Info.plist` principal continua com `$(FLAVOR_APP_NAME)` em inglês como fallback; os `.strings` por idioma sobrescrevem o nome exibido conforme o idioma do sistema.

O texto do nome é o mesmo em **prod / dev / stg** (sem prefixo de ambiente no rótulo); o flavor fica visível só nos **ícones** (DEV/STG) e no `applicationId`/bundle.

Rótulos por idioma: **en** `Yummy Clinicians`, **pt** `Yummy Clínicos`, **es** `Yummy Clínicos`.
