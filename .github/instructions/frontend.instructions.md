---
applyTo: "frontend/**"
paths:
  - "frontend/**"
---

# frontend（Flutter Web）

## Firestore に直接アクセスしない

`firestore.rules` はクライアント経路を全拒否し、backend と functions が Admin SDK で迂回する前提。必要なデータは Firestore を直接読むのではなく、backend の REST API に生やす（Hosting の `/api/**` が Cloud Run に rewrite される）。

## 生成物が git に入っていない

`.g.dart` と `lib/generated/` は ignore されている。`flutter pub get` の後に `flutter pub run build_runner build` を回すまで、analyze もテストも通らない。riverpod のプロバイダ、go_router のルート、json_serializable のモデル、chopper の API クライアントはすべてこれで生える。足したら回し直す。

入力の `swagger/api.json` は backend が生成したものなので、ここを直しても次の生成で戻る。

## `flutter analyze` だけでは lint が終わらない

riverpod_lint の指摘は `flutter pub run custom_lint` にしか出ない。`analysis_options.yaml` の `plugins:` に custom_lint を書いてあるが、`flutter analyze` はそれを評価しないため。CI は `dart format --output=none --set-exit-if-changed .` / `flutter analyze` / `flutter pub run custom_lint` の3本を回す。

## 実行には dart_defines が要る

`flutter run --dart-define-from-file=dart_defines/build.json`。このファイルは ignore 済み。`firebase_options.dart` は値を `String.fromEnvironment` で読む形に手で書き換えてあるので、`flutterfire configure` を実行すると値が直接書き戻されてこの仕組みが壊れる。
