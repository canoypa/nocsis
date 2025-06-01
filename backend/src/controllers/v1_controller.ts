import { Hono } from "hono";
import { groupRoutes } from "./v1/group_controller.js";

const v1Routes = new Hono();

v1Routes.route("/groups", groupRoutes);

export { v1Routes };
