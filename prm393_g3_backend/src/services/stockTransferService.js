import mongoose from 'mongoose';
import StockMovement from '../models/stockmovement.js';
import User from '../models/users.js';
import Variant from '../models/variant.js';
import { getBranchById } from '../repositories/branchRepository.js';
import {
  listTransferShortfalls,
  applyApprovedTransferInventory,
} from '../repositories/inventoryRepository.js';

function httpError(status, message, details) {
  const e = new Error(message);
  e.status = status;
  if (details != null) e.details = details;
  return e;
}

function managedBranchSet(user) {
  const s = new Set((user.managedBranchIds || []).map((id) => String(id)));
  if (user.branchId) s.add(String(user.branchId));
  return s;
}

function branchIdOf(ref) {
  if (ref == null) return '';
  if (typeof ref === 'object' && ref !== null && ref._id != null) {
    return String(ref._id);
  }
  return String(ref);
}

function populateTransfer(query) {
  return query
    .populate('fromBranchId', 'name')
    .populate('toBranchId', 'name')
    .populate('createdBy', 'fullName username')
    .populate('reviewedBy', 'fullName username');
}

function canViewTransfer(user, movement) {
  if (!user) return false;
  if (user.role === 'ADMIN') return true;
  const from = branchIdOf(movement.fromBranchId);
  const to = branchIdOf(movement.toBranchId);
  if (user.role === 'INVENTORY_STAFF' && user.branchId && String(user.branchId) === from) {
    return true;
  }
  if (user.role === 'BRANCH_MANAGER') {
    const m = managedBranchSet(user);
    return m.has(from) || m.has(to);
  }
  return false;
}

function canReviewTransfer(user, movement) {
  if (!user) return false;
  if (user.role === 'ADMIN') return true;
  if (user.role !== 'BRANCH_MANAGER') return false;
  return managedBranchSet(user).has(branchIdOf(movement.fromBranchId));
}

/** Gộp trùng variantId trong payload. */
function normalizeItems(items) {
  if (!Array.isArray(items) || items.length === 0) {
    throw httpError(400, 'Danh sách hàng chuyển không hợp lệ');
  }
  const map = new Map();
  for (const it of items) {
    if (!it?.variantId || !mongoose.Types.ObjectId.isValid(it.variantId)) {
      throw httpError(400, 'variantId không hợp lệ');
    }
    const q = Number(it.quantity);
    if (!Number.isFinite(q) || q <= 0 || !Number.isInteger(q)) {
      throw httpError(400, 'Số lượng phải là số nguyên dương');
    }
    const vid = String(new mongoose.Types.ObjectId(it.variantId));
    map.set(vid, (map.get(vid) || 0) + q);
  }
  return [...map.entries()].map(([variantId, quantity]) => ({
    variantId: new mongoose.Types.ObjectId(variantId),
    quantity,
  }));
}

export async function createTransferRequest({ actorUserId, payload }) {
  if (!mongoose.Types.ObjectId.isValid(actorUserId)) {
    throw httpError(401, 'Phiên đăng nhập không hợp lệ');
  }

  const user = await User.findById(actorUserId).lean();
  if (!user || user.status !== 'ACTIVE') {
    throw httpError(401, 'Người dùng không hợp lệ');
  }
  if (user.role !== 'INVENTORY_STAFF') {
    throw httpError(403, 'Chỉ nhân viên kho được tạo phiếu chuyển');
  }
  if (!user.branchId) {
    throw httpError(403, 'Tài khoản chưa gán chi nhánh');
  }

  const fromBranchId = payload?.fromBranchId;
  const toBranchId = payload?.toBranchId;
  if (!fromBranchId || !mongoose.Types.ObjectId.isValid(fromBranchId)) {
    throw httpError(400, 'fromBranchId không hợp lệ');
  }
  if (!toBranchId || !mongoose.Types.ObjectId.isValid(toBranchId)) {
    throw httpError(400, 'toBranchId không hợp lệ');
  }
  if (String(fromBranchId) === String(toBranchId)) {
    throw httpError(400, 'Chi nhánh nguồn và đích phải khác nhau');
  }
  if (String(user.branchId) !== String(fromBranchId)) {
    throw httpError(403, 'Bạn chỉ được tạo phiếu chuyển từ chi nhánh của mình');
  }

  const [fromBranch, toBranch] = await Promise.all([
    getBranchById(fromBranchId),
    getBranchById(toBranchId),
  ]);
  if (!fromBranch || !toBranch) {
    throw httpError(404, 'Không tìm thấy chi nhánh');
  }

  const items = normalizeItems(payload.items);
  const variantIds = items.map((i) => i.variantId);
  const found = await Variant.countDocuments({ _id: { $in: variantIds }, status: 'ACTIVE' });
  if (found !== items.length) {
    throw httpError(400, 'Một hoặc nhiều variant không tồn tại hoặc không hoạt động');
  }

  const shortfalls = await listTransferShortfalls(fromBranchId, items);
  if (shortfalls.length > 0) {
    throw httpError(400, 'Tồn kho chi nhánh nguồn không đủ để chuyển', shortfalls);
  }

  const doc = await StockMovement.create({
    type: 'TRANSFER',
    status: 'PENDING',
    fromBranchId,
    toBranchId,
    createdBy: actorUserId,
    note: typeof payload.note === 'string' ? payload.note.trim() || undefined : undefined,
    items,
  });

  return populateTransfer(StockMovement.findById(doc._id)).lean();
}

