import { createPublicClient, http, type Address } from 'viem';
import { base } from 'viem/chains';
import { config } from '@deadw3/config';

export class ClankerClient {
  private client;

  constructor(rpcUrl?: string) {
    this.client = createPublicClient({
      chain: base,
      // eslint-disable-next-line @typescript-eslint/no-unsafe-argument, @typescript-eslint/no-unsafe-member-access
      transport: http(rpcUrl ?? config.BASE_RPC_URL),
    });
  }

  // eslint-disable-next-line class-methods-use-this
  async deployToken(_params: {
    name: string;
    symbol: string;
    initialSupply: bigint;
  }): Promise<Address> {
    // TODO: Implement actual Clanker SDK integration
    // For now, this is a placeholder
    // eslint-disable-next-line @typescript-eslint/no-unused-expressions
    this.client;
    throw new Error('Not implemented: Clanker SDK integration pending');
  }

  // eslint-disable-next-line class-methods-use-this
  async getTokenInfo(_tokenAddress: Address): Promise<unknown> {
    // TODO: Implement token info fetching
    // eslint-disable-next-line @typescript-eslint/no-unused-expressions
    this.client;
    throw new Error('Not implemented');
  }
}

export * from './types';
