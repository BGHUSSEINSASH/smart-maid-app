import { createServer } from '../backend/src/app';

// Vercel serverless entrypoint — يعيد استخدام نفس تطبيق Express.
// يتم توجيه كل المسارات عبر vercel.json rewrite إلى هذه الدالة.
export default createServer();
