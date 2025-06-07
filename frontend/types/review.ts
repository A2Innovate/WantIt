import type { User } from './user';

export interface Review {
  id: number;
  reviewer: Pick<User, 'id' | 'name' | 'username'>;
  content: string;
  rating: number;
  edited: boolean;
  createdAt: string;
}
