import { DateTime } from "luxon";
import { afterEach, describe, expect, it, vi } from "vitest";
import * as fetchCalendarModule from "~/core/calendar.js";
import * as fetchCountdownEventsModule from "~/core/events/countdown_event.js";
import * as fetchSecretModule from "~/services/fetch_secret.js";
import { notifyEventPerGroup } from "./notify_event_per_group.js";

const { mockPostMessage } = vi.hoisted(() => ({ mockPostMessage: vi.fn() }));

vi.mock("@slack/web-api", () => ({
  WebClient: class {
    chat = { postMessage: mockPostMessage };
  },
}));

describe("notifyEventPerGroup", () => {
  const group = {
    id: "group_1",
    events_calendar_id: "events_calendar_1",
    slack_event_channel_id: "slack_event_channel_1",
  };

  const event = {
    summary: "テストイベント1",
    start: { dateTime: "2025-01-01T00:00:00+09:00" },
    end: { dateTime: "2025-01-01T01:00:00+09:00" },
  };

  const countdownEvent = {
    summary: "テストイベント2",
    start: { dateTime: "2025-01-01T00:00:00+09:00" },
    end: { dateTime: "2025-01-01T01:00:00+09:00" },
  };

  afterEach(() => {
    vi.resetAllMocks();
  });

  it("通知されること", async () => {
    vi.spyOn(fetchSecretModule, "fetchSecret").mockResolvedValue(
      "dummy_slack_token",
    );
    vi.spyOn(fetchCalendarModule, "fetchCalendar").mockResolvedValue({
      items: [event],
    });
    vi.spyOn(
      fetchCountdownEventsModule,
      "fetchCountdownEvents",
    ).mockResolvedValue({
      items: [countdownEvent],
    });
    mockPostMessage.mockResolvedValue({});

    const date = DateTime.local(2025, 1, 1);
    await notifyEventPerGroup(group, date);

    expect(mockPostMessage).toHaveBeenCalledTimes(1);
    expect(mockPostMessage).toHaveBeenCalledWith({
      channel: group.slack_event_channel_id,
      username: "イベントBot",
      icon_emoji: ":date:",
      text: "テストイベント1",
      blocks: expect.arrayContaining([]),
      unfurl_links: false,
      unfurl_media: false,
    });
  });

  describe("イベントがない場合", () => {
    it("通知されないこと", async () => {
      vi.spyOn(fetchSecretModule, "fetchSecret").mockResolvedValue(
        "dummy_slack_token",
      );
      vi.spyOn(fetchCalendarModule, "fetchCalendar").mockResolvedValue({
        items: [],
      });
      vi.spyOn(
        fetchCountdownEventsModule,
        "fetchCountdownEvents",
      ).mockResolvedValue({
        items: [],
      });

      const date = DateTime.local(2025, 1, 1);
      await notifyEventPerGroup(group, date);

      expect(mockPostMessage).toHaveBeenCalledTimes(0);
    });
  });
});
