FROM node:22-slim AS base
WORKDIR /app

ENV NODE_ENV=production

RUN corepack enable


FROM base AS builder

COPY . .
RUN pnpm install --frozen-lockfile && \
    pnpm run build && \
    pnpm prune --prod


FROM base AS runner

COPY --from=builder /app/node_modules /app/node_modules
COPY --from=builder /app/dist /app/dist

EXPOSE 8888
CMD [ "node", "--enable-source-maps", "dist/main.js" ]
