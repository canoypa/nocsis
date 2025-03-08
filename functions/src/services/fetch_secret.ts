import { SecretManagerServiceClient } from "@google-cloud/secret-manager";
import { firebaseApp } from "~/client/firebaseApp.js";

export const fetchSecret = async (secretName: string) => {
  const projectId = firebaseApp.options.projectId;
  if (!projectId) throw new Error("projectId is not found");

  const client = new SecretManagerServiceClient();

  const name = client.secretVersionPath(projectId, secretName, "latest");

  const [version] = await client.accessSecretVersion({
    name: name,
  });

  const secret = version.payload?.data?.toString();

  if (!secret) throw new Error("secret is not found");

  return secret;
};
