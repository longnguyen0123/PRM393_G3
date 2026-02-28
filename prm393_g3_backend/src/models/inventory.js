const mongoose = require('mongoose');

const inventorySchema = new mongoose.Schema({
  branchId: { type: mongoose.Schema.Types.ObjectId, ref: 'Branch', required: true },
  variantId: { type: mongoose.Schema.Types.ObjectId, ref: 'Variant', required: true },
  quantity: { type: Number, required: true, default: 0 },
  reorderLevel: { type: Number, default: 2 }
}, { timestamps: true });

// Đảm bảo không có việc trùng lặp 1 variant trong cùng 1 chi nhánh
inventorySchema.index({ branchId: 1, variantId: 1 }, { unique: true });

module.exports = mongoose.model('Inventory', inventorySchema);