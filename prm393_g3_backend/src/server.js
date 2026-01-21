import 'dotenv/config';
import app from './app.js';
import { connectMongo } from './config/db.js';

const PORT = process.env.PORT || 3000;

async function main() {
  await connectMongo();
  app.listen(PORT, () => {
    console.log(`Retail Chain API listening on http://localhost:${PORT}`);
  });
}

main().catch((err) => {
  console.error('Failed to start server:', err);
  process.exit(1);
});
