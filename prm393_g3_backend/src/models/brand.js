import mongoose from 'mongoose';

const brandSchema = new mongoose.Schema(
  {
    _id: { type: String, required: true },
    name: { type: String, required: true },
  },
  {
    timestamps: true,
    _id: false, // we define _id manually as String
  },
);

// Explicitly map to the 'brands' collection
const Brand = mongoose.model('brand', brandSchema, 'brands');

export default Brand;