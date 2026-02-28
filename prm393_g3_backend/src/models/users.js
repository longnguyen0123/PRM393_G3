const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  username: { type: String, required: true, unique: true },
  passwordHash: { type: String, required: true },
  fullName: { type: String, required: true },
  role: { 
    type: String, 
    enum: ['ADMIN', 'BRANCH_MANAGER', 'CASHIER', 'INVENTORY_STAFF'], 
    required: true 
  },
  branchId: { type: mongoose.Schema.Types.ObjectId, ref: 'Branch', default: null }, // Admin có thể null
  status: { type: String, enum: ['ACTIVE', 'INACTIVE'], default: 'ACTIVE' }
}, { timestamps: true });

module.exports = mongoose.model('User', userSchema);