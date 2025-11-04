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
