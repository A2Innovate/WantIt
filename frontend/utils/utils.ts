export function priceFmt(price: number, currency: string) {
  return price.toLocaleString('en-US', {
    style: 'currency',
    currency
  });
}
