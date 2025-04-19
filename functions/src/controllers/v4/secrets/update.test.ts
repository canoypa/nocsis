import * as secretManagerModule from "@google-cloud/secret-manager";
import { getFirestore } from "firebase-admin/firestore";
import { functionsTest } from "tests/functions_setup.js";
import {
  type MockedObject,
  afterEach,
  beforeEach,
  describe,
  expect,
  it,
  vi,
} from "vitest";
import { firebaseApp } from "~/client/firebaseApp.js";
import * as secrets from "~/controllers/v4/secrets/index.js";

describe("update", () => {
  const wrapped = functionsTest.wrap(secrets.update);

  const mockedListSecretVersions = vi.fn();
  const mockedCreateSecret = vi.fn();
  const mockedAddSecretVersion = vi.fn();
  const mockedUpdateSecret = vi.fn();
  const mockedDestroySecretVersion = vi.fn();

  const mockedSecretManagerServiceClientBase = {
    projectPath: (_: string) => "projects/dummy_project_id",
    secretPath: (_: string, secret_id: string) =>
      `projects/dummy_project_id/secrets/${secret_id}`,
    listSecretVersions: mockedListSecretVersions,
    createSecret: mockedCreateSecret,
    addSecretVersion: mockedAddSecretVersion,
    updateSecret: mockedUpdateSecret,
    destroySecretVersion: mockedDestroySecretVersion,
  } as unknown as MockedObject<secretManagerModule.SecretManagerServiceClient>;

  beforeEach(async () => {
    mockedListSecretVersions.mockResolvedValue([
      [
        {
          name: "projects/project_id/secrets/secret_id/versions/1",
        },
      ],
    ]);
    mockedCreateSecret.mockResolvedValue({});
    mockedAddSecretVersion.mockResolvedValue([
      {
        name: "projects/project_id/secrets/secret_id/versions/2",
      },
    ]);
    mockedUpdateSecret.mockResolvedValue({});
    mockedDestroySecretVersion.mockResolvedValue({});

    vi.spyOn(
      secretManagerModule,
      "SecretManagerServiceClient",
    ).mockImplementation(() => mockedSecretManagerServiceClientBase);

    const firestore = getFirestore(firebaseApp);

    await firestore.collection("user_joined_groups").add({
      user_id: "user_a",
      group_id: "group_id",
    });
  });

  afterEach(() => {
    vi.resetAllMocks();
  });

  it("シークレットバージョンの追加に成功すること", async () => {
    const auth = functionsTest.auth.makeUserRecord({
      uid: "user_a",
    });

    await expect(
      wrapped({
        // @ts-expect-error
        auth,
        data: {
          groupId: "group_id",
          key: "slack_token",
          value: "token",
        },
      }),
    ).resolves.not.toThrowError();

    expect(mockedListSecretVersions).toHaveBeenCalledTimes(1);
    expect(mockedListSecretVersions).toHaveBeenCalledWith({
      parent: "projects/dummy_project_id/secrets/group_group_id-slack_token",
    });

    expect(mockedCreateSecret).toHaveBeenCalledTimes(0);

    expect(mockedAddSecretVersion).toHaveBeenCalledTimes(1);
    expect(mockedAddSecretVersion).toHaveBeenCalledWith({
      parent: "projects/dummy_project_id/secrets/group_group_id-slack_token",
      payload: {
        data: Buffer.from("token"),
      },
    });

    expect(mockedUpdateSecret).toHaveBeenCalledTimes(1);
    expect(mockedUpdateSecret).toHaveBeenCalledWith({
      secret: {
        name: "projects/dummy_project_id/secrets/group_group_id-slack_token",
        versionAliases: {
          current: "2",
        },
      },
      updateMask: {
        paths: ["version_aliases"],
      },
    });

    expect(mockedDestroySecretVersion).toHaveBeenCalledTimes(1);
    expect(mockedDestroySecretVersion).toHaveBeenCalledWith({
      name: "projects/project_id/secrets/secret_id/versions/1",
    });
  });

  describe("認証されていない場合", () => {
    it("エラーになること", async () => {
      // @ts-expect-error
      await expect(wrapped({})).rejects.toThrow(
        "You must be authenticated to use this function",
      );
    });
  });

  describe("ユーザーが所属していないグループを更新しようとした場合", () => {
    it("エラーになること", async () => {
      const auth = functionsTest.auth.makeUserRecord({
        uid: "user_b",
      });

      await expect(
        wrapped({
          // @ts-expect-error
          auth,
          data: {
            groupId: "group_id",
            key: "slack_token",
            value: "token",
          },
        }),
      ).rejects.toThrow("You must join the group to update the group");
    });
  });

  describe("シークレットが存在しない場合", () => {
    it("シークレットが作成され、処理が正常に完了すること", async () => {
      mockedListSecretVersions.mockRejectedValue({
        code: 5,
      });

      const auth = functionsTest.auth.makeUserRecord({
        uid: "user_a",
      });

      await expect(
        wrapped({
          // @ts-expect-error
          auth,
          data: {
            groupId: "group_id",
            key: "slack_token",
            value: "token",
          },
        }),
      ).resolves.not.toThrowError();

      expect(mockedListSecretVersions).toHaveBeenCalledTimes(1);
      expect(mockedListSecretVersions).toHaveBeenCalledWith({
        parent: "projects/dummy_project_id/secrets/group_group_id-slack_token",
      });

      expect(mockedCreateSecret).toHaveBeenCalledTimes(1);
      expect(mockedCreateSecret).toHaveBeenCalledWith({
        parent: "projects/dummy_project_id",
        secretId: "group_group_id-slack_token",
        secret: {
          replication: {
            automatic: {},
          },
        },
      });

      expect(mockedAddSecretVersion).toHaveBeenCalledTimes(1);

      expect(mockedUpdateSecret).toHaveBeenCalledTimes(1);

      expect(mockedDestroySecretVersion).toHaveBeenCalledTimes(0);
    });
  });

  describe("シークレットの取得に失敗した場合", () => {
    it("エラーになること", async () => {
      mockedListSecretVersions.mockRejectedValue(new Error("error"));

      const auth = functionsTest.auth.makeUserRecord({
        uid: "user_a",
      });

      await expect(
        wrapped({
          // @ts-expect-error
          auth,
          data: {
            groupId: "group_id",
            key: "slack_token",
            value: "token",
          },
        }),
      ).rejects.toThrow("Error occurred while getting secret");

      expect(mockedListSecretVersions).toHaveBeenCalledTimes(1);
      expect(mockedListSecretVersions).toHaveBeenCalledWith({
        parent: "projects/dummy_project_id/secrets/group_group_id-slack_token",
      });

      expect(mockedCreateSecret).toHaveBeenCalledTimes(0);
      expect(mockedAddSecretVersion).toHaveBeenCalledTimes(0);
      expect(mockedUpdateSecret).toHaveBeenCalledTimes(0);
      expect(mockedDestroySecretVersion).toHaveBeenCalledTimes(0);
    });
  });

  describe("シークレットの作成に失敗した場合", () => {
    it("エラーになること", async () => {
      mockedListSecretVersions.mockRejectedValue({
        code: 5,
      });
      mockedCreateSecret.mockRejectedValue(new Error("error"));

      const auth = functionsTest.auth.makeUserRecord({
        uid: "user_a",
      });

      await expect(
        wrapped({
          // @ts-expect-error
          auth,
          data: {
            groupId: "group_id",
            key: "slack_token",
            value: "token",
          },
        }),
      ).rejects.toThrow("Error occurred while creating secret");

      expect(mockedListSecretVersions).toHaveBeenCalledTimes(1);
      expect(mockedListSecretVersions).toHaveBeenCalledWith({
        parent: "projects/dummy_project_id/secrets/group_group_id-slack_token",
      });

      expect(mockedCreateSecret).toHaveBeenCalledTimes(1);
      expect(mockedCreateSecret).toHaveBeenCalledWith({
        parent: "projects/dummy_project_id",
        secretId: "group_group_id-slack_token",
        secret: {
          replication: {
            automatic: {},
          },
        },
      });

      expect(mockedAddSecretVersion).toHaveBeenCalledTimes(0);
      expect(mockedUpdateSecret).toHaveBeenCalledTimes(0);
      expect(mockedDestroySecretVersion).toHaveBeenCalledTimes(0);
    });
  });

  describe("シークレットバージョンの追加に失敗した場合", () => {
    it("エラーになること", async () => {
      mockedAddSecretVersion.mockRejectedValue(new Error("error"));

      const auth = functionsTest.auth.makeUserRecord({
        uid: "user_a",
      });

      await expect(
        wrapped({
          // @ts-expect-error
          auth,
          data: {
            groupId: "group_id",
            key: "slack_token",
            value: "token",
          },
        }),
      ).rejects.toThrow("Error occurred while adding secret version");

      expect(mockedListSecretVersions).toHaveBeenCalledTimes(1);
      expect(mockedListSecretVersions).toHaveBeenCalledWith({
        parent: "projects/dummy_project_id/secrets/group_group_id-slack_token",
      });

      expect(mockedCreateSecret).toHaveBeenCalledTimes(0);

      expect(mockedAddSecretVersion).toHaveBeenCalledTimes(1);
      expect(mockedAddSecretVersion).toHaveBeenCalledWith({
        parent: "projects/dummy_project_id/secrets/group_group_id-slack_token",
        payload: {
          data: Buffer.from("token"),
        },
      });

      expect(mockedUpdateSecret).toHaveBeenCalledTimes(0);
      expect(mockedDestroySecretVersion).toHaveBeenCalledTimes(0);
    });
  });

  describe("シークレットエイリアスの更新に失敗した場合", () => {
    it("エラーになること", async () => {
      mockedUpdateSecret.mockRejectedValue(new Error("error"));

      const auth = functionsTest.auth.makeUserRecord({
        uid: "user_a",
      });

      await expect(
        wrapped({
          // @ts-expect-error
          auth,
          data: {
            groupId: "group_id",
            key: "slack_token",
            value: "token",
          },
        }),
      ).rejects.toThrow("Error occurred while setting secret version alias");

      expect(mockedListSecretVersions).toHaveBeenCalledTimes(1);
      expect(mockedListSecretVersions).toHaveBeenCalledWith({
        parent: "projects/dummy_project_id/secrets/group_group_id-slack_token",
      });

      expect(mockedCreateSecret).toHaveBeenCalledTimes(0);

      expect(mockedAddSecretVersion).toHaveBeenCalledTimes(1);

      expect(mockedUpdateSecret).toHaveBeenCalledTimes(1);
      expect(mockedUpdateSecret).toHaveBeenCalledWith({
        secret: {
          name: "projects/dummy_project_id/secrets/group_group_id-slack_token",
          versionAliases: {
            current: "2",
          },
        },
        updateMask: {
          paths: ["version_aliases"],
        },
      });

      expect(mockedDestroySecretVersion).toHaveBeenCalledTimes(0);
    });
  });

  describe("以前のシークレットバージョン削除に失敗した場合", () => {
    it("エラーにならず、処理が続行されること", async () => {
      mockedDestroySecretVersion.mockRejectedValue(new Error("error"));

      const auth = functionsTest.auth.makeUserRecord({
        uid: "user_a",
      });

      await expect(
        wrapped({
          // @ts-expect-error
          auth,
          data: {
            groupId: "group_id",
            key: "slack_token",
            value: "token",
          },
        }),
      ).resolves.not.toThrowError();

      expect(mockedListSecretVersions).toHaveBeenCalledTimes(1);
      expect(mockedListSecretVersions).toHaveBeenCalledWith({
        parent: "projects/dummy_project_id/secrets/group_group_id-slack_token",
      });

      expect(mockedCreateSecret).toHaveBeenCalledTimes(0);

      expect(mockedAddSecretVersion).toHaveBeenCalledTimes(1);

      expect(mockedUpdateSecret).toHaveBeenCalledTimes(1);

      expect(mockedDestroySecretVersion).toHaveBeenCalledTimes(1);
      expect(mockedDestroySecretVersion).toHaveBeenCalledWith({
        name: "projects/project_id/secrets/secret_id/versions/1",
      });
    });
  });
});
