import { describe, expect, it, vi } from "vitest";
import { WeatherName } from "~/types/weather.js";
import now from "./now.js";

vi.mock("../../../core/weather/fetchWeather.js", () => {
  return {
    fetchWeather: vi.fn().mockResolvedValue({
      current: { temp: 25 },
      hourly: [
        { temp: 0, pop: 0.0, weather: [{ id: 235 }] },
        { temp: 1, pop: 0.1, weather: [{ id: 600 }] },
        { temp: 2, pop: 0.2, weather: [{ id: 701 }] },
        { temp: 3, pop: 0.3, weather: [{ id: 800 }] },
        { temp: 4, pop: 0.4, weather: [{ id: 803 }] },
        { temp: 5, pop: 0.5, weather: [{ id: 803 }] },
        { temp: 6, pop: 0.6, weather: [{ id: 803 }] },
        { temp: 7, pop: 0.7, weather: [{ id: 803 }] },
        { temp: 8, pop: 0.8, weather: [{ id: 803 }] },
        { temp: 9, pop: 0.9, weather: [{ id: 803 }] },
      ],
    }),
  };
});

describe("now", () => {
  it("should return the correct weather data", async () => {
    const data = await now();

    expect(data.current.temp).toBe(25);
    expect(data.current.name).toBe(WeatherName.Rain);

    expect(data.threeHour.length).toBe(3);
    expect(data.threeHour[0]).toBe(WeatherName.Snow);
    expect(data.threeHour[1]).toBe(WeatherName.Atmosphere);
    expect(data.threeHour[2]).toBe(WeatherName.Clear);

    expect(data.hourly.temp.length).toBe(9);
    expect(data.hourly.temp.at(0)).toBe(0);
    expect(data.hourly.temp.at(-1)).toBe(8);

    expect(data.hourly.pop.length).toBe(9);
    expect(data.hourly.pop.at(0)).toBe(0.0);
    expect(data.hourly.pop.at(-1)).toBe(0.8);
  });
});
