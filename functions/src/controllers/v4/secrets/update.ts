import { SecretManagerServiceClient } from "@google-cloud/secret-manager";
import { getFirestore } from "firebase-admin/firestore";
import { logger } from "firebase-functions";
import { type CallableRequest, HttpsError } from "firebase-functions/https";
import { firebaseApp } from "~/client/firebaseApp.js";

type Data = {
  groupId: string;
  key: "slack_token";
  value: string;
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
  const secretManager = new SecretManagerServiceClient();

  if (!request.auth) {
    throw new HttpsError(
      "unauthenticated",
      "You must be authenticated to use this function",
    );
  }

  const userId = request.auth.uid;
  const { groupId, key, value } = request.data;

  const isUserJoinedGroup = await checkUserJoinedGroup(userId, groupId);
  if (!isUserJoinedGroup) {
    throw new HttpsError(
      "permission-denied",
      "You must join the group to update the group",
    );
  }

  const projectId = firebaseApp.options.projectId;
  if (!projectId) throw new Error("projectId is not found");

  const secretId = `group_${groupId}-${key}`;

  const secretPath = secretManager.secretPath(projectId, secretId);

  // シークレットの存在確認
  const [secretVersions] = await secretManager
    .listSecretVersions({ parent: secretPath })
    .catch((error) => {
      // NOT_FOUND
      if (error.code === 5) {
        return [null];
      }

      if (process.env.NODE_ENV !== "test") logger.error(error);
      throw "Error occurred while getting secret";
    });

  // シークレットまだなければ作成する
  if (!secretVersions) {
    const projectPath = secretManager.projectPath(projectId);

    await secretManager
      .createSecret({
        parent: projectPath,
        secretId: secretId,
        secret: {
          replication: {
            automatic: {},
          },
        },
      })
      .catch((error) => {
        if (process.env.NODE_ENV !== "test") logger.error(error);
        throw "Error occurred while creating secret";
      });
  }

  // シークレットバージョンを追加する
  const [secretVersion] = await secretManager
    .addSecretVersion({
      parent: secretPath,
      payload: {
        data: Buffer.from(value),
      },
    })
    .catch((error) => {
      if (process.env.NODE_ENV !== "test") logger.error(error);
      throw "Error occurred while adding secret version";
    });

  const secretVersionNumber = secretVersion.name?.split("/").pop();
  if (!secretVersionNumber) {
    // これになる状況がわからない
    console.error(secretVersion);
    throw "Error occurred while getting secret version number";
  }

  // シークレットのエイリアスを更新する
  await secretManager
    .updateSecret({
      secret: {
        name: secretPath,
        versionAliases: {
          current: secretVersionNumber,
        },
      },
      updateMask: {
        paths: ["version_aliases"],
      },
    })
    .catch((error) => {
      if (process.env.NODE_ENV !== "test") logger.error(error);
      throw "Error occurred while setting secret version alias";
    });

  // 以前のシークレットバージョンを削除する
  if (secretVersions) {
    for await (const secretVersion of secretVersions) {
      await secretManager
        .destroySecretVersion({
          name: secretVersion.name,
        })
        .catch((error) => {
          // 最悪失敗しても問題ないので正常終了する
          if (process.env.NODE_ENV !== "test") logger.error(error);
        });
    }
  }
};

export default update;
