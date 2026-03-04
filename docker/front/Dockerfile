FROM node:22-alpine

# Install Yarn globally
RUN corepack enable && corepack prepare yarn@stable --activate

WORKDIR /app

# Copy package files first for better caching
COPY ./front/package.json ./front/yarn.lock* ./

# Install dependencies
RUN yarn install --frozen-lockfile || true

EXPOSE 5173

CMD ["yarn", "dev", "--host", "0.0.0.0"]
