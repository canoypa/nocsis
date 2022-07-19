import { FC, ReactElement } from "react";
import { useRecoilValue } from "recoil";
import { AuthState } from "../atoms/auth";

type Props = {
  signIn: ReactElement;
  children: ReactElement;
};

// サインイン状態に応じて、子コンポーネントを切り替える
export const AuthProvider: FC<Props> = ({ signIn, children }) => {
  const authState = useRecoilValue(AuthState);

  if (!authState) {
    return signIn;
  }

  return children;
};
