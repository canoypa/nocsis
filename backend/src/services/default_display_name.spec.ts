import { describe, expect, it } from "vitest";
import { defaultDisplayName } from "./display_service.js";

describe("defaultDisplayName", () => {
  it("使われていない一番小さい番号を付けること", () => {
    expect(defaultDisplayName([])).toBe("ディスプレイ 1");
    expect(defaultDisplayName(["ディスプレイ 1", "ディスプレイ 3"])).toBe(
      "ディスプレイ 2",
    );
  });

  it("ほかの名前は数えないこと", () => {
    expect(
      defaultDisplayName(["前方", "ディスプレイ 1 横", "ディスプレイ"]),
    ).toBe("ディスプレイ 1");
  });
});
