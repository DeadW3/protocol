#!/bin/bash
set -e  # Exit on any error

echo "🚀 Setting up DeadW3 Protocol workspace..."

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_step() {
    echo -e "${BLUE}▶ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Step 1: Create directory structure
print_step "Creating directory structure..."
mkdir -p packages/{api,indexer,database,config,types,clanker-sdk}/src
mkdir -p packages/{api,indexer,clanker-sdk}/src/__tests__
mkdir -p packages/database/prisma
mkdir -p .github/workflows
mkdir -p docs/{adr,runbooks}
print_success "Directories created"

# Step 2: Create root package.json
print_step "Creating root package.json..."
cat > package.json << 'EOF'
{
  "name": "deadw3-protocol",
  "version": "0.1.0",
  "private": true,
  "description": "DeadW3 Protocol: Arweave archival + ERC-20 incentives + AI verification",
  "repository": {
    "type": "git",
    "url": "https://github.com/DeadW3/protocol.git"
  },
  "license": "MPL-2.0",
  "engines": {
    "node": ">=20.0.0",
    "pnpm": ">=8.0.0"
  },
  "packageManager": "pnpm@8.15.1",
  "scripts": {
    "build": "pnpm -r build",
    "dev": "pnpm -r --parallel dev",
    "test": "pnpm -r test",
    "lint": "pnpm -r lint",
    "format": "prettier --write \"**/*.{ts,tsx,js,jsx,json,md}\"",
    "format:check": "prettier --check \"**/*.{ts,tsx,js,jsx,json,md}\"",
    "typecheck": "pnpm -r typecheck",
    "clean": "pnpm -r clean && rm -rf node_modules",
    "prepare": "husky install"
  },
  "devDependencies": {
    "@types/node": "^20.10.6",
    "@typescript-eslint/eslint-plugin": "^6.18.1",
    "@typescript-eslint/parser": "^6.18.1",
    "eslint": "^8.56.0",
    "eslint-config-airbnb-base": "^15.0.0",
    "eslint-config-airbnb-typescript": "^17.1.0",
    "eslint-config-prettier": "^9.1.0",
    "eslint-plugin-import": "^2.29.1",
    "husky": "^8.0.3",
    "lint-staged": "^15.2.0",
    "prettier": "^3.1.1",
    "typescript": "^5.3.3"
  }
}
EOF
print_success "Root package.json created"

# Step 3: Create pnpm-workspace.yaml
print_step "Creating pnpm-workspace.yaml..."
cat > pnpm-workspace.yaml << 'EOF'
packages:
  - 'packages/*'
EOF
print_success "Workspace config created"

# Step 4: Update .gitignore
print_step "Updating .gitignore..."
cat >> .gitignore << 'EOF'

# Dependencies
node_modules/
.pnpm-store/

# Build outputs
dist/
build/
*.tsbuildinfo

# Environment files
.env
.env.local
.env*.local

# IDE
.vscode/*
!.vscode/settings.json
!.vscode/extensions.json
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Logs
*.log
logs/
pino-*.log

# Docker
.docker-data/

# Testing
coverage/
.nyc_output/

# Prisma
prisma/migrations/
!prisma/migrations/.gitkeep
EOF
print_success ".gitignore updated"

# Step 5: Create package.json files for all packages
print_step "Creating package.json files..."

cat > packages/types/package.json << 'EOF'
{
  "name": "@deadw3/types",
  "version": "0.1.0",
  "private": true,
  "description": "Shared TypeScript types for DeadW3 Protocol",
  "main": "./dist/index.js",
  "types": "./dist/index.d.ts",
  "exports": {
    ".": {
      "types": "./dist/index.d.ts",
      "default": "./dist/index.js"
    }
  },
  "scripts": {
    "build": "tsc",
    "dev": "tsc --watch",
    "typecheck": "tsc --noEmit",
    "clean": "rm -rf dist *.tsbuildinfo"
  },
  "devDependencies": {
    "typescript": "^5.3.3"
  }
}
EOF

cat > packages/config/package.json << 'EOF'
{
  "name": "@deadw3/config",
  "version": "0.1.0",
  "private": true,
  "description": "Environment configuration and validation for DeadW3",
  "main": "./dist/index.js",
  "types": "./dist/index.d.ts",
  "exports": {
    ".": {
      "types": "./dist/index.d.ts",
      "default": "./dist/index.js"
    }
  },
  "scripts": {
    "build": "tsc",
    "dev": "tsc --watch",
    "typecheck": "tsc --noEmit",
    "clean": "rm -rf dist *.tsbuildinfo"
  },
  "dependencies": {
    "zod": "^3.22.4",
    "dotenv": "^16.3.1"
  },
  "devDependencies": {
    "@types/node": "^20.10.6",
    "typescript": "^5.3.3"
  }
}
EOF

cat > packages/database/package.json << 'EOF'
{
  "name": "@deadw3/database",
  "version": "0.1.0",
  "private": true,
  "description": "Database schemas, migrations, and client for DeadW3",
  "main": "./dist/index.js",
  "types": "./dist/index.d.ts",
  "exports": {
    ".": {
      "types": "./dist/index.d.ts",
      "default": "./dist/index.js"
    }
  },
  "scripts": {
    "build": "tsc",
    "dev": "tsc --watch",
    "typecheck": "tsc --noEmit",
    "clean": "rm -rf dist *.tsbuildinfo",
    "db:generate": "prisma generate",
    "db:migrate": "prisma migrate dev",
    "db:migrate:prod": "prisma migrate deploy",
    "db:seed": "tsx prisma/seed.ts",
    "db:studio": "prisma studio",
    "db:push": "prisma db push"
  },
  "dependencies": {
    "@prisma/client": "^5.7.1",
    "@deadw3/types": "workspace:*"
  },
  "devDependencies": {
    "@types/node": "^20.10.6",
    "prisma": "^5.7.1",
    "tsx": "^4.7.0",
    "typescript": "^5.3.3"
  }
}
EOF

cat > packages/clanker-sdk/package.json << 'EOF'
{
  "name": "@deadw3/clanker-sdk",
  "version": "0.1.0",
  "private": true,
  "description": "Wrapper SDK for Clanker token deployment interactions",
  "main": "./dist/index.js",
  "types": "./dist/index.d.ts",
  "exports": {
    ".": {
      "types": "./dist/index.d.ts",
      "default": "./dist/index.js"
    }
  },
  "scripts": {
    "build": "tsc",
    "dev": "tsc --watch",
    "test": "vitest",
    "typecheck": "tsc --noEmit",
    "clean": "rm -rf dist *.tsbuildinfo"
  },
  "dependencies": {
    "viem": "^2.7.1",
    "@deadw3/types": "workspace:*",
    "@deadw3/config": "workspace:*"
  },
  "devDependencies": {
    "@types/node": "^20.10.6",
    "typescript": "^5.3.3",
    "vitest": "^1.1.0"
  }
}
EOF

cat > packages/api/package.json << 'EOF'
{
  "name": "@deadw3/api",
  "version": "0.1.0",
  "private": true,
  "description": "REST API server for DeadW3 Protocol",
  "main": "./dist/index.js",
  "scripts": {
    "build": "tsc",
    "dev": "tsx watch src/index.ts",
    "start": "node dist/index.js",
    "test": "vitest",
    "typecheck": "tsc --noEmit",
    "lint": "eslint src --ext .ts",
    "clean": "rm -rf dist *.tsbuildinfo"
  },
  "dependencies": {
    "fastify": "^4.25.2",
    "@fastify/cors": "^8.5.0",
    "@fastify/swagger": "^8.13.0",
    "@fastify/swagger-ui": "^2.1.0",
    "pino": "^8.17.2",
    "pino-pretty": "^10.3.1",
    "@deadw3/database": "workspace:*",
    "@deadw3/types": "workspace:*",
    "@deadw3/config": "workspace:*",
    "@deadw3/clanker-sdk": "workspace:*"
  },
  "devDependencies": {
    "@types/node": "^20.10.6",
    "eslint": "^8.56.0",
    "tsx": "^4.7.0",
    "typescript": "^5.3.3",
    "vitest": "^1.1.0"
  }
}
EOF

cat > packages/indexer/package.json << 'EOF'
{
  "name": "@deadw3/indexer",
  "version": "0.1.0",
  "private": true,
  "description": "Background worker for indexing Arweave data",
  "main": "./dist/index.js",
  "scripts": {
    "build": "tsc",
    "dev": "tsx watch src/index.ts",
    "start": "node dist/index.js",
    "test": "vitest",
    "typecheck": "tsc --noEmit",
    "lint": "eslint src --ext .ts",
    "clean": "rm -rf dist *.tsbuildinfo"
  },
  "dependencies": {
    "arweave": "^1.14.4",
    "graphql": "^16.8.1",
    "graphql-request": "^6.1.0",
    "pino": "^8.17.2",
    "@deadw3/database": "workspace:*",
    "@deadw3/types": "workspace:*",
    "@deadw3/config": "workspace:*"
  },
  "devDependencies": {
    "@types/node": "^20.10.6",
    "eslint": "^8.56.0",
    "tsx": "^4.7.0",
    "typescript": "^5.3.3",
    "vitest": "^1.1.0"
  }
}
EOF

print_success "All package.json files created"

# Step 6: Create TypeScript configurations
print_step "Creating TypeScript configurations..."

cat > tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "lib": ["ES2022"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "composite": true,
    "incremental": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true
  },
  "exclude": ["node_modules", "dist", "**/*.test.ts", "**/*.spec.ts"]
}
EOF

cat > packages/types/tsconfig.json << 'EOF'
{
  "extends": "../../tsconfig.json",
  "compilerOptions": {
    "outDir": "./dist",
    "rootDir": "./src"
  },
  "include": ["src/**/*"]
}
EOF

