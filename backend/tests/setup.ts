// Firebaseエミュレーターへの接続設定
process.env.FIREBASE_AUTH_EMULATOR_HOST = "localhost:9099";
process.env.FIRESTORE_EMULATOR_HOST = "localhost:8888";

// emulators:exec を通さずに 1 ファイルだけ回すときも、Secret を読むプロジェクトが決まるように
process.env.GCLOUD_PROJECT ??= "demo-nocsis";
