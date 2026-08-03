import { setGlobalOptions } from "firebase-functions/options";

setGlobalOptions({
  // 末尾の @ はデプロイ時にプロジェクト ID で補完される。プロジェクト ID を
  // ここに書かないため。@ を含まない裸の名前は firebase-tools が拒否する。
  //
  // 個別の関数定義ではなくここで指定するのは、後から追加した関数が指定漏れで
  // デフォルトの compute SA（roles/editor）に落ちるのを防ぐため。
  serviceAccount: "functions-runtime@",
});
