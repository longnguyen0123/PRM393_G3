import express from 'express';
import Brand from '../models/brand.js';

const router = express.Router();

// GET /api/brands
router.get('/', async (_req, res) => {
  try {
    const brands = await Brand.find().lean().exec();
    return res.json(brands);
  } catch (error) {
    console.error('Error fetching brands:', error);
    return res.status(500).json({
      message: 'Failed to fetch brands',
    });
  }
});

export default router;

