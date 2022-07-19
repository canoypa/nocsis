import { getMessaging, getToken, onMessage } from "firebase/messaging";
import { firebaseApp } from "./firebase_app";

if (typeof window !== "undefined" && Notification.permission === "granted") {
  const messaging = getMessaging(firebaseApp);
  getToken(messaging, {
    vapidKey:
      "BMMS-Nx5-LnQgHOMPFAoAvXPpYCeEgHZE3BZCXue2W_JNuSUM3F3Vr2MlEzryLuyYSI2lZMeq5NC7Mh4F39bjxg",
  });

  onMessage(messaging, (payload) => {
    console.log(payload);

    // 更新要求メッセージが来ればリロード
    if (
      payload.notification?.title === "SYSTEM_NOTIFICATION" &&
      payload.data?.NEED_RELOAD === "true"
    ) {
      window.location.reload();
    }
  });
}
