import 'package:analyzer/dart/element/element.dart';

const _packages = {'flutter', 'material_ui', 'cupertino_ui'};

bool isFromFlutter(Element element) {
  final uri = element.library?.uri;
  return uri != null &&
      uri.isScheme('package') &&
      _packages.contains(uri.pathSegments.first);
}
