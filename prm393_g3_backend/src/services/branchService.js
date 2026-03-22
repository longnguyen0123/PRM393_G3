import mongoose from 'mongoose';
import {
  getAllBranches,
  getBranchById,
  createBranch as createBranchRepository,
  updateBranchById,
} from '../repositories/branchRepository.js';

import {
  getTotalStockByBranch,
  getInventoryLinesWithProductsForBranch,
} from '../repositories/inventoryRepository.js';
import {
  findBranchManagersByBranchId,
  findUserByIdLean,
  detachBranchFromAllManagers,
  addManagedBranchToManager,
  detachBranchFromManager,
  listActiveBranchManagers,
  listInventoryStaffByBranch,
  createInventoryStaffUser,
  findUserByUsernameLean,
  setInventoryStaffInactiveInBranch,
} from '../repositories/userRepository.js';
import bcrypt from 'bcrypt';

export const getAllBranchesWithStock = async () => {
  const branches = await getAllBranches();
  const stockData = await getTotalStockByBranch();

  const stockMap = {};
  stockData.forEach(item => {
    stockMap[item._id] = item.totalItemsInStock;
  });

  return branches.map(branch => ({
    ...branch,
    totalItemsInStock: stockMap[branch._id] || 0
  }));
};

/**
 * Danh sách chi nhánh theo quyền đăng nhập.
 * ADMIN: tất cả; BRANCH_MANAGER: managedBranchIds (+ legacy branchId);
 * CASHIER / INVENTORY_STAFF: chỉ chi nhánh branchId.
 */
export const getBranchesWithStockForRequester = async (authUser) => {
  const all = await getAllBranchesWithStock();
  if (!authUser?.userId) {
    const error = new Error('Unauthorized');
    error.status = 401;
    throw error;
  }
  if (authUser.role === 'ADMIN') {
    return all;
  }
  const user = await findUserByIdLean(authUser.userId);
  if (!user || user.status !== 'ACTIVE') {
    const error = new Error('Unauthorized');
    error.status = 401;
    throw error;
  }
  if (user.role === 'BRANCH_MANAGER') {
    const allowed = new Set(
      (user.managedBranchIds || []).map((id) => String(id)),
    );
    if (user.branchId) {
      allowed.add(String(user.branchId));
    }
    return all.filter((b) => allowed.has(String(b._id)));
  }
  if (user.role === 'CASHIER' || user.role === 'INVENTORY_STAFF') {
    if (!user.branchId) {
      return [];
    }
    const bid = String(user.branchId);
    return all.filter((b) => String(b._id) === bid);
  }
  return [];
};

export const createBranch = async (data) => {
  return await createBranchRepository(data);
};

export const updateBranch = async (id, data) => {
  const updated = await updateBranchById(id, data);

  if (!updated) {
    const error = new Error('Branch not found');
    error.status = 404;
    throw error;
  }

  return updated;
};

export const getBranchDetail = async (id) => {
  if (!mongoose.Types.ObjectId.isValid(id)) {
    const error = new Error('Invalid branch id');
    error.status = 400;
    throw error;
  }

  const branch = await getBranchById(id);
  if (!branch) {
    const error = new Error('Branch not found');
    error.status = 404;
    throw error;
  }

  const stockData = await getTotalStockByBranch();
  const stockMap = {};
  stockData.forEach((item) => {
    stockMap[String(item._id)] = item.totalItemsInStock;
  });

  const [branchManagers, inventoryLines] = await Promise.all([
    findBranchManagersByBranchId(id),
    getInventoryLinesWithProductsForBranch(id),
  ]);

  return {
    branch: {
      ...branch,
      totalItemsInStock: stockMap[String(branch._id)] || 0,
    },
    branchManagers,
    inventoryLines,
  };
};

export const getBranchManagerCandidates = async (branchId) => {
  if (!mongoose.Types.ObjectId.isValid(branchId)) {
    const error = new Error('Invalid branch id');
    error.status = 400;
    throw error;
  }

  const branch = await getBranchById(branchId);
  if (!branch) {
    const error = new Error('Branch not found');
    error.status = 404;
    throw error;
  }

  const managers = await listActiveBranchManagers();
  return managers.map((u) => ({
    _id: u._id,
    username: u.username,
    fullName: u.fullName,
    role: u.role,
    status: u.status,
    branchId: u.branchId ?? null,
    managedBranchIds: (u.managedBranchIds || []).map((x) =>
      x?.toString?.() ?? String(x),
    ),
  }));
};