export async function listTransfers({ actorUserId, query }) {
  if (!mongoose.Types.ObjectId.isValid(actorUserId)) {
    throw httpError(401, 'Phiên đăng nhập không hợp lệ');
  }
  const user = await User.findById(actorUserId).lean();
  if (!user || user.status !== 'ACTIVE') {
    throw httpError(401, 'Người dùng không hợp lệ');
  }

  const filter = { type: 'TRANSFER' };
  if (query?.status) {
    if (!['PENDING', 'COMPLETED', 'REJECTED'].includes(query.status)) {
      throw httpError(400, 'status không hợp lệ');
    }
    filter.status = query.status;
  }

  if (user.role === 'ADMIN') {
    // toàn bộ
  } else if (user.role === 'BRANCH_MANAGER') {
    const managed = [...managedBranchSet(user)].filter((id) => mongoose.Types.ObjectId.isValid(id));
    if (managed.length === 0) {
      return [];
    }
    const managedOids = managed.map((id) => new mongoose.Types.ObjectId(id));
    filter.$or = [
      { fromBranchId: { $in: managedOids } },
      { toBranchId: { $in: managedOids } },
    ];
  } else if (user.role === 'INVENTORY_STAFF') {
    if (!user.branchId) return [];
    filter.fromBranchId = user.branchId;
  } else {
    throw httpError(403, 'Không có quyền xem danh sách phiếu chuyển');
  }

  return populateTransfer(StockMovement.find(filter).sort({ createdAt: -1 })).lean();
}

export async function getTransferById({ actorUserId, movementId }) {
  if (!mongoose.Types.ObjectId.isValid(actorUserId) || !mongoose.Types.ObjectId.isValid(movementId)) {
    throw httpError(400, 'Tham số không hợp lệ');
  }
  const movement = await StockMovement.findById(movementId).lean();
  if (!movement || movement.type !== 'TRANSFER') {
    throw httpError(404, 'Không tìm thấy phiếu chuyển');
  }
  const user = await User.findById(actorUserId).lean();
  if (!user || user.status !== 'ACTIVE') {
    throw httpError(401, 'Người dùng không hợp lệ');
  }
  if (!canViewTransfer(user, movement)) {
    throw httpError(403, 'Bạn không có quyền xem phiếu này');
  }
  return populateTransfer(StockMovement.findById(movementId)).lean();
}

function isTransactionUnsupportedError(err) {
  if (!err || err.status != null) return false;
  const c = err.code;
  const msg = String(err.message || '');
  return (
    c === 20
    || c === 303
    || /replica set|Transaction numbers are only allowed|transactions are not supported|Multi-document transactions are not supported/i.test(
      msg,
    )
  );
}

/**
 * Duyệt khi không dùng được multi-document transaction (MongoDB standalone).
 * Gán COMPLETED trước (một thao tác atomic) rồi cập nhật tồn; nếu tồn lỗi thì trả phiếu về PENDING.
 */
