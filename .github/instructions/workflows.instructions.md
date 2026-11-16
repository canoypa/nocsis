---
applyTo: ".github/workflows/**"
paths:
  - ".github/workflows/**"
---

# GitHub Actions

破っても CI が通ってしまう前提が3つある。どれも該当箇所のコメントに理由が書いてあるので、編集・複製の前にそこを読む。

## build ジョブに environment を宣言しない

`reusable-build_*.yml` が `environment` を持つと、その OIDC トークンが `attribute.environment` に束縛された `wlif-deploy` を引けるようになる。つまりビルドジョブがデプロイ権限に届く。両者を分ける境界はここにしかない。

その結果、ビルドの向き先は environment の変数から解決できない。呼び出し元が入力で渡し、渡された向き先とデプロイ先が一致しているかはデプロイ側の `Verify image target` / `Verify build target` が突き合わせる。

## デプロイ経路自身が lint / test を待つ

`deploy_prod.yml` / `deploy_stg.yml` の `needs` から lint / test を外さない。ruleset の required status check は admin が bypass できるうえ、`workflow_dispatch` は PR を経由しない。「lint / test を通ったものだけが本番に出る」をリポジトリ内で保証できるのは、この `needs` だけ。

staging は本番と同じ経路を先に通すためのものなので、両者のゲートがずれると staging の意味が無くなる。

## fork の PR のコードを、このリポジトリの権限で動かさない

PR から起動するトリガーは `pull_request` だけにしている。public リポジトリの `pull_request` なら、fork の PR のジョブには secret も OIDC トークンも渡らず、`GITHUB_TOKEN` も読み取り専用になる (private にして fork への secret 送信を有効にすると崩れる)。Preview へのデプロイ (`deploy_preview.yml` / `cleanup_preview.yml`) が `environment: Preview` と `wlif-deploy` を引けるのも、WIF の条件や `wlif-build` / `tf-plan` の束縛も、この前提の上にある。

`pull_request_target` は PR のベースブランチ、`workflow_run` と `issue_comment` は既定ブランチ (`development`) のワークフローで動き、fork の PR が起点でも secret と OIDC を受け取れる。これらを足すなら、PR のコード・artifact・出力を checkout したり実行したりしない。PR のタイトル・ブランチ名・コメント本文など、外の人が書ける値を `run:` に `${{ }}` で埋め込まない (そのままシェルとして動く)。PR にコメントを書きたいなど、書き込み権限が欲しいだけの理由でも足さない。
