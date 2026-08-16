"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.bookings = exports.workers = exports.users = void 0;
exports.makeToken = makeToken;
exports.parseUserFromToken = parseUserFromToken;
exports.users = [
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
exports.workers = [
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
exports.bookings = [];
function makeToken(user) {
    return `demo-token-${user.id}`;
}
function parseUserFromToken(token) {
    if (!token || !token.startsWith('demo-token-')) {
        return undefined;
    }
    const userId = token.replace('demo-token-', '');
    return exports.users.find((user) => user.id === userId);
}
