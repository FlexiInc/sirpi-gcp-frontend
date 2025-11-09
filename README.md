# Sirpi Frontend

Modern web interface for AI-powered GCP infrastructure automation. Built with Next.js 15 and React 19.

## Features

- One-click deployment from GitHub to Google Cloud Run
- AI assistant for infrastructure management and troubleshooting
- Real-time build and deployment logs
- Secure authentication with Clerk and GCP OAuth 2.0
- Encrypted environment variable management
- Responsive dark theme design

## Quick Start

### Prerequisites

- Node.js 18+
- Backend API running (see backend README)

### Installation

```bash
# Install dependencies
npm install

# Setup environment
cp .env.example .env.local
# Edit .env.local with your credentials (see .env.example for all required variables)

# Run development server
npm run dev
# Open http://localhost:3000
```

### Environment Variables

See [.env.example](.env.example) for all required environment variables including:
- Backend API URL
- Clerk authentication keys
- Optional Supabase configuration

## How It Works

1. Sign up and connect your GitHub account
2. Authorize Sirpi to deploy to your Google Cloud project
3. Import a repository and let AI agents analyze your code
4. Deploy to Cloud Run with one click
5. Manage scaling and monitor costs via AI assistant

## AI Assistant

Chat with the AI assistant to manage your infrastructure. Ask questions like:
- "Show my current scaling configuration"
- "Set min instances to 2 and max to 5"
- "How much is this costing me?"
- "Why did my deployment fail?"

The assistant can check service details, update scaling, estimate costs, analyze logs, and explain infrastructure decisions.

## Tech Stack

- Next.js 15 - React framework with App Router
- React 19 - UI library
- TypeScript - Type safety
- Tailwind CSS - Styling
- Clerk - Authentication
- Server-Sent Events - Real-time logs

## Development

```bash
# Linting
npm run lint

# Type checking
npx tsc --noEmit

# Production build
npm run build
npm start
```

## Deployment

### Docker
```bash
docker build -t sirpi-frontend .
docker run -p 3000:3000 sirpi-frontend
```

### Vercel
```bash
npm i -g vercel
vercel --prod
```

### Cloud Run
```bash
gcloud run deploy sirpi-frontend \
  --source . \
  --region us-central1 \
  --allow-unauthenticated
```
