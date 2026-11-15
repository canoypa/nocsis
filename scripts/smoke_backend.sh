#!/usr/bin/env bash
# 使い方: firebase emulators:exec --only auth,firestore --project demo-nocsis \
#           'bash scripts/smoke_backend.sh'
set -euo pipefail

BACKEND_URL="${BACKEND_URL:-http://127.0.0.1:8080}"
AUTH_URL="http://${FIREBASE_AUTH_EMULATOR_HOST:-127.0.0.1:9099}"
FIRESTORE_URL="http://${FIRESTORE_EMULATOR_HOST:-127.0.0.1:8888}"
PROJECT_ID="${PROJECT_ID:-demo-nocsis}"
ENDPOINT="${BACKEND_URL}/api/v1/users/me/groups"

fail() {
  echo "::error::$*" >&2
  exit 1
}

echo "backend の起動を待つ: ${BACKEND_URL}"
for _ in $(seq 1 30); do
  code=$(curl -s -o /dev/null -w '%{http_code}' "$ENDPOINT" || true)
  [ "$code" != "000" ] && break
  sleep 1
done
[ "$code" != "000" ] || fail "backend が 30 秒以内に起動しませんでした"

echo "未認証のリクエストが 401 になること"
[ "$code" = "401" ] || fail "未認証で ${code} が返りました (期待値 401)"

echo "Auth エミュレータでユーザーを作る"
signup=$(curl -sf -X POST -H 'Content-Type: application/json' \
  -d '{"returnSecureToken":true}' \
  "${AUTH_URL}/identitytoolkit.googleapis.com/v1/accounts:signUp?key=dummy")
id_token=$(jq -er '.idToken' <<<"$signup")
uid=$(jq -er '.localId' <<<"$signup")

echo "Firestore エミュレータにグループと所属を書き込む"
# 本物の ID トークンを使わないのは、firestore.rules がクライアントを全面拒否するため。
# Bearer owner はエミュレータ専用の管理者扱いでルールを迂回する。
firestore_create() {
  curl -sf -X POST -H 'Authorization: Bearer owner' -H 'Content-Type: application/json' \
    -d "$2" \
    "${FIRESTORE_URL}/v1/projects/${PROJECT_ID}/databases/(default)/documents/$1" >/dev/null
}
firestore_create 'groups?documentId=smoke_group' '{
  "fields": {
    "name": {"stringValue": "Smoke Group"},
    "classes_calendar_id": {"stringValue": "classes"},
    "events_calendar_id": {"stringValue": "events"},
    "dayduty_start_date": {"stringValue": "2000-01-01"},
    "slack_event_channel_id": {"stringValue": "slack"},
    "weather_point": {"mapValue": {"fields": {
      "lat": {"doubleValue": 35.0},
      "lon": {"doubleValue": 135.0}
    }}}
  }
}'
firestore_create 'user_joined_groups' "{
  \"fields\": {
    \"user_id\": {\"stringValue\": \"${uid}\"},
    \"group_id\": {\"stringValue\": \"smoke_group\"}
  }
}"

echo "認証付きで参加グループを取得できること"
body=$(curl -s -w '\n%{http_code}' -H "Authorization: Bearer ${id_token}" "$ENDPOINT")
code=$(tail -n1 <<<"$body")
body=$(sed '$d' <<<"$body")
[ "$code" = "200" ] || fail "認証付きで ${code} が返りました: ${body}"
jq -e '.items | length == 1 and .[0].id == "smoke_group" and .[0].weather_point.lat == 35' \
  <<<"$body" >/dev/null || fail "レスポンスが想定と違います: ${body}"

echo "backend のスモークテストに成功しました"
