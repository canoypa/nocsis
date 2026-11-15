// 使い方: エミュレータを起動したまま backend で `tsx e2e/seed.ts`
import { auth, firestore } from "../src/clients/firebase.js";

// frontend/integration_test/app_test.dart が同じ値でログインし、表示を確かめる。
const user = await auth.createUser({
  email: "e2e@example.com",
  password: "e2e-password",
});

const groupId = "e2e_group";
await firestore
  .collection("groups")
  .doc(groupId)
  .set({
    name: "E2E Group",
    // e2e/fake_external_apis.ts がこの ID ごとに偽の予定を返す。
    classes_calendar_id: "classes",
    events_calendar_id: "events",
    dayduty_start_date: "2000-01-01",
    slack_event_channel_id: "slack",
    weather_point: { lat: 35.0, lon: 135.0 },
  });
await firestore.collection("user_joined_groups").add({
  user_id: user.uid,
  group_id: groupId,
});
await firestore.collection("classmates").add({
  group_id: groupId,
  role: "student",
  stuNo: 1,
  name: "E2E 太郎",
  email: "taro@example.com",
  slackUserId: "U00000000",
});

// 閉じないと gRPC の接続が残り、プロセスが終わらない。
await firestore.terminate();
