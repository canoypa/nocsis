import { AtomEffect } from "recoil";

export const clientEffect = <T>(effect: AtomEffect<T>): AtomEffect<T> => {
  return (param) => {
    if (typeof window !== "undefined") {
      return effect(param);
    }
  };
};
