import mongoose from 'mongoose';
import Inventory from '../models/inventory.js';
import Variant from '../models/variant.js';
import Product from '../models/product.js';

export const getTotalStockByBranch = async () => {
  return await Inventory.aggregate([
    {
      $addFields: {
        branchKey: { $toString: '$branchId' },
      },
    },
    {
      $group: {
        _id: '$branchKey',
        totalItemsInStock: { $sum: '$quantity' },
      },
    },
  ]);
};

/**
 * Match branchId whether BSON is ObjectId or string (mongoimport / mixed data).
 * Dùng native collection để tránh Mongoose cast theo schema String làm hỏng query.
 */
export const branchIdMatchClause = (branchId) => {
  if (!mongoose.Types.ObjectId.isValid(branchId)) {
    return { branchId: branchId };
  }
  const bid = new mongoose.Types.ObjectId(branchId);
  return {
    $or: [
      { branchId: bid },
      { branchId: String(bid) },
      { branchId: branchId },
    ],
  };
};

export const variantIdMatchClause = (variantId) => {
  if (!mongoose.Types.ObjectId.isValid(variantId)) {
    return { variantId: variantId };
  }
  const vid = new mongoose.Types.ObjectId(variantId);
  return {
    $or: [
      { variantId: vid },
      { variantId: String(vid) },
      { variantId: variantId },
    ],
  };
};

const toCanonicalHexId = (value) => {
  if (value == null) return '';
  if (value instanceof mongoose.Types.ObjectId) return String(value);
  const s = String(value);
  if (mongoose.Types.ObjectId.isValid(s)) return String(new mongoose.Types.ObjectId(s));
  return s;
};

/**
 * Inventory rows for a branch with variant + product info (for admin branch detail).
 */
export const getInventoryLinesWithProductsForBranch = async (branchId) => {
  const rows = await Inventory.collection
    .find(branchIdMatchClause(branchId))
    .toArray();
  if (!rows.length) {
    return [];
  }

  const variantOidList = [
    ...new Set(
      rows
        .map((r) => r.variantId)
        .filter(Boolean)
        .map((id) => toCanonicalHexId(id)),
    ),
  ]
    .filter((h) => mongoose.Types.ObjectId.isValid(h))
    .map((h) => new mongoose.Types.ObjectId(h));

  const variants = await Variant.collection
    .find({ _id: { $in: variantOidList } })
    .toArray();
  const variantById = Object.fromEntries(
    variants.map((v) => [String(v._id), v]),
  );

  const productOidList = [
    ...new Set(
      variants
        .map((v) => v.productId)
        .filter(Boolean)
        .map((id) => toCanonicalHexId(id)),
    ),
  ]
    .filter((h) => mongoose.Types.ObjectId.isValid(h))
    .map((h) => new mongoose.Types.ObjectId(h));

  const products = await Product.collection
    .find({ _id: { $in: productOidList } })
    .toArray();

  const productById = Object.fromEntries(
    products.map((p) => [String(p._id), p]),
  );

  return rows.map((row) => {
    const vKey = toCanonicalHexId(row.variantId);
    const v = variantById[vKey];
    const p = v ? productById[toCanonicalHexId(v.productId)] : null;
    return {
      quantity: row.quantity,
      reorderLevel: row.reorderLevel,
      variant: v
        ? {
            _id: v._id,
            sku: v.sku,
            barcode: v.barcode,
            price: v.price,
            status: v.status,
          }
        : null,
      product: p
        ? {
            _id: p._id,
            name: p.name,
            description: p.description,
            status: p.status,
          }
        : null,
    };
  });
};

/** Chuẩn BSON ObjectId khi ghi inventory (không dùng string hex thô). */
const toObjectId = (value) => {
  if (value == null) return null;
  if (value instanceof mongoose.Types.ObjectId) return value;
  const s = String(value);
  if (!mongoose.Types.ObjectId.isValid(s)) return null;
  return new mongoose.Types.ObjectId(s);
};

export const findInventoryLine = async (branchId, variantId) => {
  return await Inventory.collection.findOne({
    $and: [branchIdMatchClause(branchId), variantIdMatchClause(variantId)],
  });
};

/**
 * Kiểm tra đủ tồn tại chi nhánh nguồn cho từng dòng.
 * @returns {Promise<Array<{ variantId: string, required: number, available: number }>>}
 */
export const listTransferShortfalls = async (fromBranchId, items) => {
  const short = [];
  for (const item of items) {
    const line = await findInventoryLine(fromBranchId, item.variantId);
    const available = line?.quantity ?? 0;
    if (available < item.quantity) {
      short.push({
        variantId: String(item.variantId),
        required: item.quantity,
        available,
      });
    }
  }
  return short;
};

/**
 * Trừ nguồn / cộng đích. `session` có thể null khi MongoDB standalone (không transaction).
 */
export const applyApprovedTransferInventory = async (fromBranchId, toBranchId, items, session) => {
  const opt = session != null ? { session } : {};
  const toBranchOid = toObjectId(toBranchId);
  if (!toBranchOid) {
    const err = new Error('INVALID_BRANCH_ID');
    err.code = 'INVALID_BRANCH_ID';
    throw err;
  }
  for (const item of items) {
    const qty = item.quantity;
    const dec = await Inventory.collection.findOneAndUpdate(
      {
        $and: [
          branchIdMatchClause(fromBranchId),
          variantIdMatchClause(item.variantId),
          { quantity: { $gte: qty } },
        ],
      },
      { $inc: { quantity: -qty } },
      { ...opt, returnDocument: 'after' },
    );
    if (!dec) {
      const err = new Error('INSUFFICIENT_STOCK');
      err.code = 'INSUFFICIENT_STOCK';
      err.variantId = item.variantId;
      throw err;
    }

    const destFilter = {
      $and: [branchIdMatchClause(toBranchId), variantIdMatchClause(item.variantId)],
    };
    const destLine = await Inventory.collection.findOne(destFilter, opt);
    const variantOid = toObjectId(item.variantId);
    if (!variantOid) {
      const err = new Error('INVALID_VARIANT_ID');
      err.code = 'INVALID_VARIANT_ID';
      throw err;
    }
    if (destLine) {
      await Inventory.collection.updateOne(destFilter, { $inc: { quantity: qty } }, opt);
    } else {
      await Inventory.collection.insertOne(
        {
          branchId: toBranchOid,
          variantId: variantOid,
          quantity: qty,
          reorderLevel: 0,
        },
        opt,
      );
    }
  }
};