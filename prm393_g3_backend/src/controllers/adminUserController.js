import bcrypt from 'bcrypt';
import mongoose from 'mongoose';
import User from '../models/users.js';
import { getBranchById } from '../repositories/branchRepository.js';
import {
  findUserByUsernameLean,
  listBranchManagersForAdmin,
  listInventoryStaffForAdmin,
  setUserStatusById,
} from '../repositories/userRepository.js';

const ADMIN_ROLES = ['ADMIN', 'BRANCH_MANAGER', 'CASHIER', 'INVENTORY_STAFF'];

const branchRef = (b) => {
  if (b == null) return null;
  if (typeof b === 'object' && b._id != null) {
    return {
      id: String(b._id),
      name: b.name ?? '',
    };
  }
  return { id: String(b), name: '' };
};

const formatBranchManager = (doc) => {
  const branches = [];
  const seen = new Set();
  for (const m of doc.managedBranchIds || []) {
    const ref = branchRef(m);
    if (ref?.id && !seen.has(ref.id)) {
      seen.add(ref.id);
      branches.push(ref);
    }
  }
  const legacy = branchRef(doc.branchId);
  if (legacy?.id && !seen.has(legacy.id)) {
    branches.push(legacy);
  }
  return {
    id: String(doc._id),
    username: doc.username,
    fullName: doc.fullName,
    role: doc.role,
    status: doc.status,
    branches,
  };
};

export const listBranchManagersAdminHandler = async (_req, res) => {
  const rows = await listBranchManagersForAdmin();
  res.json({
    success: true,
    data: rows.map(formatBranchManager),
  });
};

const formatInventoryStaff = (doc) => {
  const b = doc.branchId;
  let branch = null;
  if (b != null && typeof b === 'object' && b._id != null) {
    branch = {
      id: String(b._id),
      name: b.name ?? '',
      address: b.address ?? '',
    };
  } else if (doc.branchId) {
    branch = { id: String(doc.branchId), name: '', address: '' };
  }
  return {
    id: String(doc._id),
    username: doc.username,
    fullName: doc.fullName,
    role: doc.role,
    status: doc.status,
    branch,
  };
};

export const listInventoryStaffAdminHandler = async (_req, res) => {
  const rows = await listInventoryStaffForAdmin();
  res.json({
    success: true,
    data: rows.map(formatInventoryStaff),
  });
};

export const patchUserStatusAdminHandler = async (req, res) => {
  const { id } = req.params;
  const { status } = req.body ?? {};
  if (!['ACTIVE', 'INACTIVE'].includes(status)) {
    return res.status(400).json({
      success: false,
      message: 'status phải là ACTIVE hoặc INACTIVE',
    });
  }
  if (String(req.user.userId) === String(id)) {
    return res.status(403).json({
      success: false,
      message: 'Không thể đổi trạng thái tài khoản của chính bạn',
    });
  }
  const updated = await setUserStatusById(id, status);
  if (!updated) {
    return res.status(404).json({
      success: false,
      message: 'Không tìm thấy người dùng',
    });
  }
  res.json({
    success: true,
    data: {
      id: String(updated._id),
      status: updated.status,
    },
  });
};

export const createUserAdminHandler = async (req, res, next) => {
  try {
    const {
      username,
      password,
      fullName,
      role,
      branchId,
      managedBranchIds,
    } = req.body ?? {};

    if (!username?.trim() || !password || !fullName?.trim() || !role) {
      return res.status(400).json({
        success: false,
        message: 'username, password, fullName và role là bắt buộc',
      });
    }
    if (!ADMIN_ROLES.includes(role)) {
      return res.status(400).json({
        success: false,
        message: 'role không hợp lệ',
      });
    }

    if (role === 'CASHIER' || role === 'INVENTORY_STAFF') {
      if (!branchId || !mongoose.Types.ObjectId.isValid(branchId)) {
        return res.status(400).json({
          success: false,
          message: 'branchId là bắt buộc cho CASHIER và INVENTORY_STAFF',
        });
      }
      const br = await getBranchById(branchId);
      if (!br) {
        return res.status(400).json({
          success: false,
          message: 'Chi nhánh không tồn tại',
        });
      }
    }

    const managedOids = [];
    if (role === 'BRANCH_MANAGER' && Array.isArray(managedBranchIds)) {
      const unique = [...new Set(managedBranchIds.filter((x) => mongoose.Types.ObjectId.isValid(x)))];
      for (const bid of unique) {
        const br = await getBranchById(bid);
        if (!br) {
          return res.status(400).json({
            success: false,
            message: `Chi nhánh không tồn tại: ${bid}`,
          });
        }
        managedOids.push(new mongoose.Types.ObjectId(bid));
      }
    }

    const exists = await findUserByUsernameLean(username);
    if (exists) {
      return res.status(409).json({
        success: false,
        message: 'Username đã tồn tại',
      });
    }

    const passwordHash = await bcrypt.hash(password, 10);

    const doc = {
      username: username.trim(),
      passwordHash,
      fullName: fullName.trim(),
      role,
      status: 'ACTIVE',
      managedBranchIds: role === 'BRANCH_MANAGER' ? managedOids : [],
      branchId:
        role === 'CASHIER' || role === 'INVENTORY_STAFF'
          ? new mongoose.Types.ObjectId(branchId)
          : null,
    };

    const u = await User.create(doc);
    res.status(201).json({
      success: true,
      data: {
        id: String(u._id),
        username: u.username,
        fullName: u.fullName,
        role: u.role,
        status: u.status,
      },
    });
  } catch (err) {
    if (err?.code === 11000) {
      return res.status(409).json({
        success: false,
        message: 'Username đã tồn tại',
      });
    }
    next(err);
  }
};
