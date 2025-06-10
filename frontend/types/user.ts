export interface User {
  id: number;
  name: string;
  username: string;
  email: string;
  preferredCurrency: string;
  sessionId: number;
  isAdmin: boolean;
  isBlocked: boolean;
}

export interface UserSession {
  id: number;
  ip: string;
  expiresAt: Date;
}
