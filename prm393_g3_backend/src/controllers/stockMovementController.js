import {
  createTransferRequest,
  listTransfers,
  getTransferById,
  updatePendingTransfer,
  approveTransfer,
  rejectTransfer,
} from '../services/stockTransferService.js';

function sendHttpError(res, err) {
  return res.status(err.status || 500).json({
    success: false,
    message: err.message || 'Lỗi',
    ...(err.details ? { details: err.details } : {}),
  });
}

export const createTransferRequestHandler = async (req, res, next) => {
  try {
    const data = await createTransferRequest({
      actorUserId: req.user.userId,
      payload: req.body,
    });
    res.status(201).json({
      success: true,
      data,
      message: 'Đã tạo phiếu chuyển, chờ quản lý chi nhánh nguồn duyệt',
    });
  } catch (err) {
    if (err.status) return sendHttpError(res, err);
    next(err);
  }
};

export const listTransfersHandler = async (req, res, next) => {
  try {
    const data = await listTransfers({
      actorUserId: req.user.userId,
      query: req.query,
    });
    res.json({
      success: true,
      data,
      message: 'Danh sách phiếu chuyển',
    });
  } catch (err) {
    if (err.status) return sendHttpError(res, err);
    next(err);
  }
};

export const getTransferByIdHandler = async (req, res, next) => {
  try {
    const data = await getTransferById({
      actorUserId: req.user.userId,
      movementId: req.params.id,
    });
    res.json({
      success: true,
      data,
      message: 'Chi tiết phiếu chuyển',
    });
  } catch (err) {
    if (err.status) return sendHttpError(res, err);
    next(err);
  }
};

export const updatePendingTransferHandler = async (req, res, next) => {
  try {
    const data = await updatePendingTransfer({
      actorUserId: req.user.userId,
      movementId: req.params.id,
      payload: req.body,
    });
    res.json({
      success: true,
      data,
      message: 'Đã cập nhật phiếu chuyển',
    });
  } catch (err) {
    if (err.status) return sendHttpError(res, err);
    next(err);
  }
};

export const approveTransferHandler = async (req, res, next) => {
  try {
    const data = await approveTransfer({
      actorUserId: req.user.userId,
      movementId: req.params.id,
    });
    res.json({
      success: true,
      data,
      message: 'Đã duyệt phiếu và cập nhật tồn kho',
    });
  } catch (err) {
    if (err.status) return sendHttpError(res, err);
    next(err);
  }
};

export const rejectTransferHandler = async (req, res, next) => {
  try {
    const data = await rejectTransfer({
      actorUserId: req.user.userId,
      movementId: req.params.id,
      rejectionReason: req.body?.rejectionReason,
    });
    res.json({
      success: true,
      data,
      message: 'Đã từ chối phiếu chuyển',
    });
  } catch (err) {
    if (err.status) return sendHttpError(res, err);
    next(err);
  }
};
