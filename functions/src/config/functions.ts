import { setGlobalOptions } from "firebase-functions/options";

// firebase-tools は関数定義を読み込むとき GCLOUD_PROJECT を渡し、デプロイ時に
// 同じ変数をサービスの環境変数へ焼き込む。よってプロジェクト ID をコードに
// 書かずに済む。
//
// このモジュールは実行時にも評価されるため、変数を取れないと全関数が起動時に
// 落ちる。実際には GCLOUD_PROJECT だけで足りているが、代償が大きいので他の
// 名前も見る。
const project =
  process.env.GCLOUD_PROJECT ??
  process.env.GOOGLE_CLOUD_PROJECT ??
  process.env.GCP_PROJECT;

if (!project) {
  throw new Error("GCLOUD_PROJECT is not set");
}

setGlobalOptions({
  // 末尾を @ で止める省略形は使わない。Cloud Functions のデプロイでは補完
  // されるが、宣言したシークレットへのアクセス付与では補完されず、生の値が
  // setIamPolicy に渡って "Invalid service account" で落ちる。
  //
  // 個別の関数定義ではなくここで指定するのは、後から追加した関数が指定漏れで
  // デフォルトの compute SA（roles/editor）に落ちるのを防ぐため。
  serviceAccount: `functions-runtime@${project}.iam.gserviceaccount.com`,
});
