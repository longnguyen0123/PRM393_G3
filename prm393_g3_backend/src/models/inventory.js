import mongoose from 'mongoose';

const inventorySchema = new mongoose.Schema(
  {
    /** Luôn ObjectId trong DB (đồng bộ với Branch / Variant). */
    branchId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Branch',
      required: true,
    },
    variantId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'variant',
      required: true,
    },
    quantity: { type: Number, required: true },
    reorderLevel: { type: Number, required: true },
  },
  { timestamps: true },
);

// Map to collection 'inventory' (lowercase) in MongoDB
const Inventory = mongoose.model('Inventory', inventorySchema, 'inventory');

export default Inventory;