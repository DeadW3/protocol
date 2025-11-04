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
