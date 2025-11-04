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
