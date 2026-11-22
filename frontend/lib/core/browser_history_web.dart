import 'package:web/web.dart' as web;

bool backInBrowserHistory() {
  web.window.history.back();
  return true;
}
