import mongoose from 'mongoose';

const brandSchema = new mongoose.Schema(
  {
    name: { type: String, required: true },
    status: { type: String, enum: ['ACTIVE', 'INACTIVE'], default: 'ACTIVE' },
  },
  { timestamps: true },
);

// Explicitly map to the 'brands' collection
const Brand = mongoose.model('brand', brandSchema, 'brands');

export default Brand;