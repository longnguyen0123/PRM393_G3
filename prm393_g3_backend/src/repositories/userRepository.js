import mongoose from 'mongoose';
import User from '../models/users.js';

/**
 * Active branch manager assigned to this branch (users.branchId + role BRANCH_MANAGER).
 */
export const findBranchManagerByBranchId = async (branchId) => {
  if (!mongoose.Types.ObjectId.isValid(branchId)) {
    return null;
  }
  const bid = new mongoose.Types.ObjectId(branchId);
  return User.findOne({
    branchId: bid,
    role: 'BRANCH_MANAGER',
    status: 'ACTIVE',
  })
    .select('username fullName role status')
    .lean();
};
