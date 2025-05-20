import type { User } from './user';

export interface Offer {
  id: number;
  requestId: number;
  user: Omit<User, 'email'>;
  content: string;
  price: number;
  negotiation: boolean;
}
