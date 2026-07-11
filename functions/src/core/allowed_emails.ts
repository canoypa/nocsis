/**
 * サインアップ許可リスト（environment/allowed_emails.value）に対して
 * email がいずれかのパターンに一致するか判定する。
 *
 * patterns が配列でない・空・不正な値（文字列でないパターンや不正な
 * 正規表現）を含む場合は、意図しない許可を避けるため false を返す
 * （fail-closed）。
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
      // 部分一致を避けるため完全一致にアンカーする
      return new RegExp(`^(?:${pattern})$`);
    });
  } catch {
    return false;
  }

  return !!email && allowedPatterns.some((regexp) => regexp.test(email));
};
