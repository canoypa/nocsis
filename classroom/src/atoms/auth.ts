import { getAuth, onAuthStateChanged, User } from "firebase/auth";
import { atom } from "recoil";
import { firebaseApp } from "../core/firebase_app";

export const AuthState = atom<User | null>({
  key: "AuthState",
  effects: [
    ({ setSelf }) => {
      const auth = getAuth(firebaseApp);

      onAuthStateChanged(auth, (user) => {
        setSelf(user);
      });
    },
  ],
});
