export interface User {
  id: number;
  name: string;
  username: string;
  email: string;
  preferredCurrency: string;
  sessionId: number;
}

export interface UserSession {
  id: number;
  ip: string;
  expiresAt: Date;
}
