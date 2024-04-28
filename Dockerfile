# ---- Base Node ----
FROM node:alpine3.19 AS base
  WORKDIR /app

  COPY package.json package-lock.json ./
  RUN set -eux \
    && npm install

# ---- Run ----
FROM base AS app
  WORKDIR /app

  RUN set -eux \
    && apk add --no-cache \
        tini

  COPY . .
  RUN set -eux \
    && npm install

  CMD ["npm", "run", "start"]
