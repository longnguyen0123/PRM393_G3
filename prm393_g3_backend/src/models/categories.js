import mongoose from 'mongoose';

const categorySchema = new mongoose.Schema(
  {
    name: { type: String, required: true },
    status: { type: String, enum: ['ACTIVE', 'INACTIVE'], default: 'ACTIVE' },
  },
  { timestamps: true },
);

// Explicitly map to the 'categories' collection
const Category = mongoose.model('categories', categorySchema, 'categories');

export default Category;