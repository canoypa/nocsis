import { CssBaseline, ThemeProvider } from "@mui/material";
import { NextPage } from "next";
import { AppProps } from "next/app";
import { RecoilRoot } from "recoil";
import RootErrorBoundary from "../components/root_error_boundary";
import { theme } from "../core/theme";

const MyApp: NextPage<AppProps> = ({ Component, pageProps }) => {
  return (
    <RootErrorBoundary>
      <ThemeProvider theme={theme}>
        <CssBaseline />

        <RecoilRoot>
          <Component {...pageProps} />
        </RecoilRoot>
      </ThemeProvider>
    </RootErrorBoundary>
  );
};
export default MyApp;
