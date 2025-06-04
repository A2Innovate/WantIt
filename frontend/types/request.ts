import type { User } from './user';
import type { Offer } from './offer';

export interface Request {
  id: number;
  content: string;
  user: Omit<User, 'email' | 'preferredCurrency' | 'sessionId' | 'isAdmin'>;
  budget: number;
  currency: string;
  location: {
    x: number;
    y: number;
  } | null;
  radius: number | null;
  offers: Offer[];
  createdAt: string;
}
