import axios from "axios";

export type SwitchbotStatusBody = {
  deviceId: string;
  deviceType: string;
  hubDeviceId: string;
  humidity: number;
  temperature: number;
};

export type SwitchbotStatus = {
  statusCode: number;
  message: string;
  body: SwitchbotStatusBody;
};

const getEndpoint = (deviceId: string) =>
  `https://api.switch-bot.com/v1.0/devices/${deviceId}/status`;

export const fetchSwitchbotStatus = async () => {
  const SWITCHBOT_TOKEN = process.env.SWITCHBOT_TOKEN;
  if (!SWITCHBOT_TOKEN) {
    throw new Error("SWITCHBOT_TOKEN is not defined");
  }

  const deviceIds = [
    process.env.SWITCHBOT_DEVICE_1,
    process.env.SWITCHBOT_DEVICE_2,
    process.env.SWITCHBOT_DEVICE_3,
  ] as const;

  if (!deviceIds.every((v): v is string => typeof v === "string")) {
    throw new Error("SWITCHBOT_DEVICE_* is not set");
  }

  // FIXME: 型キャスト
  const promises = deviceIds.map((deviceId: string) =>
    axios
      .get<SwitchbotStatus>(getEndpoint(deviceId), {
        headers: { Authorization: SWITCHBOT_TOKEN },
      })
      .then((v) => v.data),
  );

  const res = await Promise.all(promises);

  // 正常に取得できたか
  if (!res.every((v) => v.message === "success")) {
    throw new Error("Switchbot API error");
  }

  // body のみ返す
  return res.map((v) => v.body);
};
