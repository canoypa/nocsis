import { setGlobalOptions } from "firebase-functions/options";

// firebase-tools は関数定義を読み込むとき GCLOUD_PROJECT を渡す。実行時にも
// 同じ変数が入るため、ここでプロジェクト ID を組み立ててもコードには残らない。
const project = process.env.GCLOUD_PROJECT;

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
