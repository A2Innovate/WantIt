import type { User } from './user';

export interface Offer {
  id: number;
  requestId: number;
  user: Omit<User, 'email' | 'preferredCurrency'>;
  content: string;
  price: number;
  negotiation: boolean;
  images: {
    name: string;
  }[];
}