async function approveTransferWithoutTransaction(movementId, actorUserId) {
  const reviewedAt = new Date();
  const claimed = await StockMovement.findOneAndUpdate(
    {
      _id: movementId,
      type: 'TRANSFER',
      status: 'PENDING',
    },
    {
      $set: {
        status: 'COMPLETED',
        reviewedBy: actorUserId,
        reviewedAt,
      },
    },
    { new: true },
  );
  if (!claimed) {
    throw httpError(400, 'Phiếu đã được xử lý');
  }
  try {
    await applyApprovedTransferInventory(
      claimed.fromBranchId,
      claimed.toBranchId,
      claimed.items,
      null,
    );
  } catch (e) {
    await StockMovement.updateOne(
      { _id: movementId },
      {
        $set: {
          status: 'PENDING',
          reviewedBy: null,
          reviewedAt: null,
        },
      },
    );
    if (e.code === 'INSUFFICIENT_STOCK') {
      throw httpError(400, 'Tồn kho không đủ tại thời điểm duyệt (có thể đã thay đổi)');
    }
    throw e;
  }
}

export async function approveTransfer({ actorUserId, movementId }) {
  if (!mongoose.Types.ObjectId.isValid(actorUserId) || !mongoose.Types.ObjectId.isValid(movementId)) {
    throw httpError(400, 'Tham số không hợp lệ');
  }

  const user = await User.findById(actorUserId).lean();
  if (!user || user.status !== 'ACTIVE') {
    throw httpError(401, 'Người dùng không hợp lệ');
  }
  if (user.role !== 'ADMIN' && user.role !== 'BRANCH_MANAGER') {
    throw httpError(403, 'Chỉ quản lý chi nhánh hoặc quản trị viên được duyệt phiếu');
  }

  const movement = await StockMovement.findById(movementId).lean();
  if (!movement || movement.type !== 'TRANSFER') {
    throw httpError(404, 'Không tìm thấy phiếu chuyển');
  }
  if (movement.status !== 'PENDING') {
    throw httpError(400, 'Phiếu không ở trạng thái chờ duyệt');
  }
  if (!canReviewTransfer(user, movement)) {
    throw httpError(403, 'Bạn chỉ duyệt phiếu chuyển xuất từ chi nhánh mình quản lý');
  }

  const shortfalls = await listTransferShortfalls(movement.fromBranchId, movement.items);
  if (shortfalls.length > 0) {
    throw httpError(400, 'Tồn kho hiện không đủ để hoàn tất phiếu', shortfalls);
  }

  const session = await mongoose.startSession();
  try {
    await session.withTransaction(async () => {
      const fresh = await StockMovement.findOne({
        _id: movementId,
        type: 'TRANSFER',
        status: 'PENDING',
      }).session(session);
      if (!fresh) {
        throw httpError(400, 'Phiếu đã được xử lý');
      }
      await applyApprovedTransferInventory(
        fresh.fromBranchId,
        fresh.toBranchId,
        fresh.items,
        session,
      );
      fresh.status = 'COMPLETED';
      fresh.reviewedBy = actorUserId;
      fresh.reviewedAt = new Date();
      await fresh.save({ session });
    });
  } catch (e) {
    if (e.status != null) {
      throw e;
    }
    if (e.code === 'INSUFFICIENT_STOCK') {
      throw httpError(400, 'Tồn kho không đủ tại thời điểm duyệt (có thể đã thay đổi)');
    }
    if (isTransactionUnsupportedError(e)) {
      await approveTransferWithoutTransaction(movementId, actorUserId);
    } else {
      throw e;
    }
  } finally {
    session.endSession();
  }

  return populateTransfer(StockMovement.findById(movementId)).lean();
}

