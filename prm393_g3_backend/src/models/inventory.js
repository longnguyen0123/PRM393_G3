import mongoose from 'mongoose';

const inventorySchema = new mongoose.Schema(
  {
    branchId: { type: String, required: true },
    variantId: { type: String, required: true },
    quantity: { type: Number, required: true },
    reorderLevel: { type: Number, required: true }
  },
  { timestamps: true }
);

// Map to collection 'inventory' (lowercase) in MongoDB
const Inventory = mongoose.model('Inventory', inventorySchema, 'inventory');

export default Inventory;