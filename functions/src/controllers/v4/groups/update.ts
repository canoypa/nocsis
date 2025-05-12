import { getFirestore } from "firebase-admin/firestore";
import { type CallableRequest, HttpsError } from "firebase-functions/https";
import * as v from "valibot";
import { firebaseApp } from "~/client/firebaseApp.js";

const minKvSize = <T extends {}>(
  min: number,
  message?: v.ErrorMessage<v.CustomIssue>,
) =>
  v.custom<T>((input) => {
    return (
      input !== null &&
      typeof input === "object" &&
      Object.keys(input).length >= min
    );
  }, message);

const groupSchema = v.pipe(
  v.strictObject({
    name: v.optional(v.string()),

    classes_calendar_id: v.optional(v.string()),
    events_calendar_id: v.optional(v.string()),

    dayduty_start_date: v.optional(v.string()),

    slack_event_channel_id: v.optional(v.string()),

    weather_point: v.optional(
      v.object({
        lat: v.number(),
        lon: v.number(),
      }),
    ),
  }),
  minKvSize(1),
);

type Data = {
  groupId: string;
  data: v.InferInput<typeof groupSchema>;
};

const firestore = getFirestore(firebaseApp);

const checkUserJoinedGroup = async (
  userId: string,
  groupId: string,
): Promise<boolean> => {
  const userJoinedGroupSnapshot = await firestore
    .collection("user_joined_groups")
    .where("user_id", "==", userId)
    .where("group_id", "==", groupId)
    .get();

  return userJoinedGroupSnapshot.size === 1;
};

const update = async (request: CallableRequest<Data>) => {
  if (!request.auth) {
    throw new HttpsError(
      "unauthenticated",
      "You must be authenticated to use this function",
    );
  }

  const userId = request.auth.uid;
  const { groupId, data } = request.data;

  const result = v.safeParse(groupSchema, data);
  if (!result.success) {
    throw new HttpsError("invalid-argument", "The data is invalid");
  }

  const isUserJoinedGroup = await checkUserJoinedGroup(userId, groupId);
  if (!isUserJoinedGroup) {
    throw new HttpsError(
      "permission-denied",
      "You must join the group to update the group",
    );
  }

  const groupRef = firestore.collection("groups").doc(groupId);

  await groupRef.update(result.output);
};

export default update;
