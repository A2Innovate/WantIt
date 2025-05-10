import type { User } from './user';

export interface Request {
  id: number;
  content: string;
  user: User;
}
