import mongoose from 'mongoose';

const productSchema = new mongoose.Schema(
  {
    name: { type: String, required: true, trim: true },
    price: { type: Number, required: true, min: 0 },
    stock: { type: Number, required: true, min: 0 },
    storeId: { type: mongoose.Schema.Types.ObjectId, ref: 'Store', required: true },
  },
  { timestamps: true }
);

export const ProductModel = mongoose.model('Product', productSchema);
