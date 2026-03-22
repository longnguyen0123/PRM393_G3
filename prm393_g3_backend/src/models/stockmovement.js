import mongoose from 'mongoose';

const stockMovementItemSchema = new mongoose.Schema(
  {
    variantId: { type: mongoose.Schema.Types.ObjectId, ref: 'Variant', required: true },
    quantity: { type: Number, required: true },
  },
  { _id: false },
);

const stockMovementSchema = new mongoose.Schema(
  {
    type: { type: String, enum: ['IN', 'OUT', 'TRANSFER'], required: true },
    status: {
      type: String,
      enum: ['PENDING', 'COMPLETED', 'REJECTED'],
      default: 'COMPLETED',
    },
    fromBranchId: { type: mongoose.Schema.Types.ObjectId, ref: 'Branch', default: null },
    toBranchId: { type: mongoose.Schema.Types.ObjectId, ref: 'Branch', default: null },
    createdBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    reviewedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User', default: null },
    reviewedAt: { type: Date, default: null },
    rejectionReason: { type: String, default: null },
    note: { type: String },
    items: [stockMovementItemSchema],
  },
  { timestamps: true },
);

const StockMovement = mongoose.model('StockMovement', stockMovementSchema);
export default StockMovement;
