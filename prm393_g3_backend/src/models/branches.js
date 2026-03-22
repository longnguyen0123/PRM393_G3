import mongoose from 'mongoose';

const branchSchema = new mongoose.Schema(
  {
    name: { type: String, required: true },
    address: { type: String, required: true },
    status: { type: String, enum: ['ACTIVE', 'INACTIVE'], default: 'ACTIVE' },
    /** Admin bật: Branch Manager được quản lý nhân viên kho / kho tại chi nhánh này. */
    inventoryDelegatedToManager: { type: Boolean, default: false },
  },
  { timestamps: true }
);

// Map to collection 'branches' (lowercase, plural) in MongoDB
const Branch = mongoose.model('Branch', branchSchema, 'branches');

export default Branch;