import { hexFromArgb, Scheme } from "@material/material-color-utilities";
import {
  createTheme,
  PaletteColor,
  PaletteColorOptions,
  PaletteOptions,
  TypeBackground,
} from "@mui/material";

// Augmentation MUI theme with Material 3
declare module "@mui/material/styles" {
  interface PaletteOptions {
    primary?: PaletteColorOptions;
    primaryContainer?: PaletteColorOptions;
    onPrimary?: PaletteColorOptions;
    onPrimaryContainer?: PaletteColorOptions;
    secondary?: PaletteColorOptions;
    secondaryContainer?: PaletteColorOptions;
    onSecondary?: PaletteColorOptions;
    onSecondaryContainer?: PaletteColorOptions;
    tertiary?: PaletteColorOptions;
    tertiaryContainer?: PaletteColorOptions;
    onTertiary?: PaletteColorOptions;
    onTertiaryContainer?: PaletteColorOptions;
    error?: PaletteColorOptions;
    errorContainer?: PaletteColorOptions;
    onError?: PaletteColorOptions;
    onErrorContainer?: PaletteColorOptions;
    background?: Partial<TypeBackground>;
    onBackground?: PaletteColorOptions;
    surface?: PaletteColorOptions;
    onSurface?: PaletteColorOptions;
    surfaceVariant?: PaletteColorOptions;
    onSurfaceVariant?: PaletteColorOptions;
    outline?: PaletteColorOptions;
    shadow?: PaletteColorOptions;
    inverseSurface?: PaletteColorOptions;
    inverseOnSurface?: PaletteColorOptions;
    inversePrimary?: PaletteColorOptions;
  }

  interface Palette {
    primary: PaletteColor;
    primaryContainer: PaletteColor;
    onPrimary: PaletteColor;
    onPrimaryContainer: PaletteColor;
    secondary: PaletteColor;
    secondaryContainer: PaletteColor;
    onSecondary: PaletteColor;
    onSecondaryContainer: PaletteColor;
    tertiary: PaletteColor;
    tertiaryContainer: PaletteColor;
    onTertiary: PaletteColor;
    onTertiaryContainer: PaletteColor;
    error: PaletteColor;
    errorContainer: PaletteColor;
    onError: PaletteColor;
    onErrorContainer: PaletteColor;
    background: TypeBackground;
    onBackground: PaletteColor;
    surface: PaletteColor;
    onSurface: PaletteColor;
    surfaceVariant: PaletteColor;
    onSurfaceVariant: PaletteColor;
    outline: PaletteColor;
    shadow: PaletteColor;
    inverseSurface: PaletteColor;
    inverseOnSurface: PaletteColor;
    inversePrimary: PaletteColor;
  }
}

const SEED_COLOR = 0x6750a4;

const createPalette = (): PaletteOptions => {
  const scheme = Scheme.dark(SEED_COLOR);

  const options: PaletteOptions = {
    mode: "dark",

    tonalOffset: 0.4,

    ...Object.entries(scheme.toJSON()).reduce<any>((p, c) => {
      const [key, value] = c;

      if (key === "background") {
        p[key] = { default: hexFromArgb(value), paper: hexFromArgb(value) };
        return p;
      }

      p[key] = { main: hexFromArgb(value) };
      return p;
    }, {}),
  };

  return options;
};

export const theme = createTheme({
  palette: createPalette(),

  typography: {
    fontFamily: ["Noto Sans JP", "sans-serif"].join(","),
  },

  components: {
    MuiCssBaseline: {
      styleOverrides: {
        body: {
          overflow: "hidden",
        },
      },
    },
    MuiPaper: {
      styleOverrides: {
        rounded: {
          borderRadius: 28,
        },
      },
    },
  },
});
