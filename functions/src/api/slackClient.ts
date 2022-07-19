import { WebClient as SlackClient } from "@slack/web-api";

export const slackClient = new SlackClient(process.env.SLACK_TOKEN);
