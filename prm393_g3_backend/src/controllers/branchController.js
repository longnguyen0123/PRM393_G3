import {
  getBranchesWithStockForRequester,
  getBranchDetail,
  getBranchManagerCandidates,
  assignBranchManager,
  createBranch,
  updateBranch,
  getInventoryStaffForBranch,
  createInventoryStaffForBranch,
  deactivateInventoryStaffForBranch,
  getCashiersForBranch,
  createCashierForBranch,
  deactivateCashierForBranch,
} from '../services/branchService.js';

export const getBranches = async (req, res, next) => {
  try {
    const branches = await getBranchesWithStockForRequester(req.user);
    res.json({
      success: true,
      data: branches,
      message: 'Branches fetched successfully'
    });
  } catch (err) {
    if (err.status === 401) {
      return res.status(401).json({
        success: false,
        message: 'Phiên đăng nhập không hợp lệ',
      });
    }
    next(err);
  }
};

export const getBranchDetailHandler = async (req, res, next) => {
  try {
    const detail = await getBranchDetail(req.params.id);
    res.json({
      success: true,
      data: detail,
      message: 'Branch detail fetched successfully',
    });
  } catch (err) {
    next(err);
  }
};

export const getBranchManagerCandidatesHandler = async (req, res, next) => {
  try {
    const candidates = await getBranchManagerCandidates(req.params.id);
    res.json({
      success: true,
      data: candidates,
      message: 'Branch manager candidates fetched successfully',
    });
  } catch (err) {
    next(err);
  }
};

export const assignBranchManagerHandler = async (req, res, next) => {
  try {
    const { userId, detach } = req.body ?? {};
    const branchManagers = await assignBranchManager(req.params.id, userId, {
      detach: Boolean(detach),
    });
    res.json({
      success: true,
      data: { branchManagers },
      message: userId == null || userId === ''
        ? 'Đã gỡ mọi quản lý khỏi chi nhánh'
        : detach
          ? 'Đã gỡ quản lý khỏi chi nhánh'
          : 'Đã cập nhật quản lý chi nhánh',
    });
  } catch (err) {
    next(err);
  }
};

export const listInventoryStaffHandler = async (req, res, next) => {
  try {
    const staff = await getInventoryStaffForBranch(req.params.id);
    res.json({
      success: true,
      data: staff,
      message: 'Danh sách nhân viên kho',
    });
  } catch (err) {
    next(err);
  }
};

export const createInventoryStaffHandler = async (req, res, next) => {
  try {
    const { username, password, fullName } = req.body ?? {};
    const created = await createInventoryStaffForBranch(req.params.id, {
      username,
      password,
      fullName,
    });
    res.status(201).json({
      success: true,
      data: created,
      message: 'Đã tạo tài khoản nhân viên kho',
    });
  } catch (err) {
    next(err);
  }
};

export const deactivateInventoryStaffHandler = async (req, res, next) => {
  try {
    const updated = await deactivateInventoryStaffForBranch(
      req.params.id,
      req.params.userId,
    );
    res.json({
      success: true,
      data: updated,
      message: 'Đã vô hiệu hóa tài khoản nhân viên kho',
    });
  } catch (err) {
    next(err);
  }
};

export const listCashiersHandler = async (req, res, next) => {
  try {
    const list = await getCashiersForBranch(req.params.id);
    res.json({
      success: true,
      data: list,
      message: 'Danh sách thu ngân',
    });
  } catch (err) {
    next(err);
  }
};

export const createCashierHandler = async (req, res, next) => {
  try {
    const { username, password, fullName } = req.body ?? {};
    const created = await createCashierForBranch(req.params.id, {
      username,
      password,
      fullName,
    });
    res.status(201).json({
      success: true,
      data: created,
      message: 'Đã tạo tài khoản thu ngân',
    });
  } catch (err) {
    next(err);
  }
};

export const deactivateCashierHandler = async (req, res, next) => {
  try {
    const updated = await deactivateCashierForBranch(
      req.params.id,
      req.params.userId,
    );
    res.json({
      success: true,
      data: updated,
      message: 'Đã vô hiệu hóa tài khoản thu ngân',
    });
  } catch (err) {
    next(err);
  }
};

export const createBranchHandler = async (req, res, next) => {
  try {
    const branch = await createBranch(req.body);
    res.status(201).json({
      success: true,
      data: branch,
      message: 'Branch created successfully'
    });
  } catch (err) {
    next(err);
  }
};

export const updateBranchHandler = async (req, res, next) => {
  try {
    const branch = await updateBranch(req.params.id, req.body);
    res.json({
      success: true,
      data: branch,
      message: 'Branch updated successfully'
    });
  } catch (err) {
    next(err);
  }
};

