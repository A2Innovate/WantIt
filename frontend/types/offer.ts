import type { User } from './user';
import type { Comment } from './comment';

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
  comments: Comment[];
  createdAt: string;
}
