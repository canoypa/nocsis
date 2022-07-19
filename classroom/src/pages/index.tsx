import dynamic from "next/dynamic";
import Head from "next/head";
import { FC } from "react";
import "../core/messaging";

// SSR 回避
const Main = dynamic(() => import("../components/app"), {
  ssr: false,
  loading: () => <p>Wait a second...</p>,
});

const Home: FC = () => {
  return (
    <>
      <Head>
        <title>Nocsis</title>
      </Head>

      <Main />
    </>
  );
};
export default Home;
