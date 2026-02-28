const mongoose = require('mongoose');

const stockMovementItemSchema = new mongoose.Schema({
  variantId: { type: mongoose.Schema.Types.ObjectId, ref: 'Variant', required: true },
  quantity: { type: Number, required: true }
}, { _id: false });

const stockMovementSchema = new mongoose.Schema({
  type: { type: String, enum: ['IN', 'OUT', 'TRANSFER'], required: true },
  fromBranchId: { type: mongoose.Schema.Types.ObjectId, ref: 'Branch', default: null },
  toBranchId: { type: mongoose.Schema.Types.ObjectId, ref: 'Branch', default: null },
  createdBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  note: { type: String },
  items: [stockMovementItemSchema]
}, { timestamps: true });

module.exports = mongoose.model('StockMovement', stockMovementSchema);