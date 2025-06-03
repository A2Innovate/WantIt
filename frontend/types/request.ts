import type { User } from './user';
import type { Offer } from './offer';

export interface Request {
  id: number;
  content: string;
  user: Omit<User, 'email' | 'preferredCurrency' | 'sessionId'>;
  budget: number;
  currency: string;
  location: {
    x: number;
    y: number;
  };
  radius: number;
  offers: Offer[];
}
