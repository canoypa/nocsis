import { Hono } from "hono";
import { classesRoutes } from "./v1/classes_controller.js";
import { groupRoutes } from "./v1/group_controller.js";

const v1Routes = new Hono();

v1Routes.route("/groups", groupRoutes);
v1Routes.route("/groups", classesRoutes);

export { v1Routes };
