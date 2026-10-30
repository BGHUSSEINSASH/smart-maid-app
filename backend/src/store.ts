import fs from 'fs';
import path from 'path';
import bcrypt from 'bcryptjs';

export type AppRole = 'customer' | 'worker' | 'admin' | 'company';

export interface User {
  id: string;
  name: string;
  email: string;
  role: AppRole;
  passwordHash: string;
  phone?: string;
  suspended?: boolean;
  suspendReason?: string;
  createdAt: string;
}

export interface Worker {
  id: string;
  userId?: string;
  name: string;
  city: string;
  category: string;
  experienceYears: number;
  hourlyRate: number;
  bio: string;
  available: boolean;
}

export interface Booking {
  id: string;
  userId: string;
  workerId: string;
  contractType: 'hourly' | 'daily' | 'weekly' | 'monthly';
  hours: number;
  scheduledFor: string;
  addressId?: string;
  notes?: string;
  total: number;
  paymentMethod: 'cash' | 'card';
  status: 'pending' | 'accepted' | 'rejected' | 'completed' | 'cancelled';
  paymentStatus: 'unpaid' | 'paid' | 'refunded';
  paymentIntentId?: string;
  createdAt: string;
}

export interface ChatMessage {
  id: string;
  bookingId: string;
  senderId: string;
  body: string;
  createdAt: string;
}

export interface WalletTransaction {
  id: string;
  userId: string;
  title: string;
  amount: number;
  type: 'topup' | 'payment' | 'withdrawal' | 'earning' | 'refund';
  createdAt: string;
}

export interface LoyaltyRecord {
  points: number;
  history: { title: string; points: number; at: string }[];
}

export interface Coupon {
  code: string;
  title: string;
  discountPercent: number;
  minTotal: number;
  firstBookingOnly?: boolean;
}

export interface LoyaltyCoupon {
  code: string;
  userId: string;
  discountPercent: number;
  minTotal: number;
  used: boolean;
  createdAt: string;
}

export interface Review {
  id: string;
  workerId: string;
  userId: string;
  bookingId: string;
  rating: number;
  comment: string;
  createdAt: string;
}

export interface Address {
  id: string;
  userId: string;
  label: string;
  city: string;
  details: string;
  isDefault: boolean;
}

export interface AppNotification {
  id: string;
  userId?: string;
  title: string;
  body: string;
  icon: string;
  read: boolean;
  createdAt: string;
}

// ─────────────────────────────────────────────────────────────
// Persistence
// ─────────────────────────────────────────────────────────────
// البيانات تُحفظ في ملف JSON داخل مجلد البيانات، فتبقى بعد إعادة
// التشغيل أو إعادة النشر. على منصات بلا قرص دائم (Vercel serverless)
// اضبط DATA_FILE على قرص دائم أو استبدل هذا الملف بقاعدة بيانات.
const dataFile =
  process.env.DATA_FILE ?? path.join(process.cwd(), 'data', 'db.json');

interface Snapshot {
  users: User[];
  workers: Worker[];
  bookings: Booking[];
  messages: ChatMessage[];
  walletTransactions: WalletTransaction[];
  loyalty: Record<string, LoyaltyRecord>;
  loyaltyCoupons: LoyaltyCoupon[];
  reviews: Review[];
  addresses: Address[];
  notifications: AppNotification[];
}

export let users: User[] = [];
export let workers: Worker[] = [];
export let bookings: Booking[] = [];
export let messages: ChatMessage[] = [];
export let walletTransactions: WalletTransaction[] = [];
export const loyaltyByUser = new Map<string, LoyaltyRecord>();
export let loyaltyCoupons: LoyaltyCoupon[] = [];
export let reviews: Review[] = [];
export let addresses: Address[] = [];
export let notifications: AppNotification[] = [];

export const coupons: Coupon[] = [
  { code: 'SMART50', title: 'خصم النصف', discountPercent: 50, minTotal: 50 },
  { code: 'SAVE15', title: 'وفّر 15%', discountPercent: 15, minTotal: 30 },
  {
    code: 'MONTHLY10',
    title: 'باقة الشهر',
    discountPercent: 10,
    minTotal: 200,
    firstBookingOnly: true,
  },
];

