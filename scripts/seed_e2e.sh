#!/usr/bin/env bash
# 使い方: firebase emulators:exec --only auth,firestore --project demo-nocsis \
#           'bash scripts/seed_e2e.sh && <E2E を流すコマンド>'
set -euo pipefail

AUTH_URL="http://${FIREBASE_AUTH_EMULATOR_HOST:-127.0.0.1:9099}"
FIRESTORE_URL="http://${FIRESTORE_EMULATOR_HOST:-127.0.0.1:8888}"
PROJECT_ID="${PROJECT_ID:-demo-nocsis}"

signup=$(curl -sf -X POST -H 'Content-Type: application/json' \
  -d '{"email":"e2e@example.com","password":"e2e-password","returnSecureToken":true}' \
  "${AUTH_URL}/identitytoolkit.googleapis.com/v1/accounts:signUp?key=dummy")
uid=$(jq -er '.localId' <<<"$signup")

# 本物の ID トークンを使わないのは、firestore.rules がクライアントを全面拒否するため。
firestore_create() {
  curl -sf -X POST -H 'Authorization: Bearer owner' -H 'Content-Type: application/json' \
    -d "$2" \
    "${FIRESTORE_URL}/v1/projects/${PROJECT_ID}/databases/(default)/documents/$1" >/dev/null
}
firestore_create 'groups?documentId=e2e_group' '{
  "fields": {
    "name": {"stringValue": "E2E Group"},
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
    \"group_id\": {\"stringValue\": \"e2e_group\"}
  }
}"
firestore_create 'classmates' '{
  "fields": {
    "group_id": {"stringValue": "e2e_group"},
    "role": {"stringValue": "student"},
    "stuNo": {"integerValue": "1"},
    "name": {"stringValue": "E2E 太郎"},
    "email": {"stringValue": "taro@example.com"},
    "slackUserId": {"stringValue": "U00000000"}
  }
}'
