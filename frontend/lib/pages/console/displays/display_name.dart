/// backend は UTF-16 の長さで数える。TextField の maxLength は書記素で数えるので合わない
bool isValidDisplayName(String name) {
  final trimmed = name.trim();
  return trimmed.isNotEmpty && trimmed.length <= 50;
}
