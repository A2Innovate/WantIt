export interface Alert {
  id: number;
  content: string;
  budget: number;
  currency: string;
  location: {
    x: number;
    y: number;
  };
  radius: number;
  budgetComparisonMode: string;
  createdAt: string;
}
