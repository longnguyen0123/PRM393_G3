import mongoose from 'mongoose';

const variantSchema = new mongoose.Schema(
  {
    // align with existing data: often productId is a string code like 'product_001'
    productId: { type: String, required: true },
    sku: { type: String, required: true, unique: true },
    barcode: { type: String, unique: true },
    price: { type: Number, required: true },
    status: { type: String, enum: ['ACTIVE', 'INACTIVE'], default: 'ACTIVE' },
  },
  { timestamps: true },
);

// Explicitly map to 'variants' collection
const Variant = mongoose.model('variant', variantSchema, 'variants');

export default Variant;