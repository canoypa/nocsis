import { NoSsr } from "@mui/material";
import Head from "next/head";
import { FC, Suspense } from "react";
import { AuthProvider } from "../components/auth_provider";
import { Main } from "../components/main";
import { SignIn } from "../components/signin";
import "../core/messaging";

const Home: FC = () => {
  return (
    <>
      <Head>
        <title>Nocsis</title>
      </Head>

      <NoSsr>
        <Suspense fallback={<p>Loading something...</p>}>
          <AuthProvider signIn={<SignIn />}>
            <Main />
          </AuthProvider>
        </Suspense>
      </NoSsr>
    </>
  );
};
export default Home;