/**
 * Gán / gỡ BRANCH_MANAGER khỏi chi nhánh.
 * - userId rỗng: gỡ mọi quản lý khỏi chi nhánh này.
 * - detach true + userId: chỉ gỡ user đó khỏi chi nhánh này.
 * - detach false/absent + userId: thêm user vào danh sách quản lý chi nhánh (addToSet).
 */
export const assignBranchManager = async (branchId, userId, { detach = false } = {}) => {
  if (!mongoose.Types.ObjectId.isValid(branchId)) {
    const error = new Error('Invalid branch id');
    error.status = 400;
    throw error;
  }

  const branch = await getBranchById(branchId);
  if (!branch) {
    const error = new Error('Branch not found');
    error.status = 404;
    throw error;
  }

  const unassignAll = userId == null || userId === '';

  if (unassignAll) {
    await detachBranchFromAllManagers(branchId);
    return findBranchManagersByBranchId(branchId);
  }

  if (!mongoose.Types.ObjectId.isValid(userId)) {
    const error = new Error('Invalid user id');
    error.status = 400;
    throw error;
  }

  if (detach) {
    await detachBranchFromManager(userId, branchId);
    return findBranchManagersByBranchId(branchId);
  }

  const user = await findUserByIdLean(userId);
  if (!user) {
    const error = new Error('User not found');
    error.status = 404;
    throw error;
  }
  if (user.status !== 'ACTIVE') {
    const error = new Error('User must be ACTIVE');
    error.status = 400;
    throw error;
  }
  if (user.role !== 'BRANCH_MANAGER') {
    const error = new Error('Only users with role BRANCH_MANAGER can be assigned');
    error.status = 400;
    throw error;
  }

  const updated = await addManagedBranchToManager(userId, branchId);
  if (!updated) {
    const err = new Error('User not found');
    err.status = 404;
    throw err;
  }

  return findBranchManagersByBranchId(branchId);
};

export const getInventoryStaffForBranch = async (branchId) => {
  if (!mongoose.Types.ObjectId.isValid(branchId)) {
    const error = new Error('Invalid branch id');
    error.status = 400;
    throw error;
  }
  const branch = await getBranchById(branchId);
  if (!branch) {
    const error = new Error('Branch not found');
    error.status = 404;
    throw error;
  }
  return listInventoryStaffByBranch(branchId);
};

export const createInventoryStaffForBranch = async (branchId, { username, password, fullName }) => {
  if (!mongoose.Types.ObjectId.isValid(branchId)) {
    const error = new Error('Invalid branch id');
    error.status = 400;
    throw error;
  }
  const branch = await getBranchById(branchId);
  if (!branch) {
    const error = new Error('Branch not found');
    error.status = 404;
    throw error;
  }
  if (!username?.trim() || !password || !fullName?.trim()) {
    const error = new Error('username, password và fullName là bắt buộc');
    error.status = 400;
    throw error;
  }
  const exists = await findUserByUsernameLean(username);
  if (exists) {
    const error = new Error('Username đã tồn tại');
    error.status = 409;
    throw error;
  }
  const passwordHash = await bcrypt.hash(password, 10);
  const created = await createInventoryStaffUser({
    username,
    passwordHash,
    fullName,
    branchId,
  });
  if (!created) {
    const error = new Error('Không tạo được tài khoản');
    error.status = 400;
    throw error;
  }
  return {
    _id: created._id,
    username: created.username,
    fullName: created.fullName,
    role: created.role,
    status: created.status,
    branchId: created.branchId?.toString?.() ?? created.branchId,
  };
};

export const deactivateInventoryStaffForBranch = async (branchId, staffUserId) => {
  if (!mongoose.Types.ObjectId.isValid(branchId) || !mongoose.Types.ObjectId.isValid(staffUserId)) {
    const error = new Error('Invalid id');
    error.status = 400;
    throw error;
  }
  const branch = await getBranchById(branchId);
  if (!branch) {
    const error = new Error('Branch not found');
    error.status = 404;
    throw error;
  }
  const updated = await setInventoryStaffInactiveInBranch(staffUserId, branchId);
  if (!updated) {
    const error = new Error('Không tìm thấy nhân viên kho tại chi nhánh này');
    error.status = 404;
    throw error;
  }
  return updated;
};