cat > packages/config/tsconfig.json << 'EOF'
{
  "extends": "../../tsconfig.json",
  "compilerOptions": {
    "outDir": "./dist",
    "rootDir": "./src"
  },
  "include": ["src/**/*"],
  "references": [{ "path": "../types" }]
}
EOF

cat > packages/database/tsconfig.json << 'EOF'
{
  "extends": "../../tsconfig.json",
  "compilerOptions": {
    "outDir": "./dist",
    "rootDir": "./src"
  },
  "include": ["src/**/*", "prisma/**/*"],
  "references": [{ "path": "../types" }]
}
EOF

cat > packages/clanker-sdk/tsconfig.json << 'EOF'
{
  "extends": "../../tsconfig.json",
  "compilerOptions": {
    "outDir": "./dist",
    "rootDir": "./src"
  },
  "include": ["src/**/*"],
  "references": [
    { "path": "../types" },
    { "path": "../config" }
  ]
}
EOF

cat > packages/api/tsconfig.json << 'EOF'
{
  "extends": "../../tsconfig.json",
  "compilerOptions": {
    "outDir": "./dist",
    "rootDir": "./src"
  },
  "include": ["src/**/*"],
  "references": [
    { "path": "../types" },
    { "path": "../config" },
    { "path": "../database" },
    { "path": "../clanker-sdk" }
  ]
}
EOF

