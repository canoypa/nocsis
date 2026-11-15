import 'dart:convert';
import 'dart:io';

import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver(
  writeResponseOnFailure: true,
  responseDataCallback: (data) async {
    if (data != null) {
      stdout.writeln(const JsonEncoder.withIndent('  ').convert(data));
    }
  },
);
