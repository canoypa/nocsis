import 'package:chopper/chopper.dart';

/// ビルドした commit。`flutter run` など、CI 以外のビルドでは空。
const buildCommit = String.fromEnvironment('BUILD_COMMIT');

/// どの版の画面からのリクエストかを backend のログで数えるため、ビルドした commit を付ける
Interceptor clientCommitInterceptor(String commit) =>
    HeadersInterceptor({if (commit.isNotEmpty) 'X-Client-Commit': commit});
