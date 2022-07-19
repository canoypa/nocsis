import { FC, Suspense } from "react";
import { AuthProvider } from "./auth_provider";
import { Main } from "./main";
import { SignIn } from "./signin";

export const App: FC = () => {
  return (
    <Suspense fallback={<p>Loading something...</p>}>
      <AuthProvider signIn={<SignIn />}>
        <Main />
      </AuthProvider>
    </Suspense>
  );
};
export default App;
