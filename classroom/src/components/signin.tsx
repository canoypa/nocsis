import { Button, Stack, styled, Typography } from "@mui/material";
import { Box } from "@mui/system";
import { getAuth, GoogleAuthProvider, signInWithPopup } from "firebase/auth";
import { FC } from "react";
import { firebaseApp } from "../core/firebase_app";

// でかいボタン
const SignInButton = styled(Button)({
  height: 64,
  borderRadius: 32,
});

export const SignIn: FC = () => {
  const signIn = async () => {
    const auth = getAuth(firebaseApp);

    signInWithPopup(auth, new GoogleAuthProvider()).catch((err) => {
      // エラーは無い (あっても問題ない)
    });
  };

  return (
    <Box
      height="100vh"
      display="flex"
      alignItems="center"
      justifyContent="center"
    >
      <Stack direction="column" spacing={8}>
        <Typography variant="h2">Nocsis</Typography>
        <SignInButton variant="outlined" onClick={signIn}>
          サインイン
        </SignInButton>
      </Stack>
    </Box>
  );
};
