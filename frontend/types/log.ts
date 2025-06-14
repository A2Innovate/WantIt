import type { User } from './user';

export interface Log {
  id: number;
  type: string;
  user?: Pick<User, 'id' | 'name' | 'username'>;
  ip?: string;
  content?: string;
  createdAt: string;
}
