export type ContractType = 'hourly' | 'daily' | 'weekly' | 'monthly';

/**
 * تسعير واحد يستخدمه الخادم والتطبيق — يمنع اختلاف المبلغ بين الواجهة
 * والفاتورة. الأسعار بالريال/الدولار حسب عملة المنصة.
 */
export function computePrice(
  hourlyRate: number,
  contractType: ContractType,
  hours: number,
): number {
  const rate = Math.max(0, hourlyRate);
  const safeHours = Math.max(1, Math.min(24, Math.round(hours)));
  switch (contractType) {
    case 'hourly':
      return round2(rate * safeHours);
    case 'daily':
      return round2(rate * 8);
    case 'weekly':
      return round2(rate * 8 * 5 * 0.9);
    case 'monthly':
      return round2(rate * 8 * 22 * 0.8);
  }
}

function round2(value: number): number {
  return Math.round(value * 100) / 100;
}
