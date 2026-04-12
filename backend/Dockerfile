FROM node:22-slim AS base
WORKDIR /app

ENV NODE_ENV=production
ENV PNPM_HOME=/root/.local/share/pnpm
ENV PATH=${PNPM_HOME}:${PATH}
ENV PNPM_VERSION=10.11.0

RUN apt-get update && \
    apt-get install --yes --no-install-recommends wget ca-certificates && \
    wget -qO- https://get.pnpm.io/install.sh | env PNPM_VERSION=${PNPM_VERSION} ENV="$HOME/.shrc" SHELL="$(which sh)" sh - && \
    apt-get purge --yes --auto-remove wget && \
    rm -rf /var/lib/apt/lists/*


FROM base AS builder

COPY . .
RUN pnpm install --frozen-lockfile && \
    pnpm run build && \
    pnpm prune --prod


FROM base AS runner

COPY --from=builder /app/node_modules /app/node_modules
COPY --from=builder /app/dist /app/dist

EXPOSE 8080
CMD [ "node", "--enable-source-maps", "dist/main.js" ]
