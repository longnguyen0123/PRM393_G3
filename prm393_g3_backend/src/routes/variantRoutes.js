import express from 'express';
import mongoose from 'mongoose';
import Variant from '../models/variant.js';
import Product from '../models/product.js';
import { authenticate, requireAdmin } from '../middleware/authMiddleware.js';

const router = express.Router();
const adminOnly = [authenticate, requireAdmin];

// GET /api/variants
// Optional query: ?productId=<ObjectId> — khớp ref ObjectId trên schema variant
router.get('/', async (req, res) => {
  try {
    const { productId } = req.query;
    const filter = {};

    if (productId != null && String(productId).trim() !== '') {
      const idStr = String(productId).trim();
      if (!mongoose.Types.ObjectId.isValid(idStr)) {
        return res.status(400).json({ message: 'Invalid productId' });
      }
      filter.productId = new mongoose.Types.ObjectId(idStr);
    }

    const variants = await Variant.find(filter).lean().exec();
    return res.json(variants);
  } catch (error) {
    console.error('Error fetching variants:', error);
    return res.status(500).json({
      message: 'Failed to fetch variants',
    });
  }
});

// POST /api/variants (admin)
router.post('/', ...adminOnly, async (req, res) => {
  try {
    const { productId, sku, barcode, price, status } = req.body ?? {};

    if (productId == null || String(productId).trim() === '') {
      return res.status(400).json({ message: 'productId is required' });
    }
    if (typeof sku !== 'string' || !sku.trim()) {
      return res.status(400).json({ message: 'sku is required' });
    }

    const priceNum = Number(price);
    if (!Number.isFinite(priceNum) || priceNum < 0) {
      return res.status(400).json({ message: 'price must be a non-negative number' });
    }

    const pidStr = String(productId).trim();
    if (!mongoose.Types.ObjectId.isValid(pidStr)) {
      return res.status(400).json({ message: 'productId is invalid' });
    }

    const product = await Product.findById(pidStr).lean().exec();
    if (!product) {
      return res.status(404).json({ message: 'Product not found' });
    }

    const doc = {
      productId: new mongoose.Types.ObjectId(pidStr),
      sku: sku.trim(),
      price: priceNum,
      status: status === 'INACTIVE' ? 'INACTIVE' : 'ACTIVE',
    };
    if (typeof barcode === 'string' && barcode.trim()) {
      doc.barcode = barcode.trim();
    }

    const variant = await Variant.create(doc);
    return res.status(201).json(variant.toObject());
  } catch (error) {
    if (error.code === 11000) {
      return res.status(409).json({ message: 'SKU or barcode already exists' });
    }
    console.error('Error creating variant:', error);
    return res.status(500).json({ message: 'Failed to create variant' });
  }
});

// PATCH /api/variants/:id (admin)
router.patch('/:id', ...adminOnly, async (req, res) => {
  try {
    const { id } = req.params;
    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({ message: 'Invalid variant id' });
    }

    const { sku, barcode, price, status } = req.body ?? {};
    const $set = {};
    const $unset = {};

    if (sku !== undefined) {
      if (typeof sku !== 'string' || !sku.trim()) {
        return res.status(400).json({ message: 'Invalid sku' });
      }
      $set.sku = sku.trim();
    }
    if (price !== undefined) {
      const priceNum = Number(price);
      if (!Number.isFinite(priceNum) || priceNum < 0) {
        return res.status(400).json({ message: 'price must be a non-negative number' });
      }
      $set.price = priceNum;
    }
    if (status !== undefined) {
      if (!['ACTIVE', 'INACTIVE'].includes(status)) {
        return res.status(400).json({ message: 'Invalid status' });
      }
      $set.status = status;
    }
    if (barcode !== undefined) {
      if (barcode === null || (typeof barcode === 'string' && !barcode.trim())) {
        $unset.barcode = '';
      } else if (typeof barcode === 'string') {
        $set.barcode = barcode.trim();
      } else {
        return res.status(400).json({ message: 'Invalid barcode' });
      }
    }

    const hasSet = Object.keys($set).length > 0;
    const hasUnset = Object.keys($unset).length > 0;
    if (!hasSet && !hasUnset) {
      return res.status(400).json({ message: 'No fields to update' });
    }

    const updateDoc = {};
    if (hasSet) updateDoc.$set = $set;
    if (hasUnset) updateDoc.$unset = $unset;

    const variant = await Variant.findByIdAndUpdate(id, updateDoc, { new: true }).lean().exec();
    if (!variant) {
      return res.status(404).json({ message: 'Variant not found' });
    }
    return res.json(variant);
  } catch (error) {
    if (error.code === 11000) {
      return res.status(409).json({ message: 'SKU or barcode already exists' });
    }
    console.error('Error updating variant:', error);
    return res.status(500).json({ message: 'Failed to update variant' });
  }
});

export default router;

