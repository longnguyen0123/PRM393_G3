import mongoose from 'mongoose';

const storeSchema = new mongoose.Schema(
  {
    name: { type: String, required: true, trim: true },
    location: { type: String, required: true, trim: true },
  },
  { timestamps: true }
);

export const StoreModel = mongoose.model('Store', storeSchema);
