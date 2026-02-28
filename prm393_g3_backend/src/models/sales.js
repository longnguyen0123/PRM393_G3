const mongoose = require('mongoose');

const saleItemSchema = new mongoose.Schema({
  variantId: { type: mongoose.Schema.Types.ObjectId, ref: 'Variant', required: true },
  quantity: { type: Number, required: true },
  unitPrice: { type: Number, required: true },
  lineTotal: { type: Number, required: true }
}, { _id: false });

const saleSchema = new mongoose.Schema({
  branchId: { type: mongoose.Schema.Types.ObjectId, ref: 'Branch', required: true },
  cashierId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  paymentMethod: { type: String, enum: ['CASH', 'CARD', 'TRANSFER'], required: true },
  status: { type: String, enum: ['COMPLETED', 'PENDING', 'CANCELLED'], default: 'COMPLETED' },
  totalAmount: { type: Number, required: true },
  items: [saleItemSchema]
}, { timestamps: true });

module.exports = mongoose.model('Sale', saleSchema);