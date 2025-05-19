export interface Offer {
  id: number;
  requestId: number;
  user: {
    name: string;
  };
  content: string;
  price: number;
  negotiation: boolean;
}
