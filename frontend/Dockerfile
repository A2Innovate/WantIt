FROM node:22-alpine AS build
WORKDIR /app

RUN corepack enable

COPY package.json pnpm-lock.yaml ./

RUN pnpm i

COPY . ./
RUN pnpm run build

FROM node:22-alpine
WORKDIR /app

COPY --from=build /app/.output/ ./

ENV PORT 3000
ENV HOST 0.0.0.0

EXPOSE 3000

CMD ["node", "/app/server/index.mjs"]
