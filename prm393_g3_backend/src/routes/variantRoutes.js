import express from 'express';
import mongoose from 'mongoose';
import Variant from '../models/variant.js';

const router = express.Router();

// GET /api/variants
// Optional query: ?productId=<id> (matches string or ObjectId stored in DB)
router.get('/', async (req, res) => {
  try {
    const { productId } = req.query;
    const filter = {};

    if (productId) {
      const idStr = String(productId);
      if (mongoose.Types.ObjectId.isValid(idStr)) {
        const oid = new mongoose.Types.ObjectId(idStr);
        filter.$or = [{ productId: idStr }, { productId: oid }];
      } else {
        filter.productId = idStr;
      }
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

export default router;

