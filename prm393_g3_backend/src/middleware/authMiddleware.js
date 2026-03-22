import jwt from 'jsonwebtoken';

import mongoose from 'mongoose';

import { JWT_SECRET } from '../config/jwt.js';

import User from '../models/users.js';

import { getBranchById } from '../repositories/branchRepository.js';



export function authenticate(req, res, next) {

  const header = req.headers.authorization;

  if (!header?.startsWith('Bearer ')) {

    return res.status(401).json({

      success: false,

      message: 'Chưa đăng nhập',

    });

  }

  const token = header.slice(7);

  try {

    const payload = jwt.verify(token, JWT_SECRET);

    req.user = {

      userId: payload.userId != null ? String(payload.userId) : undefined,

      username: payload.username,

      role: payload.role,

    };

    next();

  } catch {

    return res.status(401).json({

      success: false,

      message: 'Token không hợp lệ hoặc đã hết hạn',

    });

  }

}



export function requireAdmin(req, res, next) {

  if (req.user?.role !== 'ADMIN') {

    return res.status(403).json({

      success: false,

      message: 'Chỉ quản trị viên được thực hiện thao tác này',

    });

  }

  next();

}

/** Danh mục & thương hiệu: ADMIN, quản lý chi nhánh, nhân viên kho. */
const CATALOG_EDIT_ROLES = ['ADMIN', 'BRANCH_MANAGER', 'INVENTORY_STAFF'];

export function requireCatalogEditor(req, res, next) {
  if (!CATALOG_EDIT_ROLES.includes(req.user?.role)) {
    return res.status(403).json({
      success: false,
      message: 'Bạn không có quyền thêm hoặc sửa danh mục / thương hiệu',
    });
  }
  next();
}

/**

 * Truy cập tài nguyên theo branchId: ADMIN; BRANCH_MANAGER theo managedBranchIds / branchId;

 * CASHIER / INVENTORY_STAFF chỉ đúng chi nhánh branchId.

 */

export async function requireAdminOrManagerOfBranch(req, res, next) {

  const branchId = req.params.id;

  if (!branchId) {

    return res.status(400).json({ success: false, message: 'Thiếu branch id' });

  }

  if (req.user?.role === 'ADMIN') {

    return next();

  }

  if (!mongoose.Types.ObjectId.isValid(req.user.userId)) {

    return res.status(401).json({ success: false, message: 'Token không hợp lệ' });

  }

  const user = await User.findById(req.user.userId)

    .select('managedBranchIds branchId role')

    .lean();

  if (!user) {

    return res.status(401).json({ success: false, message: 'Người dùng không tồn tại' });

  }

  const bid = String(branchId);

  if (user.role === 'ADMIN') {

    return next();

  }

  if (user.role === 'BRANCH_MANAGER') {

    const managed = new Set(

      (user.managedBranchIds || []).map((id) => String(id)),

    );

    if (user.branchId) {

      managed.add(String(user.branchId));

    }

    if (!managed.has(bid)) {

      return res.status(403).json({

        success: false,

        message: 'Bạn không quản lý chi nhánh này',

      });

    }

    return next();

  }

  if (user.role === 'CASHIER' || user.role === 'INVENTORY_STAFF') {

    if (!user.branchId || String(user.branchId) !== bid) {

      return res.status(403).json({

        success: false,

        message: 'Bạn không có quyền truy cập chi nhánh này',

      });

    }

    return next();

  }

  return res.status(403).json({

    success: false,

    message: 'Bạn không có quyền truy cập chi nhánh này',

  });

}



/**

 * Xem danh sách nhân viên kho: chỉ BRANCH_MANAGER đang quản lý chi nhánh đó.

 */

export async function requireBranchManagerInventoryStaffRead(req, res, next) {

  const branchId = req.params.id;

  if (!branchId) {

    return res.status(400).json({ success: false, message: 'Thiếu branch id' });

  }

  if (req.user?.role === 'ADMIN') {

    return next();

  }

  if (req.user?.role !== 'BRANCH_MANAGER') {

    return res.status(403).json({

      success: false,

      message: 'Chỉ quản trị viên hoặc quản lý chi nhánh xem được danh sách nhân viên',

    });

  }

  const branch = await getBranchById(branchId);

  if (!branch) {

    return res.status(404).json({ success: false, message: 'Không tìm thấy chi nhánh' });

  }

  if (!mongoose.Types.ObjectId.isValid(req.user.userId)) {

    return res.status(401).json({ success: false, message: 'Token không hợp lệ' });

  }

  const user = await User.findById(req.user.userId)

    .select('managedBranchIds branchId role')

    .lean();

  if (!user) {

    return res.status(401).json({ success: false, message: 'Người dùng không tồn tại' });

  }

  const bid = String(branchId);

  const managed = new Set(

    (user.managedBranchIds || []).map((id) => String(id)),

  );

  if (user.branchId) {

    managed.add(String(user.branchId));

  }

  if (!managed.has(bid)) {

    return res.status(403).json({

      success: false,

      message: 'Bạn không quản lý chi nhánh này',

    });

  }

  next();

}



/**

 * Thêm / vô hiệu nhân viên kho: chỉ BRANCH_MANAGER khi admin đã giao quyền quản lý kho.

 */

export async function requireDelegatedBranchManagerInventoryWrite(req, res, next) {

  const branchId = req.params.id;

  if (!branchId) {

    return res.status(400).json({ success: false, message: 'Thiếu branch id' });

  }

  if (req.user?.role === 'ADMIN') {

    return next();

  }

  if (req.user?.role !== 'BRANCH_MANAGER') {

    return res.status(403).json({

      success: false,

      message: 'Chỉ quản trị viên hoặc quản lý chi nhánh được thao tác nhân viên tại chi nhánh',

    });

  }

  const branch = await getBranchById(branchId);

  if (!branch) {

    return res.status(404).json({ success: false, message: 'Không tìm thấy chi nhánh' });

  }

  if (!branch.inventoryDelegatedToManager) {

    return res.status(403).json({

      success: false,

      message: 'Admin chưa giao quyền quản lý kho cho chi nhánh này',

    });

  }

  if (!mongoose.Types.ObjectId.isValid(req.user.userId)) {

    return res.status(401).json({ success: false, message: 'Token không hợp lệ' });

  }

  const user = await User.findById(req.user.userId)

    .select('managedBranchIds branchId role')

    .lean();

  if (!user) {

    return res.status(401).json({ success: false, message: 'Người dùng không tồn tại' });

  }

  const bid = String(branchId);

  const managed = new Set(

    (user.managedBranchIds || []).map((id) => String(id)),

  );

  if (user.branchId) {

    managed.add(String(user.branchId));

  }

  if (!managed.has(bid)) {

    return res.status(403).json({

      success: false,

      message: 'Bạn không quản lý chi nhánh này',

    });

  }

  next();

}



/** @deprecated Dùng requireDelegatedBranchManagerInventoryWrite */

export const requireAdminOrDelegatedInventoryManager =

  requireDelegatedBranchManagerInventoryWrite;

