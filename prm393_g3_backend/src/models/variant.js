import mongoose from 'mongoose';

const variantSchema = new mongoose.Schema(
  {
    productId: { type: mongoose.Schema.Types.ObjectId, ref: 'product', required: true },
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