FROM node:20-alpine AS builder
WORKDIR /app

# Build arguments for environment variables needed at build time
ARG NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY
ARG NEXT_PUBLIC_CLERK_SIGN_IN_URL
ARG NEXT_PUBLIC_CLERK_SIGN_UP_URL
ARG NEXT_PUBLIC_CLERK_AFTER_SIGN_IN_URL
ARG NEXT_PUBLIC_CLERK_AFTER_SIGN_UP_URL
ARG NEXT_PUBLIC_GITHUB_BASE_URL
ARG NEXT_PUBLIC_GITHUB_API_BASE_URL
ARG NEXT_PUBLIC_GITHUB_APP_NAME
ARG NEXT_PUBLIC_SUPABASE_URL
ARG NEXT_PUBLIC_SUPABASE_ANON_KEY
ARG NEXT_PUBLIC_API_URL

# Set as environment variables for the build
ENV NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=$NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY
ENV NEXT_PUBLIC_CLERK_SIGN_IN_URL=$NEXT_PUBLIC_CLERK_SIGN_IN_URL
ENV NEXT_PUBLIC_CLERK_SIGN_UP_URL=$NEXT_PUBLIC_CLERK_SIGN_UP_URL
ENV NEXT_PUBLIC_CLERK_AFTER_SIGN_IN_URL=$NEXT_PUBLIC_CLERK_AFTER_SIGN_IN_URL
ENV NEXT_PUBLIC_CLERK_AFTER_SIGN_UP_URL=$NEXT_PUBLIC_CLERK_AFTER_SIGN_UP_URL
ENV NEXT_PUBLIC_GITHUB_BASE_URL=$NEXT_PUBLIC_GITHUB_BASE_URL
ENV NEXT_PUBLIC_GITHUB_API_BASE_URL=$NEXT_PUBLIC_GITHUB_API_BASE_URL
ENV NEXT_PUBLIC_GITHUB_APP_NAME=$NEXT_PUBLIC_GITHUB_APP_NAME
ENV NEXT_PUBLIC_SUPABASE_URL=$NEXT_PUBLIC_SUPABASE_URL
ENV NEXT_PUBLIC_SUPABASE_ANON_KEY=$NEXT_PUBLIC_SUPABASE_ANON_KEY
ENV NEXT_PUBLIC_API_URL=$NEXT_PUBLIC_API_URL

# Copy package.json and package-lock.json first for layer caching
COPY package.json package-lock.json ./

# Install dependencies
RUN npm ci

# Copy the rest of the application source code
COPY . .

# Build the Next.js application
RUN npm run build

# Clean npm cache
RUN npm cache clean --force

FROM node:20-alpine AS runtime
WORKDIR /app

# Create a non-root user and set permissions
RUN adduser -D -u 1001 appuser && \
    chown -R appuser:appuser /app

# Copy standalone server files FIRST
COPY --from=builder /app/.next/standalone ./

# CRITICAL: Copy static assets AFTER standalone
# Without this, CSS/JS will not load (white page with unstyled text)
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/public ./public

# Switch to the non-root user
USER appuser

# Expose the application port
EXPOSE 3000

# Healthcheck for container orchestration
HEALTHCHECK --interval=30s --timeout=3s CMD node -e "require('http').get('http://localhost:3000/_next/health', (r) => process.exit(r.statusCode === 200 ? 0 : 1))"

# Start the Next.js application in standalone mode
CMD ["node", "server.js"]