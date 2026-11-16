#!/usr/bin/env bash
# plan ファイルから「どのリソースをどう変えるか」だけを Markdown で出す。
# 属性の値は出さない (公開リポジトリのログに残るため)。
set -euo pipefail

PLAN=${1:?plan ファイルを渡す}
TITLE=${2:-plan}

echo "### $TITLE"
echo
terraform show -json "$PLAN" | jq -r '
  [.resource_changes[]?
    | select(.change.actions != ["no-op"] or .change.importing != null)
    | {address, actions: ((if .change.importing != null then ["import"] else [] end)
        + (.change.actions | map(select(. != "no-op"))))}] as $changes
  | if ($changes | length) == 0 then "変更なし"
    else ($changes[] | "- `\(.actions | join("/"))` \(.address)")
    end'
echo
