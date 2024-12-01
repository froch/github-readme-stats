# ---- Build Stage ----
FROM node:22-alpine3.19 AS builder
WORKDIR /app
COPY package*.json ./
# Install dependencies including dev dependencies
RUN set -eux \
    && npm ci

# Copy source
COPY . .
# Run any build steps, tests, etc
RUN set -eux \
    && npm run format \
    && npm run lint \
    && npm run test \
    && npm prune --production

# ---- Production Stage ----
FROM node:22-alpine3.19
WORKDIR /app

# Add Tini for proper process handling
RUN set -eux \
    && apk add --no-cache tini

# Copy only production files
COPY --from=builder /app/src ./src
COPY --from=builder /app/api ./api
COPY --from=builder /app/themes ./themes
COPY --from=builder /app/express.js ./
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/node_modules ./node_modules

# Switch to non-root user
USER node

# Use Tini as entrypoint
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["node", "express.js"]