export const MAX_BOOKING_AMOUNT = Number(
  process.env.MAX_BOOKING_AMOUNT ?? 2000,
);

function emptySnapshot(): Snapshot {
  return {
    users: [],
    workers: [],
    bookings: [],
    messages: [],
    walletTransactions: [],
    loyalty: {},
    loyaltyCoupons: [],
    reviews: [],
    addresses: [],
    notifications: [],
  };
}

function readSnapshot(): Snapshot {
  try {
    const raw = fs.readFileSync(dataFile, 'utf8');
    const parsed = JSON.parse(raw) as Partial<Snapshot>;
    return { ...emptySnapshot(), ...parsed };
  } catch {
    return emptySnapshot();
  }
}

function applySnapshot(snapshot: Snapshot): void {
  users = snapshot.users ?? [];
  workers = snapshot.workers ?? [];
  bookings = snapshot.bookings ?? [];
  messages = snapshot.messages ?? [];
  walletTransactions = snapshot.walletTransactions ?? [];
  reviews = snapshot.reviews ?? [];
  addresses = snapshot.addresses ?? [];
  notifications = snapshot.notifications ?? [];
  loyaltyCoupons = snapshot.loyaltyCoupons ?? [];
  loyaltyByUser.clear();
  for (const [userId, record] of Object.entries(snapshot.loyalty ?? {})) {
    loyaltyByUser.set(userId, record);
  }
}

/** يحفظ كل البيانات على القرص. يُستدعى بعد أي عملية كتابة. */
export function persist(): void {
  const snapshot: Snapshot = {
    users,
    workers,
    bookings,
    messages,
    walletTransactions,
    loyalty: Object.fromEntries(loyaltyByUser),
    loyaltyCoupons,
    reviews,
    addresses,
    notifications,
  };
  try {
    fs.mkdirSync(path.dirname(dataFile), { recursive: true });
    const tmp = `${dataFile}.tmp`;
    fs.writeFileSync(tmp, JSON.stringify(snapshot, null, 2), 'utf8');
    fs.renameSync(tmp, dataFile);
  } catch (error) {
    // eslint-disable-next-line no-console
    console.error('Failed to persist database:', error);
  }
}

/** يشغّل بيانات أولية للتطوير المحلي فقط — لا في الإنتاج. */
function seedDevelopmentData(): void {
  if (process.env.NODE_ENV === 'production') return;
  if (users.length > 0) return;

  const devPassword = process.env.DEV_SEED_PASSWORD;
  if (!devPassword) {
    // eslint-disable-next-line no-console
    console.warn(
      'No DEV_SEED_PASSWORD set — skipping demo accounts. Register through the API instead.',
    );
    return;
  }

  const now = new Date().toISOString();
  const seed: Array<[string, string, AppRole]> = [
    ['customer@example.com', 'عميل تجريبي', 'customer'],
    ['worker@example.com', 'عاملة تجريبية', 'worker'],
    ['company@example.com', 'شركة تنظيف', 'company'],
  ];
  for (const [email, name, role] of seed) {
    users.push({
      id: `u_${role}_${Math.random().toString(36).slice(2, 8)}`,
      name,
      email,
      role,
      passwordHash: bcrypt.hashSync(devPassword, 10),
      createdAt: now,
    });
  }
  if (!users.some((u) => u.role === 'admin')) {
    users.push({
      id: 'u_admin_dev',
      name: 'إدارة المنصة',
      email: 'admin@example.com',
      role: 'admin',
      passwordHash: bcrypt.hashSync(devPassword, 10),
      createdAt: now,
    });
  }
}

