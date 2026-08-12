# AGENTS.md

<!--
ここは毎セッション全文が読み込まれる。書くのは、どのディレクトリを触っても真である前提だけ。
特定ディレクトリの規約は .github/instructions/ に置き、対象パスを frontmatter で絞る。

このファイルが正で、CLAUDE.md と .github/copilot-instructions.md はここへの symlink
（Copilot code review は AGENTS.md を読む保証がないため、あちらの名前でも置いてある）。
.claude/rules/*.md も .github/instructions/*.instructions.md への symlink。
.github/instructions/ の frontmatter に applyTo（Copilot）と paths（Claude Code）を併記して
あるのは、同じ1ファイルを両方に読ませるため。パターンを変えるときは両方を直す。
-->

**日本語で書く。** コメント・コミットメッセージ・PR・レビューのすべてが対象。

**pnpm workspace ではない。** ルート・`backend`・`functions` がそれぞれ独立した pnpm プロジェクトで、lockfile も tsconfig も別。作業するディレクトリで `pnpm install` する。

**backend / functions のテストは Firestore エミュレータに繋がる。** 各プロジェクトの `pnpm run test` は `firebase emulators:exec` 経由なので単体で完結する。1ファイルだけ回すときは、ルートで `pnpm run emulators:start` を起動したまま `pnpm vitest run <file>` する。

**`development → main` のリリース PR は push で自動生成される。** 手で作らない。`main` への push が本番デプロイを起こす。
