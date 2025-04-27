import * as slackModule from "@slack/web-api";
import { DateTime } from "luxon";
import { type MockedObject, afterEach, describe, expect, it, vi } from "vitest";
import * as fetchCalendarModule from "~/core/calendar.js";
import * as fetchCountdownEventsModule from "~/core/events/countdown_event.js";
import * as fetchSecretModule from "~/services/fetch_secret.js";
import { notifyEventPerGroup } from "./notify_event_per_group.js";

describe("notifyDayDutyPerGroup", () => {
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

    const postMessage = vi.fn().mockResolvedValue({});
    const mockedSlackWebClient = {
      chat: { postMessage },
    } as unknown as MockedObject<slackModule.WebClient>;
    vi.spyOn(slackModule, "WebClient").mockImplementation(
      () => mockedSlackWebClient,
    );

    const date = DateTime.local(2025, 1, 1);
    await notifyEventPerGroup(group, date);

    expect(postMessage).toBeCalledTimes(1);
    expect(postMessage).toBeCalledWith({
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

      const postMessage = vi.fn();
      const mockedSlackWebClient = {
        chat: { postMessage },
      } as unknown as MockedObject<slackModule.WebClient>;
      vi.spyOn(slackModule, "WebClient").mockImplementation(
        () => mockedSlackWebClient,
      );

      const date = DateTime.local(2025, 1, 1);
      await notifyEventPerGroup(group, date);

      expect(postMessage).toBeCalledTimes(0);
    });
  });
});
