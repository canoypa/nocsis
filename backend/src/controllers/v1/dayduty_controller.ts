import { Hono } from "hono";
import { HTTPException } from "hono/http-exception";
import { describeRoute, resolver, validator } from "hono-openapi";
import { DateTime } from "luxon";
import { z } from "zod";
import {
  type AuthorizedEnv,
  authorize,
  groupOf,
} from "../../authz/middleware.js";
import { firestore } from "../../clients/firebase.js";
import { AppConfig } from "../../config/app_config.js";
import { authentication } from "../../middlewares/authenticate.js";
import {
  daydutyQuerySchema,
  daydutyResponseSchema,
} from "../../resources/v1/dayduty.js";
import { getDaydutyStuNo } from "../../services/dayduty_service.js";

export const daydutRoutes = new Hono<AuthorizedEnv>();

const paramSchema = z
  .object({
    groupId: z.string().meta({ description: "グループのID" }),
  })
  .meta({ description: "日直情報を取得する際のパラメータ" });
type DaydutyResponse = z.infer<typeof daydutyResponseSchema>;

daydutRoutes.get(
  "/:groupId/dayduty",
  describeRoute({
    description: "日直情報を取得する",
    responses: {
      200: {
        description: "Successful response",
        content: {
          "application/json": { schema: resolver(daydutyResponseSchema) },
        },
      },
      400: {
        description: "Bad Request",
      },
      401: {
        description: "Unauthorized",
      },
      403: {
        description: "Forbidden",
      },
      404: {
        description: "Not Found",
      },
      500: {
        description: "Internal Server Error",
      },
    },
    security: [{ bearer: [] }],
  }),
  validator("param", paramSchema),
  authentication,
  authorize("member.read", groupOf("groupId")),
  // 権限の無い相手に、クエリの検証結果 (400) を先に返さない
  validator("query", daydutyQuerySchema),
  async (c) => {
    const groupId = c.req.param("groupId");
    const { date } = c.req.valid("query");

    try {
      // binding が残ったまま、グループが消えていることがある
      const groupSnapshot = await firestore
        .collection("groups")
        .doc(groupId)
        .get();
      if (!groupSnapshot.exists) {
        throw new HTTPException(404, { message: "グループが存在しません。" });
      }

      const targetDate = date
        ? DateTime.fromISO(date, { zone: AppConfig.TIMEZONE })
        : DateTime.now().setZone(AppConfig.TIMEZONE);

      if (!targetDate.isValid) {
        throw new HTTPException(400, {
          message: "日付のフォーマットが正しくありません。",
        });
      }

      // 出席番号取得
      // @types/luxon 3.7.4 で fromISO/now().setZone() の戻り値型が
      // DateTimeMaybeValid から DateTime に簡略化され、isValid による
      // narrowing が効かなくなったため明示的にキャストする
      const stuNo = await getDaydutyStuNo(
        groupId,
        targetDate as DateTime<true>,
      );

      // Classmate 取得
      const classmateSnapshot = await firestore
        .collection("classmates")
        .where("group_id", "==", groupId)
        .where("stuNo", "==", stuNo)
        .select("name")
        .get();

      if (classmateSnapshot.empty) {
        throw new HTTPException(500, {
          message: "学生が見つかりません。",
        });
      }

      const validatedResponse = daydutyResponseSchema.parse(
        classmateSnapshot.docs[0].data(),
      );

      return c.json<DaydutyResponse>(validatedResponse, 200);
    } catch (error) {
      console.error("Error in dayduty controller:", error);
      throw error;
    }
  },
);
