---
applyTo: "frontend/**"
paths:
  - "frontend/**"
---

# frontend（Flutter Web）

## Firestore に直接アクセスしない

`firestore.rules` はクライアント経路を拒否し、backend と functions が Admin SDK で迂回する前提。必要なデータは Firestore を直接読むのではなく、backend の REST API に生やす（Hosting の `/api/**` が Cloud Run に rewrite される）。

例外は、教室ディスプレイが自分の付与（`role_bindings` の subject が自分）を購読することだけ。登録の解除にすぐ気づくためで、読める範囲はルールで本人の付与に限っている。

## 生成物が git に入っていない

`.g.dart` と `lib/generated/` は ignore されている。`flutter pub get` の後に `flutter pub run build_runner build` を回すまで、analyze もテストも通らない。riverpod のプロバイダ、go_router のルート、json_serializable のモデル、chopper の API クライアントはすべてこれで生える。足したら回し直す。

入力の `swagger/api.json` は backend が生成したものなので、ここを直しても次の生成で戻る。

## 実行には dart_defines が要る

`flutter run --dart-define-from-file=dart_defines/build.json`。このファイルは ignore 済み。`firebase_options.dart` は値を `String.fromEnvironment` で読む形に手で書き換えてあるので、`flutterfire configure` を実行すると値が直接書き戻されてこの仕組みが壊れる。

## ダイアログはルートにする

ブラウザの戻るで閉じられるように、ダイアログは go_router の子ルートにする。例は `lib/routes/settings/settings_top_page_route.dart`。

- ルートの `buildPage` で `DialogPage` を返し、`$parentNavigatorKey` を `rootNavigatorKey` にする
- 開くときは `push` を使う。`go` は後ろの画面ごと作り直すので、開くときのフェードが飛ぶ
- 閉じるときは `closeDialog` を使う。`Navigator.pop` で閉じると、閉じた状態が履歴に積まれ、戻るでまた開く
- 呼び出し元に結果を返せないので、確定の処理はダイアログの中で行う

## 間は spacing でとる

意味のまとまりごとに `Column` / `Row` を分け、同じレベルの要素の間はその `spacing` でとる。要素のあいだに `SizedBox` を挟んで、個別に調整しない。

まとまりどうしの大きめの間は、外側の `spacing` で表す。

## 画面を足したら、ルーター経由でも開く

ウィジェットを直接 pump するテストに加えて、`routerProvider` を通して URL を開き、その URL に留まることを確かめるテストを 1 つ書く (`test/routes/router_test.dart` の `pumpRouter`)。

go_router の子ルートは、親の画面も下に作る。親の `initState` が遷移すると、子の画面がすぐ消える。ウィジェット単体のテストでは、これは見つからない。

## 文字数は見たとおりに数える

入力の上限などで文字数を数えるときは、`characters.length` を使う。`String.length` は UTF-16 の単位なので、絵文字などを多く数える。
