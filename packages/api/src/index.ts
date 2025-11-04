import Fastify from 'fastify';
import { config } from '@deadw3/config';

// eslint-disable-next-line @typescript-eslint/no-unsafe-assignment
const server = Fastify({
  logger: {
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
  },
});

server.get('/health', async () => ({
  status: 'ok',
  timestamp: new Date().toISOString(),
  // eslint-disable-next-line @typescript-eslint/no-unsafe-assignment, @typescript-eslint/no-unsafe-member-access
  environment: config.NODE_ENV,
}));

const start = async (): Promise<void> => {
  try {
    // eslint-disable-next-line @typescript-eslint/no-unsafe-assignment, @typescript-eslint/no-unsafe-member-access
    await server.listen({
      // eslint-disable-next-line @typescript-eslint/no-unsafe-assignment, @typescript-eslint/no-unsafe-member-access
      port: config.PORT,
      host: '0.0.0.0',
    });
    // eslint-disable-next-line @typescript-eslint/no-unsafe-member-access
    server.log.info(`API server listening on port ${config.PORT}`);
  } catch (err) {
    server.log.error(err);
    process.exit(1);
  }
};

start().catch(console.error);
