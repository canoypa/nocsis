---
applyTo: ".github/workflows/**"
paths:
  - ".github/workflows/**"
---

# GitHub Actions

破っても CI が通ってしまう前提が2つある。どちらも該当箇所のコメントに理由が書いてあるので、編集・複製の前にそこを読む。

## build ジョブに environment を宣言しない

`_build_*.yml` が `environment` を持つと、その OIDC トークンが `attribute.environment` に束縛された `wlif-deploy` を引けるようになる。つまりビルドジョブがデプロイ権限に届く。両者を分ける境界はここにしかない。

その結果、ビルドの向き先は environment の変数から解決できない。呼び出し元が入力で渡し、渡された向き先とデプロイ先が一致しているかはデプロイ側の `Verify image target` / `Verify build target` が突き合わせる。

## デプロイ経路自身が lint / test を待つ

`deploy_prod.yml` / `deploy_stg.yml` の `needs` から lint / test を外さない。ruleset の required status check は admin が bypass できるうえ、`workflow_dispatch` は PR を経由しない。「lint / test を通ったものだけが本番に出る」をリポジトリ内で保証できるのは、この `needs` だけ。

staging は本番と同じ経路を先に通すためのものなので、両者のゲートがずれると staging の意味が無くなる。
