import { firestore } from "../clients/firebase.js";

/**
 * 生徒は classmates に、出席番号 stuNo を付けて持つ。
 * 日直の計算が stuNo を 1 から数えるので、並べ替えや削除のたびに 1 から詰めて振り直す。
 * 先生 (role が teacher) も同じコレクションにいるが、ここでは扱わない。
 */
const CLASSMATES = "classmates";

export type Member = {
  id: string;
  number: number;
  name: string;
};

const studentsOf = (groupId: string) =>
  firestore
    .collection(CLASSMATES)
    .where("group_id", "==", groupId)
    .where("role", "==", "student");

const toMembers = (docs: FirebaseFirestore.QueryDocumentSnapshot[]): Member[] =>
  docs
    .map((doc) => ({
      id: doc.id,
      number: doc.get("stuNo") as number,
      name: doc.get("name") as string,
    }))
    .sort((a, b) => a.number - b.number);

/** ids の順に 1 から振り直す。番号が変わる行だけ書く */
const renumber = (
  tx: FirebaseFirestore.Transaction,
  members: Member[],
): Member[] =>
  members.map((member, index) => {
    const number = index + 1;
    if (member.number !== number) {
      tx.update(firestore.collection(CLASSMATES).doc(member.id), {
        stuNo: number,
      });
    }
    return { ...member, number };
  });

export const listMembers = async (groupId: string): Promise<Member[]> =>
  toMembers((await studentsOf(groupId).get()).docs);

/** 名前の順に、末尾の番号の続きで加える */
export const addMembers = (
  groupId: string,
  names: string[],
): Promise<Member[]> =>
  firestore.runTransaction(async (tx) => {
    const current = toMembers((await tx.get(studentsOf(groupId))).docs);
    const last = current.at(-1)?.number ?? 0;

    return names.map((name, index) => {
      const ref = firestore.collection(CLASSMATES).doc();
      const number = last + index + 1;
      tx.create(ref, {
        group_id: groupId,
        role: "student",
        stuNo: number,
        name,
      });
      return { id: ref.id, number, name };
    });
  });

export const renameMember = (
  groupId: string,
  memberId: string,
  name: string,
): Promise<Member | null> =>
  firestore.runTransaction(async (tx) => {
    const ref = firestore.collection(CLASSMATES).doc(memberId);
    const doc = await tx.get(ref);
    if (
      !doc.exists ||
      doc.get("group_id") !== groupId ||
      doc.get("role") !== "student"
    ) {
      return null;
    }

    tx.update(ref, { name });
    return { id: doc.id, number: doc.get("stuNo") as number, name };
  });

/**
 * ids の順に並べ替える。ids はグループの生徒全員でないといけない。
 * 画面を開いた後にほかの人が足したり消したりしていたら、並べ替えずに "mismatch" を返す
 */
export const reorderMembers = (
  groupId: string,
  ids: string[],
): Promise<Member[] | "mismatch"> =>
  firestore.runTransaction(async (tx) => {
    const current = toMembers((await tx.get(studentsOf(groupId))).docs);
    const byId = new Map(current.map((member) => [member.id, member]));

    const ordered = ids.flatMap((id) => byId.get(id) ?? []);

    if (ordered.length !== ids.length || ids.length !== current.length) {
      return "mismatch";
    }

    return renumber(tx, ordered);
  });

/** 消したあと、残りを詰めて振り直す。グループにいない ID があれば、消さずに "not_found" を返す */
export const removeMembers = (
  groupId: string,
  ids: string[],
): Promise<Member[] | "not_found"> =>
  firestore.runTransaction(async (tx) => {
    const current = toMembers((await tx.get(studentsOf(groupId))).docs);
    const removing = new Set(ids);

    if (!ids.every((id) => current.some((member) => member.id === id))) {
      return "not_found";
    }

    for (const id of removing) {
      tx.delete(firestore.collection(CLASSMATES).doc(id));
    }
    return renumber(
      tx,
      current.filter((member) => !removing.has(member.id)),
    );
  });
