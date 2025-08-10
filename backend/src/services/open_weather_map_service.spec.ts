import { http, HttpResponse } from "msw";
import { setupServer } from "msw/node";
import {
  afterAll,
  beforeAll,
  beforeEach,
  describe,
  expect,
  it,
  vi,
} from "vitest";
import { fetchWeather } from "./open_weather_map_service.js";
import { fetchSecret } from "./secret_manager_service.js";

// Secret Manager Service をモック
vi.mock("./secret_manager_service.js", () => ({
  fetchSecret: vi.fn(),
}));

const mockFetchSecret = vi.mocked(fetchSecret);

describe("fetchWeather", () => {
  const handlers = [
    http.get("https://api.openweathermap.org/data/2.5/weather", () => {
      return HttpResponse.json(
        {
          weather: [{ id: 1, main: "Clear" }],
          main: { temp: 25 },
        },
        { status: 200 },
      );
    }),
    http.get("https://api.openweathermap.org/data/2.5/forecast", () => {
      return HttpResponse.json(
        {
          list: [
            {
              main: { temp: 26 },
              pop: 0.1,
              weather: [{ id: 2, main: "Rain" }],
            },
            {
              main: { temp: 27 },
              pop: 0.2,
              weather: [{ id: 3, main: "Snow" }],
            },
          ],
        },
        { status: 200 },
      );
    }),
  ];
  const server = setupServer(...handlers);

  beforeAll(() => {
    server.listen();

    return () => {
      server.resetHandlers();
    };
  });

  beforeEach(() => {
    // モックを確実に設定（他のテストによる汚染を防ぐため）
    mockFetchSecret.mockResolvedValue("dummy_token");
  });

  afterAll(() => {
    server.close();
  });

  it("気象情報のデータを取得できること", async () => {
    const spyFetch = vi.spyOn(global, "fetch");

    const result = await fetchWeather({ lat: 10, lon: 20 });

    const calls = spyFetch.mock.calls;

    const firstUrl = calls[0][0].toString();
    expect(firstUrl).toContain("appid=dummy_token");
    expect(firstUrl).toContain("lat=10");
    expect(firstUrl).toContain("lon=20");
    expect(firstUrl).toContain("units=metric");

    const secondUrl = calls[1][0].toString();
    expect(secondUrl).toContain("appid=dummy_token");
    expect(secondUrl).toContain("lat=10");
    expect(secondUrl).toContain("lon=20");
    expect(secondUrl).toContain("units=metric");
    expect(secondUrl).toContain("cnt=8");

    expect(result).toEqual({
      current: { temp: 25, weather: [{ id: 1, main: "Clear" }] },
      hourly: [
        { temp: 26, pop: 0.1, weather: [{ id: 2, main: "Rain" }] },
        { temp: 27, pop: 0.2, weather: [{ id: 3, main: "Snow" }] },
      ],
    });
  });

  it("APIレスポンスが500の場合", async () => {
    server.use(
      http.get("https://api.openweathermap.org/data/2.5/weather", () => {
        return HttpResponse.json(
          {
            cod: "500",
            message: "Internal Server Error",
          },
          { status: 500 },
        );
      }),
    );
    await expect(fetchWeather({ lat: 1, lon: 1 })).rejects.toThrow(
      "Failed to fetch weather data",
    );
  });
});
