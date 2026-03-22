import mongoose from 'mongoose';
import User from '../models/users.js';

const toBranchOid = (branchId) => {
  if (!mongoose.Types.ObjectId.isValid(branchId)) return null;
  return new mongoose.Types.ObjectId(branchId);
};

/**
 * Branch managers có branch trong managedBranchIds hoặc legacy branchId.
 */
export const findBranchManagersByBranchId = async (branchId) => {
  const bid = toBranchOid(branchId);
  if (!bid) return [];
  return User.find({
    role: 'BRANCH_MANAGER',
    status: 'ACTIVE',
    $or: [{ managedBranchIds: bid }, { branchId: bid }],
  })
    .select('username fullName role status')
    .sort({ fullName: 1 })
    .lean();
};

export const findUserByIdLean = async (userId) => {
  if (userId == null || userId === '') return null;
  const id = String(userId);
  const select = 'username fullName role status branchId managedBranchIds';
  // Chuẩn Mongo ObjectId
  if (mongoose.Types.ObjectId.isValid(id)) {
    const byOid = await User.findById(id).select(select).lean();
    if (byOid) return byOid;
  }
  // Legacy / seed: _id là string (vd. "user_admin") — khớp comment trong authController
  return User.findOne({ _id: id }).select(select).lean();
};

export const detachBranchFromAllManagers = async (branchId) => {
  const bid = toBranchOid(branchId);
  if (!bid) return;
  await User.updateMany(
    { role: 'BRANCH_MANAGER' },
    { $pull: { managedBranchIds: bid } },
  );
  await User.updateMany(
    { role: 'BRANCH_MANAGER', branchId: bid },
    { $set: { branchId: null } },
  );
};

export const addManagedBranchToManager = async (userId, branchId) => {
  const uid = toBranchOid(userId);
  const bid = toBranchOid(branchId);
  if (!uid || !bid) return null;
  const user = await User.findById(uid);
  if (!user) return null;
  const idSet = new Set((user.managedBranchIds || []).map((x) => String(x)));
  idSet.add(String(bid));
  if (user.branchId) {
    idSet.add(String(user.branchId));
  }
  const merged = [...idSet].map((s) => new mongoose.Types.ObjectId(s));
  return User.findByIdAndUpdate(
    uid,
    {
      $set: {
        managedBranchIds: merged,
        role: 'BRANCH_MANAGER',
        branchId: null,
      },
    },
    { new: true, runValidators: true },
  )
    .select('username fullName role status managedBranchIds')
    .lean();
};

export const detachBranchFromManager = async (userId, branchId) => {
  const uid = toBranchOid(userId);
  const bid = toBranchOid(branchId);
  if (!uid || !bid) return null;
  const user = await User.findById(uid);
  if (!user) return null;
  user.managedBranchIds = (user.managedBranchIds || []).filter(
    (id) => String(id) !== String(bid),
  );
  if (user.role === 'BRANCH_MANAGER' && String(user.branchId) === String(bid)) {
    user.branchId = null;
  }
  await user.save();
  return User.findById(uid)
    .select('username fullName role status managedBranchIds')
    .lean();
};

export const listActiveBranchManagers = async () => {
  return User.find({
    role: 'BRANCH_MANAGER',
    status: 'ACTIVE',
  })
    .select('username fullName role status branchId managedBranchIds')
    .sort({ fullName: 1 })
    .lean();
};

export const listInventoryStaffByBranch = async (branchId) => {
  const bid = toBranchOid(branchId);
  if (!bid) return [];
  return User.find({
    role: 'INVENTORY_STAFF',
    branchId: bid,
  })
    .select('username fullName role status branchId')
    .sort({ fullName: 1 })
    .lean();
};

export const createInventoryStaffUser = async ({
  username,
  passwordHash,
  fullName,
  branchId,
}) => {
  const bid = toBranchOid(branchId);
  if (!bid) return null;
  try {
    return await User.create({
      username: username.trim(),
      passwordHash,
      fullName: fullName.trim(),
      role: 'INVENTORY_STAFF',
      branchId: bid,
      managedBranchIds: [],
      status: 'ACTIVE',
    });
  } catch {
    return null;
  }
};

export const listCashiersByBranch = async (branchId) => {
  const bid = toBranchOid(branchId);
  if (!bid) return [];
  return User.find({
    role: 'CASHIER',
    branchId: bid,
  })
    .select('username fullName role status branchId')
    .sort({ fullName: 1 })
    .lean();
};

export const createCashierUser = async ({
  username,
  passwordHash,
  fullName,
  branchId,
}) => {
  const bid = toBranchOid(branchId);
  if (!bid) return null;
  try {
    return await User.create({
      username: username.trim(),
      passwordHash,
      fullName: fullName.trim(),
      role: 'CASHIER',
      branchId: bid,
      managedBranchIds: [],
      status: 'ACTIVE',
    });
  } catch {
    return null;
  }
};

export const setCashierInactiveInBranch = async (userId, branchId) => {
  const uid = toBranchOid(userId);
  const bid = toBranchOid(branchId);
  if (!uid || !bid) return null;
  return User.findOneAndUpdate(
    { _id: uid, role: 'CASHIER', branchId: bid },
    { $set: { status: 'INACTIVE' } },
    { new: true, runValidators: true },
  )
    .select('username fullName role status branchId')
    .lean();
};

export const findUserByUsernameLean = async (username) => {
  if (!username?.trim()) return null;
  return User.findOne({ username: username.trim() }).select('_id').lean();
};

export const setInventoryStaffInactiveInBranch = async (userId, branchId) => {
  const uid = toBranchOid(userId);
  const bid = toBranchOid(branchId);
  if (!uid || !bid) return null;
  return User.findOneAndUpdate(
    { _id: uid, role: 'INVENTORY_STAFF', branchId: bid },
    { $set: { status: 'INACTIVE' } },
    { new: true, runValidators: true },
  )
    .select('username fullName role status branchId')
    .lean();
};

/** @deprecated dùng findBranchManagersByBranchId */
export const findBranchManagerByBranchId = async (branchId) => {
  const list = await findBranchManagersByBranchId(branchId);
  return list[0] ?? null;
};

/** Admin: tất cả BRANCH_MANAGER kèm chi nhánh (populate). */
export const listBranchManagersForAdmin = async () => {
  return User.find({ role: 'BRANCH_MANAGER' })
    .select('username fullName role status branchId managedBranchIds')
    .populate({ path: 'managedBranchIds', select: 'name' })
    .populate({ path: 'branchId', select: 'name' })
    .sort({ fullName: 1 })
    .lean();
};

/** Admin: tất cả INVENTORY_STAFF kèm chi nhánh. */
export const listInventoryStaffForAdmin = async () => {
  return User.find({ role: 'INVENTORY_STAFF' })
    .select('username fullName role status branchId')
    .populate({ path: 'branchId', select: 'name address' })
    .sort({ fullName: 1 })
    .lean();
};

/** Admin: đổi trạng thái ACTIVE / INACTIVE. */
export const setUserStatusById = async (userId, status) => {
  if (!mongoose.Types.ObjectId.isValid(userId)) {
    return null;
  }
  if (!['ACTIVE', 'INACTIVE'].includes(status)) {
    return null;
  }
  return User.findByIdAndUpdate(
    userId,
    { $set: { status } },
    { new: true, runValidators: true },
  )
    .select('username fullName role status')
    .lean();
};
