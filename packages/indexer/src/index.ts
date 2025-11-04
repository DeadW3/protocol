import pino from 'pino';
import { config } from '@deadw3/config';

// eslint-disable-next-line @typescript-eslint/no-unsafe-assignment
const logger = pino({
  // eslint-disable-next-line @typescript-eslint/no-unsafe-assignment, @typescript-eslint/no-unsafe-member-access
  level: config.LOG_LEVEL,
  // eslint-disable-next-line @typescript-eslint/no-unsafe-member-access
  transport:
    config.NODE_ENV === 'development'
      ? {
          target: 'pino-pretty',
          options: {
            colorize: true,
          },
        }
      : undefined,
});

logger.info('Indexer worker starting...');
// eslint-disable-next-line @typescript-eslint/no-unsafe-assignment, @typescript-eslint/no-unsafe-member-access
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
