import mongoose from 'mongoose';

const userSchema = new mongoose.Schema({
  username: { type: String, required: true, unique: true },
  passwordHash: { type: String, required: true },
  fullName: { type: String, required: true },
  role: {
    type: String,
    enum: ['ADMIN', 'BRANCH_MANAGER', 'CASHIER', 'INVENTORY_STAFF'],
    required: true,
  },
  branchId: { type: mongoose.Schema.Types.ObjectId, ref: 'Branch', default: null },
  status: { type: String, enum: ['ACTIVE', 'INACTIVE'], default: 'ACTIVE' },
}, { timestamps: true });

const User = mongoose.model('User', userSchema, 'users');
export default User;