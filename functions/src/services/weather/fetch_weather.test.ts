import { http, HttpResponse } from "msw";
import { setupServer } from "msw/node";
import { afterEach, beforeEach, describe, expect, it } from "vitest";
import { fetchWeather } from "./fetch_weather.js";

describe("now", () => {
  const server = setupServer(
    http.get("https://api.openweathermap.org/data/2.5/weather", () => {
      return HttpResponse.json({
        weather: [{ id: 25 }],
        main: { temp: 25 },
      });
    }),
    http.get("https://api.openweathermap.org/data/2.5/forecast", () => {
      return HttpResponse.json({
        list: [{ main: { temp: 1 }, pop: 2.0, weather: [{ id: 235 }] }],
      });
    }),
  );

  beforeEach(() => {
    process.env.OPENWEATHERMAP_TOKEN = "dummy";

    server.listen({ onUnhandledRequest: "error" });
  });

  afterEach(() => {
    process.env.OPENWEATHERMAP_TOKEN = "";

    server.close();
    server.resetHandlers();
  });

  it("should return the correct weather data", async () => {
    const data = await fetchWeather({ lat: "99", lon: "99" });

    expect(data).toEqual({
      current: {
        temp: 25,
        weather: [{ id: 25 }],
      },
      hourly: [
        {
          temp: 1,
          pop: 2.0,
          weather: [{ id: 235 }],
        },
      ],
    });
  });
});
