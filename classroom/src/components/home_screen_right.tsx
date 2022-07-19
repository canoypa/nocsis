import { FC } from "react";
import { selector, useRecoilValue } from "recoil";
import { ClassesSelector } from "../atoms/classes";
import { MinuteState } from "../atoms/date";
import { EventSelector } from "../atoms/events";
import { ClassesData } from "../types/classes";
import { ClassesList } from "./classes-list";
import { EventsList } from "./events-list";

const UpcomingClassSelector = selector<ClassesData>({
  key: "upcomingClass",
  get: ({ get }) => {
    // update every minute
    get(MinuteState);

    const classes = get(ClassesSelector);

    const upcomingClass = classes.items.filter(
      (v) => v.endAt.diffNow().as("milliseconds") >= 0
    );

    return {
      isEmpty: upcomingClass.length === 0,
      items: upcomingClass,
    };
  },
  cachePolicy_UNSTABLE: {
    eviction: "most-recent",
  },
});

export const HomeScreenRight: FC = () => {
  const classes = useRecoilValue(UpcomingClassSelector);
  const events = useRecoilValue(EventSelector);

  if (!classes.isEmpty) {
    return <ClassesList items={classes.items} />;
  }

  if (!events.isEmpty) {
    return <EventsList items={events.items} />;
  }

  return null;
};
