import mongoose from 'mongoose';

export async function connectMongo() {
  const mongoUri = process.env.MONGO_URI;
  if (!mongoUri) {
    console.warn('MONGO_URI is not set. Skipping MongoDB connection.');
    return;
  }

  mongoose.set('strictQuery', true);

  await mongoose.connect(mongoUri, {
    dbName: process.env.MONGO_DB_NAME,
  });

  console.log('MongoDB connected');
}

