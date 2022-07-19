const withTM = require("next-transpile-modules")([
  "@material/material-color-utilities",
]);

/** @type {import('next').NextConfig} */
const nextConfig = withTM({
  reactStrictMode: true,
});

module.exports = nextConfig;