cat > packages/indexer/tsconfig.json << 'EOF'
{
  "extends": "../../tsconfig.json",
  "compilerOptions": {
    "outDir": "./dist",
    "rootDir": "./src"
  },
  "include": ["src/**/*"],
  "references": [
    { "path": "../types" },
    { "path": "../config" },
    { "path": "../database" }
  ]
}
EOF

print_success "TypeScript configurations created"

# Step 7: Create ESLint and Prettier configs
print_step "Creating linter and formatter configs..."

cat > .eslintrc.js << 'EOF'
module.exports = {
  root: true,
  parser: '@typescript-eslint/parser',
  parserOptions: {
    ecmaVersion: 2022,
    sourceType: 'module',
    project: './tsconfig.json',
  },
  plugins: ['@typescript-eslint', 'import'],
  extends: [
    'eslint:recommended',
    'plugin:@typescript-eslint/recommended',
    'plugin:@typescript-eslint/recommended-requiring-type-checking',
    'airbnb-base',
    'airbnb-typescript/base',
    'prettier',
  ],
  rules: {
    'import/prefer-default-export': 'off',
    'import/no-default-export': 'error',
    '@typescript-eslint/explicit-module-boundary-types': 'error',
    '@typescript-eslint/no-explicit-any': 'error',
    '@typescript-eslint/no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
    'no-console': ['warn', { allow: ['warn', 'error'] }],
  },
};
EOF

