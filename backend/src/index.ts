import dotenv from 'dotenv';
import { createServer } from './app';

dotenv.config();

const port = Number(process.env.PORT ?? 4000);

const server = createServer();
server.listen(port, () => {
  // eslint-disable-next-line no-console
  console.log(`API listening on http://localhost:${port}`);
});

export { server };
