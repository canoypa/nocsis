// @jridgewell/gen-mapping で作った小さなソースマップ。
// dart2js は相対パス、wasm は CI の絶対パスでソースを書くので、それに合わせている。

/** main.dart.js:10:5 → lib/main.dart:26、main.dart.js:20:9 → Flutter の framework.dart */
export const jsSourceMap = {
  version: 3,
  file: "main.dart.js",
  names: ["deepFunctionThatFails", "StatelessElement.build"],
  sources: [
    "../../../lib/main.dart",
    "/opt/flutter/packages/flutter/lib/src/widgets/framework.dart",
  ],
  mappings: ";;;;;;;;;IAyBcA;;;;;;;;;;QCyvLkCC",
};

/** オフセット 0x100 → lib/pages/home.dart:42、0x200 → go_router (pub のパッケージ) */
export const wasmSourceMap = {
  version: 3,
  file: "main.dart.wasm",
  names: ["build", "push"],
  sources: [
    "file:///home/runner/work/nocsis/nocsis/frontend/lib/pages/home.dart",
    "file:///home/runner/.pub-cache/hosted/pub.dev/go_router-18.1.1/lib/src/router.dart",
  ],
  mappings: "gQAyCMA,gQChCJC",
};
