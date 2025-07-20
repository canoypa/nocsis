import { Hono } from "hono";
import { classesRoutes } from "./v1/classes_controller.js";
import { eventsRoutes } from "./v1/events_controller.js";
import { groupRoutes } from "./v1/group_controller.js";
import { userRoutes } from "./v1/user_controller.js";
import { weatherRoutes } from "./v1/weather_controller.js";

const v1Routes = new Hono();

v1Routes.route("/groups", groupRoutes);
v1Routes.route("/groups", classesRoutes);
v1Routes.route("/groups", eventsRoutes);
v1Routes.route("/groups", weatherRoutes);
v1Routes.route("/users", userRoutes);

export { v1Routes };
