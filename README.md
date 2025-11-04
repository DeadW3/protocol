# DeadW3 Protocol

> Arweave archival + ERC-20 incentives + AI verification for live music recordings

## 🚀 Quick Start

### Prerequisites

- Node.js >= 20.0.0
- pnpm >= 8.0.0
- Docker & Docker Compose (for local development)

### Setup

1. Clone the repository:

```bash
git clone https://github.com/DeadW3/protocol.git
cd protocol
```

2. Run the setup script:

```bash
./setup.sh
```

3. Copy environment variables:

```bash
cp .env.example .env
# Edit .env with your configuration
```

4. Set up the database:

```bash
cd packages/database
pnpm db:generate
pnpm db:migrate
```

5. Start development servers:

```bash
# From the root directory
pnpm dev
```

## 📦 Package Structure

- `packages/types` - Shared TypeScript types
- `packages/config` - Environment configuration
- `packages/database` - Prisma schemas and client
- `packages/clanker-sdk` - Clanker token SDK wrapper
- `packages/api` - FastAPI REST server
- `packages/indexer` - Arweave indexing worker

## 🛠️ Development

- `pnpm build` - Build all packages
- `pnpm dev` - Start all packages in watch mode
- `pnpm test` - Run all tests
- `pnpm lint` - Lint all packages
- `pnpm format` - Format code with Prettier

## 📄 License

MPL-2.0
