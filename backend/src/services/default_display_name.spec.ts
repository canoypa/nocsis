import { describe, expect, it } from "vitest";
import { defaultDisplayName } from "./display_service.js";

describe("defaultDisplayName", () => {
  it("使われていない一番小さい番号を付けること", () => {
    expect(defaultDisplayName([])).toBe("ディスプレイ 1");
    expect(defaultDisplayName(["ディスプレイ 1", "ディスプレイ 3"])).toBe(
      "ディスプレイ 2",
    );
  });

  it("全角や空白の揺れも、同じ番号として数えること", () => {
    expect(
      defaultDisplayName([
        "ディスプレイ１",
        "ディスプレイ2",
        "ディスプレイ　3",
        "ディスプレイ 04",
      ]),
    ).toBe("ディスプレイ 5");
  });

  it("ほかの名前は数えないこと", () => {
    expect(
      defaultDisplayName(["前方", "ディスプレイ 1 横", "ディスプレイ"]),
    ).toBe("ディスプレイ 1");
  });
});
