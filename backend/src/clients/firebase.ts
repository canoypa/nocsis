import { getApps, initializeApp } from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";
import { getFirestore } from "firebase-admin/firestore";

export const firebaseApp = getApps().at(0) ?? initializeApp();
export const auth = getAuth(firebaseApp);
export const firestore = getFirestore(firebaseApp);
