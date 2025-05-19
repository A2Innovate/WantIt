import type { User } from './user';
import type { Offer } from './offer';

export interface Request {
  id: number;
  content: string;
  user: User;
  budget: number;
  offers: Offer[];
}
