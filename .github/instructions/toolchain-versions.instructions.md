---
applyTo: "mise.toml,**/package.json,frontend/pubspec.yaml,backend/Dockerfile,firebase.json,renovate.json"
paths:
  - "mise.toml"
  - "**/package.json"
  - "frontend/pubspec.yaml"
  - "backend/Dockerfile"
  - "firebase.json"
  - "renovate.json"
---

# ツールチェーンのバージョン

node / pnpm / flutter は同じバージョンが複数ファイルに書かれており、`renovate.json` が束ねて同時に更新している。標準のマネージャが見ない2箇所（Dockerfile の pnpm、firebase.json の runtime）には専用の customManager がある。

書く場所を増やすときは、**Renovate が追える形かを先に確認する**。追えない場所は更新から取り残されて他とずれる。
