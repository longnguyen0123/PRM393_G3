import mongoose from 'mongoose';
import Inventory from '../models/inventory.js';
import Variant from '../models/variant.js';
import Product from '../models/product.js';

export const getTotalStockByBranch = async () => {
  return await Inventory.aggregate([
    {
      $group: {
        _id: "$branchId",
        totalItemsInStock: { $sum: "$quantity" }
      }
    }
  ]);
};

/**
 * Match branchId whether BSON is ObjectId or string (mongoimport / mixed data).
 * Dùng native collection để tránh Mongoose cast theo schema String làm hỏng query.
 */
const branchIdMatchClause = (branchId) => {
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