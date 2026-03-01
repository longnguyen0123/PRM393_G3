import mongoose from 'mongoose';

const productSchema = new mongoose.Schema(
  {
    name: { type: String, required: true },
    // Use string codes like "brand_001", "category_001" to match existing data
    brandId: { type: String, ref: 'brand', required: true },
    categoryId: { type: String, ref: 'categories', required: true },
    description: { type: String },
    status: { type: String, enum: ['ACTIVE', 'INACTIVE'], default: 'ACTIVE' },
  },
  { timestamps: true },
);

// Use default collection name 'products' (matches MongoDB)
const Product = mongoose.model('product', productSchema);

export default Product;