function seedWorkers(): void {
  if (workers.length > 0) return;
  // كتالوج العاملات يُدار من لوحة الإدارة؛ لا تقييمات ولا صور مُختلقة.
  workers = [
    {
      id: 'w_cleaning_1',
      name: 'فريق التنظيف المنزلي',
      city: 'الرياض',
      category: 'تنظيف منزلي',
      experienceYears: 0,
      hourlyRate: 25,
      bio: 'تنظيف شامل للمنزل: غرف، مطبخ، حمّامات.',
      available: true,
    },
    {
      id: 'w_care_1',
      name: 'فريق رعاية الأطفال',
      city: 'الرياض',
      category: 'رعاية أطفال',
      experienceYears: 0,
      hourlyRate: 30,
      bio: 'رعاية الأطفال داخل المنزل حسب ساعات متفق عليها.',
      available: true,
    },
    {
      id: 'w_cooking_1',
      name: 'فريق الطبخ المنزلي',
      city: 'جدة',
      category: 'طبخ منزلي',
      experienceYears: 0,
      hourlyRate: 28,
      bio: 'إعداد وجبات منزلية يومية أو أسبوعية.',
      available: true,
    },
  ];
}

function bootstrap(): void {
  applySnapshot(readSnapshot());
  seedDevelopmentData();
  seedWorkers();
  // المدير في الإنتاج يُنشأ من متغيرات البيئة فقط.
  const adminEmail = process.env.ADMIN_EMAIL;
  const adminPassword = process.env.ADMIN_PASSWORD;
  if (
    process.env.NODE_ENV === 'production' &&
    adminEmail &&
    adminPassword &&
    !users.some((u) => u.role === 'admin')
  ) {
    users.push({
      id: `u_admin_${Date.now()}`,
      name: process.env.ADMIN_NAME ?? 'إدارة المنصة',
      email: adminEmail,
      role: 'admin',
      passwordHash: bcrypt.hashSync(adminPassword, 10),
      createdAt: new Date().toISOString(),
    });
    persist();
  }
}

bootstrap();

// ─────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────

export function getWalletBalance(userId: string): number {
  return walletTransactions
    .filter((t) => t.userId === userId)
    .reduce((sum, t) => sum + t.amount, 0);
}

export function loyaltyFor(userId: string): LoyaltyRecord {
  return loyaltyByUser.get(userId) ?? { points: 0, history: [] };
}

/** متوسط تقييم العاملة من التقييمات الحقيقية فقط. */
export function workerRating(workerId: string): {
  rating: number;
  count: number;
} {
  const list = reviews.filter((r) => r.workerId === workerId);
  if (list.length === 0) return { rating: 0, count: 0 };
  const sum = list.reduce((acc, r) => acc + r.rating, 0);
  return { rating: Number((sum / list.length).toFixed(1)), count: list.length };
}

export async function createUser(input: {
  name: string;
  email: string;
  password: string;
  role: AppRole;
}): Promise<User> {
  const user: User = {
    id: `u_${Date.now()}_${Math.random().toString(36).slice(2, 6)}`,
    name: input.name,
    email: input.email,
    role: input.role,
    passwordHash: await bcrypt.hash(input.password, 10),
    createdAt: new Date().toISOString(),
  };
  users.push(user);
  persist();
  return user;
}

export async function updateUserPassword(
  user: User,
  newPassword: string,
): Promise<void> {
  user.passwordHash = await bcrypt.hash(newPassword, 10);
  persist();
}

/** يحذف المستخدم وكل بياناته المرتبطة (متطلب Apple 5.1.1(v)). */
export function deleteUserData(userId: string): void {
  users = users.filter((u) => u.id !== userId);
  bookings = bookings.filter((b) => b.userId !== userId);
  messages = messages.filter((m) => m.senderId !== userId);
  walletTransactions = walletTransactions.filter((t) => t.userId !== userId);
  loyaltyByUser.delete(userId);
  loyaltyCoupons = loyaltyCoupons.filter((c) => c.userId !== userId);
  reviews = reviews.filter((r) => r.userId !== userId);
  addresses = addresses.filter((a) => a.userId !== userId);
  notifications = notifications.filter((n) => n.userId !== userId);
  workers = workers.filter((w) => w.userId !== userId);
  persist();
}

export function findUserById(id: string): User | undefined {
  return users.find((u) => u.id === id);
}

export function findUserByEmail(email: string): User | undefined {
  return users.find((u) => u.email.toLowerCase() === email.toLowerCase());
}

export function makeId(prefix: string): string {
  return `${prefix}_${Date.now()}_${Math.random().toString(36).slice(2, 6)}`;
}
