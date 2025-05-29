import type { User } from './user';
import type { Offer } from './offer';

export interface Request {
  id: number;
  content: string;
  user: Omit<User, 'email'>;
  budget: number;
  currency: string;
  offers: Offer[];
}
