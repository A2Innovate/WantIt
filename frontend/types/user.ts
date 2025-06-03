export interface User {
  id: number;
  name: string;
  username: string;
  email: string;
  preferredCurrency: string;
}

export interface UserSession {
  id: number;
  expiresAt: Date;
}
