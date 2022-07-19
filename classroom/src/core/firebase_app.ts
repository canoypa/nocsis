import { getApp, getApps, initializeApp } from "firebase/app";

const firebaseConfig = {
  apiKey: "AIzaSyBzIPmQKtoKybxCWpb3ErbQ5ohW4FPCR7g",
  authDomain: "class-clock-40088.firebaseapp.com",
  projectId: "class-clock-40088",
  storageBucket: "class-clock-40088.appspot.com",
  messagingSenderId: "219141289630",
  appId: "1:219141289630:web:6988629faf082890b1ad8f",
  measurementId: "G-KEGZJCNJDX",
};

// fast refresh とかで複数回初期化されるのを防ぐ (必要？)
export const firebaseApp = getApps().length
  ? getApp()
  : initializeApp(firebaseConfig);