cat > .prettierrc.js << 'EOF'
module.exports = {
  semi: true,
  trailingComma: 'es5',
  singleQuote: true,
  printWidth: 100,
  tabWidth: 2,
  useTabs: false,
  arrowParens: 'always',
  endOfLine: 'lf',
};
EOF

cat > .prettierignore << 'EOF'
node_modules
dist
build
coverage
.next
*.tsbuildinfo
pnpm-lock.yaml
EOF

cat > .lintstagedrc.js << 'EOF'
module.exports = {
  '*.{ts,tsx}': ['eslint --fix', 'prettier --write'],
  '*.{js,jsx,json,md}': ['prettier --write'],
};
EOF

print_success "Linter and formatter configs created"

# Step 8: Create source files
print_step "Creating source files..."

# Types package
cat > packages/types/src/index.ts << 'EOF'
// Core domain types for DeadW3 Protocol
export * from './show';
export * from './verification';
export * from './user';
EOF

cat > packages/types/src/show.ts << 'EOF'
export interface Show {
  id: string;
  artist: string;
  venue: string;
  date: string;
  arweaveId: string;
  status: 'pending' | 'verified' | 'rejected';
  createdAt: Date;
  updatedAt: Date;
}

export interface ShowMetadata {
  duration?: number;
  setlist?: string[];
  notes?: string;
}
EOF

cat > packages/types/src/verification.ts << 'EOF'
export interface VerificationReport {
  id: string;
  showId: string;
  audioFingerprint: string;
  duplicateScore: number;
  verified: boolean;
  arweaveReportId: string;
  createdAt: Date;
}

export interface AudioAnalysis {
  sampleRate: number;
  channels: number;
  duration: number;
  checksum: string;
}
EOF

cat > packages/types/src/user.ts << 'EOF'
export interface User {
  id: string;
  address: string;
  farcasterFid?: string;
  createdAt: Date;
}

export interface UserProfile extends User {
  uploadsCount: number;
  rewardsEarned: string;
}
EOF

# Config package
cat > packages/config/src/index.ts << 'EOF'
import { z } from 'zod';
import dotenv from 'dotenv';

dotenv.config();

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),
  DATABASE_URL: z.string().url(),
  REDIS_URL: z.string().url().optional(),
  ARWEAVE_GATEWAY: z.string().url().default('https://arweave.net'),
  BASE_RPC_URL: z.string().url(),
  PORT: z.coerce.number().default(3000),
  LOG_LEVEL: z.enum(['debug', 'info', 'warn', 'error']).default('info'),
});

export type Env = z.infer<typeof envSchema>;

export const config = envSchema.parse(process.env);

export const isDevelopment = config.NODE_ENV === 'development';
export const isProduction = config.NODE_ENV === 'production';
export const isTest = config.NODE_ENV === 'test';
EOF

# Database package
cat > packages/database/src/index.ts << 'EOF'
export { PrismaClient } from '@prisma/client';
export * from './client';
EOF

cat > packages/database/src/client.ts << 'EOF'
import { PrismaClient } from '@prisma/client';

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined;
};

export const prisma =
  globalForPrisma.prisma ??
  new PrismaClient({
    log: process.env.NODE_ENV === 'development' ? ['query', 'error', 'warn'] : ['error'],
  });

if (process.env.NODE_ENV !== 'production') globalForPrisma.prisma = prisma;

export default prisma;
EOF

# Clanker SDK package
cat > packages/clanker-sdk/src/index.ts << 'EOF'
import { createPublicClient, http, type Address } from 'viem';
import { base } from 'viem/chains';
import { config } from '@deadw3/config';

export class ClankerClient {
  private client;

  constructor(rpcUrl?: string) {
    this.client = createPublicClient({
      chain: base,
      transport: http(rpcUrl ?? config.BASE_RPC_URL),
    });
  }

