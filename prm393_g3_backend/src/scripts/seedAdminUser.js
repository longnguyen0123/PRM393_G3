/**
 * Script tạo user admin mẫu (chạy một lần để có tài khoản đăng nhập).
 * Chạy: node src/scripts/seedAdminUser.js
 * (Cần có MONGO_URI trong .env)
 */
import mongoose from 'mongoose';
import bcrypt from 'bcrypt';
import dotenv from 'dotenv';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';
import User from '../models/users.js';

const __dirname = dirname(fileURLToPath(import.meta.url));
dotenv.config({ path: join(__dirname, '../../.env') });

async function seed() {
  await mongoose.connect(process.env.MONGO_URI, { dbName: process.env.MONGO_DB_NAME });
  const passwordHash = await bcrypt.hash('admin123', 10);
  const result = await User.updateOne(
    { username: 'admin' },
    {
      $set: {
        passwordHash,
        fullName: 'Administrator',
        role: 'ADMIN',
        status: 'ACTIVE',
      },
    },
  );
  if (result.matchedCount > 0) {
    console.log('Đã cập nhật mật khẩu admin (bcrypt). Đăng nhập: admin / admin123');
  } else {
    await User.create({
      username: 'admin',
      passwordHash,
      fullName: 'Administrator',
      role: 'ADMIN',
      status: 'ACTIVE',
    });
    console.log('Đã tạo user admin. Đăng nhập: admin / admin123');
  }
  await mongoose.disconnect();
}

seed().catch((e) => {
  console.error(e);
  process.exit(1);
});
