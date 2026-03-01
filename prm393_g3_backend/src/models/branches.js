import mongoose from 'mongoose';

const branchSchema = new mongoose.Schema(
  {
    name: { type: String, required: true },
    address: { type: String, required: true },
    status: { type: String, enum: ['ACTIVE', 'INACTIVE'], default: 'ACTIVE' }
  },
  { timestamps: true }
);

// Map to collection 'branches' (lowercase, plural) in MongoDB
const Branch = mongoose.model('Branch', branchSchema, 'branches');

export default Branch;