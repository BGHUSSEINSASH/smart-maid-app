import dotenv from 'dotenv';
import { createServer } from './app';

dotenv.config();

const port = Number(process.env.PORT ?? 4000);

// رفض الإقلاع بدون سرّ JWT في الإنتاج — الأمان أهم من التشغيل.
if (process.env.NODE_ENV === 'production' && !process.env.JWT_SECRET) {
  // eslint-disable-next-line no-console
  console.error(
    'FATAL: JWT_SECRET is not set. Refusing to start in production.',
  );
  process.exit(1);
}

const server = createServer();
server.listen(port, () => {
  // eslint-disable-next-line no-console
  console.log(`API listening on http://localhost:${port}`);
});

export { server };
