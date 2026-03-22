fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

### platform_name

```sh
[bundle exec] fastlane platform_name
```



### flavor

```sh
[bundle exec] fastlane flavor
```



### firebase_distribution_notification

```sh
[bundle exec] fastlane firebase_distribution_notification
```



### upload_store_notification

```sh
[bundle exec] fastlane upload_store_notification
```



### clean_project

```sh
[bundle exec] fastlane clean_project
```



### flutter_build

```sh
[bundle exec] fastlane flutter_build
```



### increment_app_build_number

```sh
[bundle exec] fastlane increment_app_build_number
```



### build_ios_and_export_ipa

```sh
[bundle exec] fastlane build_ios_and_export_ipa
```



### upload_crashlytics_symbols

```sh
[bundle exec] fastlane upload_crashlytics_symbols
```

Upload Dart obfuscation symbols to Firebase Crashlytics (prod only)

### upload_sentry_symbols

```sh
[bundle exec] fastlane upload_sentry_symbols
```

Upload Dart debug symbols to Sentry (prod only)

### uploading_firebase_distribution

```sh
[bundle exec] fastlane uploading_firebase_distribution
```



### connect_app_store

```sh
[bundle exec] fastlane connect_app_store
```



### upload_store

```sh
[bundle exec] fastlane upload_store
```



### update_gem

```sh
[bundle exec] fastlane update_gem
```



### rematch

```sh
[bundle exec] fastlane rematch
```

Download provisioning profiles

### certificates

```sh
[bundle exec] fastlane certificates
```

Download certificates and profiles from repo (readonly). Run from ios/: fastlane certificates

### match_init

```sh
[bundle exec] fastlane match_init
```

Create and push certs/profiles for clinicians app (first-time setup)

----


## iOS

### ios dev

```sh
[bundle exec] fastlane ios dev
```

Build an ipa

### ios prod

```sh
[bundle exec] fastlane ios prod
```



### ios certificates

```sh
[bundle exec] fastlane ios certificates
```



----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
