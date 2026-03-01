import express from 'express';
import Variant from '../models/variant.js';

const router = express.Router();

// GET /api/variants
// Optional query: ?productId=product_001
router.get('/', async (req, res) => {
  try {
    const { productId } = req.query;
    const filter = {};

    if (productId) {
      filter.productId = productId;
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

