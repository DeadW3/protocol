#!/usr/bin/env node
/**
 * Generate manifest.json from Arweave upload transaction logs
 * 
 * Reads transaction receipt logs from bundle_to_arweave.ts and generates
 * a comprehensive manifest mapping Archive.org identifiers to Arweave transaction IDs.
 * 
 * Usage:
 *   npx tsx generate_manifest.ts [--input-dir=./logs] [--output=./manifest.json]
 */

import { readFile, readdir, writeFile } from 'fs/promises';
import { join, resolve } from 'path';

interface UploadTransaction {
  archiveId: string;
  arweaveTxId: string;
  date?: string;
  venue?: string;
  artist?: string;
  source?: string;
  bundleId?: string;
  uploadedAt?: string;
}

interface ManifestEntry {
  archiveId: string;
  arweaveTxId: string;
  arweaveUrl: string;
  archiveUrl?: string;
  metadata?: {
    date?: string;
    venue?: string;
    artist?: string;
    source?: string;
  };
}

interface Manifest {
  version: string;
  generatedAt: string;
  totalShows: number;
  entries: Record<string, ManifestEntry>;
}

const DEFAULT_INPUT_DIR = './data/upload-logs';
const DEFAULT_OUTPUT_FILE = './data/manifest.json';
const ARWEAVE_GATEWAY = 'https://arweave.net';
const ARCHIVE_ORG_BASE = 'https://archive.org/details';

/**
 * Parse command line arguments
 */
function parseArgs(): { inputDir: string; outputFile: string } {
  const args = process.argv.slice(2);
  let inputDir = DEFAULT_INPUT_DIR;
  let outputFile = DEFAULT_OUTPUT_FILE;

  for (const arg of args) {
    if (arg.startsWith('--input-dir=')) {
      inputDir = arg.split('=')[1];
    } else if (arg.startsWith('--output=')) {
      outputFile = arg.split('=')[1];
    } else if (arg === '--help' || arg === '-h') {
      console.log(`
Usage: generate_manifest.ts [OPTIONS]

Options:
  --input-dir=DIR    Directory containing transaction log files (default: ./data/upload-logs)
  --output=FILE      Output manifest file path (default: ./data/manifest.json)
  --help, -h         Show this help message

Example:
  npx tsx generate_manifest.ts --input-dir=./logs --output=./manifest.json
      `);
      process.exit(0);
    }
  }

  return { inputDir: resolve(inputDir), outputFile: resolve(outputFile) };
}

/**
 * Read and parse a transaction log file
 */
async function readTransactionLog(filePath: string): Promise<UploadTransaction[]> {
  try {
    const content = await readFile(filePath, 'utf-8');
    const data = JSON.parse(content);
    
    // Handle both single transaction and array of transactions
    if (Array.isArray(data)) {
      return data;
    } else if (data.transactions && Array.isArray(data.transactions)) {
      return data.transactions;
    } else if (data.archiveId && data.arweaveTxId) {
      return [data];
    }
    
    throw new Error(`Invalid transaction log format in ${filePath}`);
  } catch (error) {
    if (error instanceof SyntaxError) {
      throw new Error(`Failed to parse JSON in ${filePath}: ${error.message}`);
    }
    throw error;
  }
}

/**
 * Collect all transaction logs from a directory
 */
async function collectTransactions(inputDir: string): Promise<UploadTransaction[]> {
  const transactions: UploadTransaction[] = [];
  
  try {
    const files = await readdir(inputDir);
    const logFiles = files.filter((file: string) => 
      file.endsWith('.json') && !file.includes('manifest')
    );
    
    if (logFiles.length === 0) {
      console.warn(`Warning: No JSON log files found in ${inputDir}`);
      return transactions;
    }
    
    console.log(`Found ${logFiles.length} log file(s), reading transactions...`);
    
    for (const file of logFiles) {
      const filePath = join(inputDir, file);
      try {
        const fileTransactions = await readTransactionLog(filePath);
        transactions.push(...fileTransactions);
        console.log(`  ✓ ${file}: ${fileTransactions.length} transaction(s)`);
      } catch (error) {
        console.error(`  ✗ Error reading ${file}: ${error instanceof Error ? error.message : String(error)}`);
      }
    }
  } catch (error) {
    const err = error as { code?: string };
    if (err.code === 'ENOENT') {
      throw new Error(`Input directory not found: ${inputDir}`);
    }
    throw error;
  }
  
  return transactions;
}

/**
 * Convert transaction to manifest entry
 */
function transactionToEntry(tx: UploadTransaction): ManifestEntry {
  const entry: ManifestEntry = {
    archiveId: tx.archiveId,
    arweaveTxId: tx.arweaveTxId,
    arweaveUrl: `${ARWEAVE_GATEWAY}/${tx.arweaveTxId}`,
    archiveUrl: `${ARCHIVE_ORG_BASE}/${tx.archiveId}`,
  };
  
  // Include metadata if available
  if (tx.date || tx.venue || tx.artist || tx.source) {
    entry.metadata = {};
    if (tx.date) entry.metadata.date = tx.date;
    if (tx.venue) entry.metadata.venue = tx.venue;
    if (tx.artist) entry.metadata.artist = tx.artist;
    if (tx.source) entry.metadata.source = tx.source;
  }
  
  return entry;
}

/**
 * Generate manifest from transactions
 */
function generateManifest(transactions: UploadTransaction[]): Manifest {
  const entries: Record<string, ManifestEntry> = {};
  
  // Deduplicate by archiveId (keep latest if duplicates exist)
  const uniqueTransactions = new Map<string, UploadTransaction>();
  for (const tx of transactions) {
    if (!tx.archiveId || !tx.arweaveTxId) {
      console.warn(`Skipping invalid transaction: missing archiveId or arweaveTxId`);
      continue;
    }
    
    const existing = uniqueTransactions.get(tx.archiveId);
    if (!existing || (tx.uploadedAt && existing.uploadedAt && tx.uploadedAt > existing.uploadedAt)) {
      uniqueTransactions.set(tx.archiveId, tx);
    }
  }
  
  // Convert to manifest entries
  for (const tx of uniqueTransactions.values()) {
    entries[tx.archiveId] = transactionToEntry(tx);
  }
  
  return {
    version: '1.0.0',
    generatedAt: new Date().toISOString(),
    totalShows: Object.keys(entries).length,
    entries,
  };
}

/**
 * Write manifest to file
 */
async function writeManifest(manifest: Manifest, outputFile: string): Promise<void> {
  const json = JSON.stringify(manifest, null, 2);
  await writeFile(outputFile, json, 'utf-8');
  console.log(`\n✓ Manifest written to ${outputFile}`);
  console.log(`  Total shows: ${manifest.totalShows}`);
}

/**
 * Main execution
 */
async function main(): Promise<void> {
  try {
    const { inputDir, outputFile } = parseArgs();
    
    console.log(`Generating manifest from ${inputDir}...`);
    console.log(`Output: ${outputFile}\n`);
    
    const transactions = await collectTransactions(inputDir);
    
    if (transactions.length === 0) {
      console.error('Error: No transactions found. Cannot generate manifest.');
      process.exit(1);
    }
    
    const manifest = generateManifest(transactions);
    await writeManifest(manifest, outputFile);
    
  } catch (error) {
    console.error('Error:', error instanceof Error ? error.message : String(error));
    process.exit(1);
  }
}

// Run if executed directly
main();

export { generateManifest, transactionToEntry, type Manifest, type ManifestEntry, type UploadTransaction };