  async deployToken(params: { 
    name: string; 
    symbol: string; 
    initialSupply: bigint 
  }): Promise<Address> {
    // TODO: Implement actual Clanker SDK integration
    // For now, this is a placeholder
    throw new Error('Not implemented: Clanker SDK integration pending');
  }

  async getTokenInfo(tokenAddress: Address) {
    // TODO: Implement token info fetching
    throw new Error('Not implemented');
  }
}

export * from './types';
EOF

cat > packages/clanker-sdk/src/types.ts << 'EOF'
import type { Address } from 'viem';

export interface TokenDeployment {
  address: Address;
  name: string;
  symbol: string;
  totalSupply: bigint;
  deployer: Address;
  deployedAt: Date;
}

export interface TokenConfig {
  name: string;
  symbol: string;
  initialSupply: bigint;
  decimals: number;
}
EOF

# API package
cat > packages/api/src/index.ts << 'EOF'
import Fastify from 'fastify';
import { config } from '@deadw3/config';

const server = Fastify({
  logger: {
    level: config.LOG_LEVEL,
    transport: config.NODE_ENV === 'development' ? {
      target: 'pino-pretty',
      options: {
        colorize: true,
      },
    } : undefined,
  },
});

server.get('/health', async () => {
  return { 
    status: 'ok', 
    timestamp: new Date().toISOString(),
    environment: config.NODE_ENV,
  };
});

const start = async (): Promise<void> => {
  try {
    await server.listen({ port: config.PORT, host: '0.0.0.0' });
    server.log.info(`API server listening on port ${config.PORT}`);
  } catch (err) {
    server.log.error(err);
    process.exit(1);
  }
};

start().catch(console.error);
EOF

# Indexer package
cat > packages/indexer/src/index.ts << 'EOF'
import pino from 'pino';
import { config } from '@deadw3/config';

const logger = pino({
  level: config.LOG_LEVEL,
  transport: config.NODE_ENV === 'development' ? {
    target: 'pino-pretty',
    options: {
      colorize: true,
    },
  } : undefined,
});

logger.info('Indexer worker starting...');
logger.info({ arweaveGateway: config.ARWEAVE_GATEWAY }, 'Configuration loaded');

// Main indexer loop will go here
async function main(): Promise<void> {
  logger.info('Indexer initialized and ready');
  // TODO: Implement indexing logic
}

main().catch((err) => {
  logger.error(err, 'Indexer failed to start');
  process.exit(1);
});
EOF

print_success "Source files created"

# Step 9: Create .env.example
print_step "Creating .env.example..."
cat > .env.example << 'EOF'
# Node environment
NODE_ENV=development

# Database
DATABASE_URL=postgresql://deadw3:deadw3@localhost:5432/deadw3?schema=public

# Redis (optional)
REDIS_URL=redis://localhost:6379

# Arweave
ARWEAVE_GATEWAY=https://arweave.net

# Base L2
BASE_RPC_URL=https://sepolia.base.org

# API
PORT=3000
LOG_LEVEL=info
EOF
print_success ".env.example created"

# Step 10: Install dependencies
print_step "Installing dependencies (this may take a few minutes)..."
if command -v pnpm &> /dev/null; then
    pnpm install
    print_success "Dependencies installed"
else
    echo "⚠️  pnpm not found. Please install it with: npm install -g pnpm"
    echo "   Then run: pnpm install"
fi

# Step 11: Initialize Husky
print_step "Setting up git hooks..."
if [ -d "node_modules" ]; then
    pnpm exec husky install
    pnpm exec husky add .husky/pre-commit "pnpm exec lint-staged"
    chmod +x .husky/pre-commit
    print_success "Git hooks configured"
else
    echo "⚠️  Skipping Husky setup (run 'pnpm install' first)"
fi

# Step 12: Create initial README
print_step "Creating README.md..."
cat > README.md << 'EOF'
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
EOF
print_success "README.md created"

echo ""
echo -e "${GREEN}✨ Setup complete!${NC}"
echo "Next steps:"
echo "  1. Copy .env.example to .env and configure it"
echo "  2. Run 'pnpm install' if dependencies weren't installed"
echo "  3. Set up your database with 'cd packages/database && pnpm db:generate && pnpm db:migrate'"
echo "  4. Start developing with 'pnpm dev'"
