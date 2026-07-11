/**
 * サインアップ許可リスト（environment/allowed_emails.value）に対して
 * email がいずれかのパターンに一致するか判定する。
 *
 * value の各要素は "^...$" で完全一致にアンカーされた正規表現文字列で
 * あることを前提とする。アンカーされていないパターンは部分一致による
 * バイパス（例: "^user@example\\.com$" のつもりが "user@example\\.com"
 * のみだと "user@example.com.attacker.com" にもマッチしてしまう）の
 * 原因になるため、アンカーされていないパターンは不正として拒否する。
 *
 * patterns が配列でない・空・不正な値（文字列でない、アンカーされて
 * いない、正規表現として不正なパターン）を含む場合は、意図しない許可
 * を避けるため false を返す（fail-closed）。
 */
export const isAllowedEmail = (
  email: string | undefined,
  patterns: unknown,
): boolean => {
  if (!Array.isArray(patterns) || patterns.length === 0) {
    return false;
  }

  let allowedPatterns: RegExp[];
  try {
    allowedPatterns = patterns.map((pattern) => {
      if (typeof pattern !== "string") {
        throw new Error("invalid pattern");
      }
      if (!pattern.startsWith("^") || !pattern.endsWith("$")) {
        throw new Error("pattern is not anchored");
      }
      return new RegExp(pattern);
    });
  } catch {
    return false;
  }

  return !!email && allowedPatterns.some((regexp) => regexp.test(email));
};
