import type { User } from './user';

export interface Comment {
  id: number;
  offerId?: number;
  content: string;
  createdAt: string;
  user: Omit<User, 'email' | 'preferredCurrency' | 'name'>;
}
