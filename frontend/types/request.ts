import type { User } from './user';
import type { Offer } from './offer';

export interface Request {
  id: number;
  content: string;
  user: Omit<User, 'email' | 'preferredCurrency'>;
  budget: number;
  currency: string;
  offers: Offer[];
  category: string;
}
