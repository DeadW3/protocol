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
