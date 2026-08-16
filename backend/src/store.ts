export type AppRole = 'customer' | 'worker' | 'admin';

export interface User {
  id: string;
  name: string;
  email: string;
  password: string;
  role: AppRole;
}

export interface Worker {
  id: string;
  name: string;
  image: string;
  rating: number;
  experienceYears: number;
  hourlyRate: number;
}

export interface Booking {
  id: string;
  userId: string;
  workerId: string;
  contractType: 'hourly' | 'daily' | 'monthly';
  hours: number;
  notes?: string;
  total: number;
  status: 'pending' | 'accepted' | 'rejected' | 'completed';
  paymentStatus: 'pending' | 'processing' | 'succeeded' | 'failed';
  paymentIntentId?: string;
  createdAt: string;
}

export const users: User[] = [
  {
    id: 'u_customer_1',
    name: 'Demo User',
    email: 'user@example.com',
    password: 'Passw0rd!',
    role: 'customer',
  },
  {
    id: 'u_worker_1',
    name: 'Demo Worker',
    email: 'worker@example.com',
    password: 'Passw0rd!',
    role: 'worker',
  },
  {
    id: 'u_admin_1',
    name: 'Demo Admin',
    email: 'admin@example.com',
    password: 'Passw0rd!',
    role: 'admin',
  },
];

export const workers: Worker[] = [
  {
    id: 'w1',
    name: 'Maria',
    image: 'https://i.pravatar.cc/160?img=47',
    rating: 4.9,
    experienceYears: 7,
    hourlyRate: 32,
  },
  {
    id: 'w2',
    name: 'Anna',
    image: 'https://i.pravatar.cc/160?img=32',
    rating: 4.8,
    experienceYears: 6,
    hourlyRate: 29,
  },
  {
    id: 'w3',
    name: 'Nour',
    image: 'https://i.pravatar.cc/160?img=15',
    rating: 4.7,
    experienceYears: 5,
    hourlyRate: 27,
  },
];

export const bookings: Booking[] = [];

export function makeToken(user: User): string {
  return `demo-token-${user.id}`;
}

export function parseUserFromToken(token?: string): User | undefined {
  if (!token || !token.startsWith('demo-token-')) {
    return undefined;
  }

  const userId = token.replace('demo-token-', '');
  return users.find((user) => user.id === userId);
}
