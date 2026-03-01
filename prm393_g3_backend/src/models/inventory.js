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

const Inventory = mongoose.model('Inventory', inventorySchema, 'Inventory');

export default Inventory;