FROM node:24-slim AS base
WORKDIR /app

ENV NODE_ENV=production

FROM base AS builder-base

ENV PNPM_VERSION=11.25.0

RUN npm install --global pnpm@${PNPM_VERSION}


FROM builder-base AS builder

COPY . .
RUN pnpm install --frozen-lockfile && \
    pnpm run build && \
    pnpm prune --prod


FROM base AS runner

COPY --from=builder /app/node_modules /app/node_modules
COPY --from=builder /app/dist /app/dist

EXPOSE 8080
CMD [ "node", "--enable-source-maps", "dist/main.js" ]
