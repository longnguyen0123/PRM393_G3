import mongoose from 'mongoose';

const categorySchema = new mongoose.Schema(
  {
    _id: { type: String, required: true },
    name: { type: String, required: true },
  },
  {
    timestamps: true,
    _id: false, // we define _id manually as String
  },
);

// Explicitly map to the 'categories' collection
const Category = mongoose.model('categories', categorySchema, 'categories');

export default Category;