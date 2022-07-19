import { CssBaseline, ThemeProvider } from "@mui/material";
import { NextPage } from "next";
import { AppProps } from "next/app";
import { RecoilRoot } from "recoil";
import { theme } from "../core/theme";

const MyApp: NextPage<AppProps> = ({ Component, pageProps }) => {
  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />

      <RecoilRoot>
        <Component {...pageProps} />
      </RecoilRoot>
    </ThemeProvider>
  );
};
export default MyApp;