export async function updatePendingTransfer({ actorUserId, movementId, payload }) {
  if (!mongoose.Types.ObjectId.isValid(actorUserId) || !mongoose.Types.ObjectId.isValid(movementId)) {
    throw httpError(400, 'Tham số không hợp lệ');
  }

  const user = await User.findById(actorUserId).lean();
  if (!user || user.status !== 'ACTIVE') {
    throw httpError(401, 'Người dùng không hợp lệ');
  }
  if (user.role !== 'INVENTORY_STAFF') {
    throw httpError(403, 'Chỉ nhân viên kho được sửa phiếu chuyển');
  }
  if (!user.branchId) {
    throw httpError(403, 'Tài khoản chưa gán chi nhánh');
  }

  const movement = await StockMovement.findById(movementId);
  if (!movement || movement.type !== 'TRANSFER') {
    throw httpError(404, 'Không tìm thấy phiếu chuyển');
  }
  if (movement.status !== 'PENDING') {
    throw httpError(400, 'Chỉ sửa được phiếu đang chờ duyệt');
  }
  if (String(user.branchId) !== String(movement.fromBranchId)) {
    throw httpError(403, 'Bạn không thể sửa phiếu của chi nhánh khác');
  }

  const toBranchId =
    payload?.toBranchId != null && payload.toBranchId !== ''
      ? payload.toBranchId
      : movement.toBranchId;
  if (!mongoose.Types.ObjectId.isValid(toBranchId)) {
    throw httpError(400, 'toBranchId không hợp lệ');
  }
  if (String(movement.fromBranchId) === String(toBranchId)) {
    throw httpError(400, 'Chi nhánh nguồn và đích phải khác nhau');
  }

  const [fromBranch, toBranch] = await Promise.all([
    getBranchById(movement.fromBranchId),
    getBranchById(toBranchId),
  ]);
  if (!fromBranch || !toBranch) {
    throw httpError(404, 'Không tìm thấy chi nhánh');
  }

  let items;
  if (payload?.items != null) {
    items = normalizeItems(payload.items);
  } else {
    items = movement.items.map((row) => ({
      variantId: row.variantId,
      quantity: row.quantity,
    }));
  }

  const variantIds = items.map((i) => i.variantId);
  const found = await Variant.countDocuments({ _id: { $in: variantIds }, status: 'ACTIVE' });
  if (found !== items.length) {
    throw httpError(400, 'Một hoặc nhiều variant không tồn tại hoặc không hoạt động');
  }

  const shortfalls = await listTransferShortfalls(movement.fromBranchId, items);
  if (shortfalls.length > 0) {
    throw httpError(400, 'Tồn kho chi nhánh nguồn không đủ để chuyển', shortfalls);
  }

  movement.toBranchId = toBranchId;
  if (typeof payload?.note === 'string') {
    movement.note = payload.note.trim() || undefined;
  }
  movement.items = items;
  await movement.save();

  return populateTransfer(StockMovement.findById(movementId)).lean();
}

export async function rejectTransfer({ actorUserId, movementId, rejectionReason }) {
  if (!mongoose.Types.ObjectId.isValid(actorUserId) || !mongoose.Types.ObjectId.isValid(movementId)) {
    throw httpError(400, 'Tham số không hợp lệ');
  }
  const reason = typeof rejectionReason === 'string' ? rejectionReason.trim() : '';
  if (!reason) {
    throw httpError(400, 'Vui lòng nhập lý do từ chối');
  }

  const user = await User.findById(actorUserId).lean();
  if (!user || user.status !== 'ACTIVE') {
    throw httpError(401, 'Người dùng không hợp lệ');
  }
  if (user.role !== 'ADMIN' && user.role !== 'BRANCH_MANAGER') {
    throw httpError(403, 'Chỉ quản lý chi nhánh hoặc quản trị viên được từ chối phiếu');
  }

  const movement = await StockMovement.findById(movementId).lean();
  if (!movement || movement.type !== 'TRANSFER') {
    throw httpError(404, 'Không tìm thấy phiếu chuyển');
  }
  if (movement.status !== 'PENDING') {
    throw httpError(400, 'Phiếu không ở trạng thái chờ duyệt');
  }
  if (!canReviewTransfer(user, movement)) {
    throw httpError(403, 'Bạn chỉ từ chối phiếu chuyển xuất từ chi nhánh mình quản lý');
  }

  const updated = await StockMovement.findOneAndUpdate(
    { _id: movementId, type: 'TRANSFER', status: 'PENDING' },
    {
      $set: {
        status: 'REJECTED',
        reviewedBy: actorUserId,
        reviewedAt: new Date(),
        rejectionReason: reason,
      },
    },
    { new: true },
  ).lean();

  if (!updated) {
    throw httpError(400, 'Phiếu đã được xử lý');
  }
  return populateTransfer(StockMovement.findById(movementId)).lean();
}
