import express from 'express';
import Category from '../models/categories.js';

const router = express.Router();

// GET /api/categories
router.get('/', async (_req, res) => {
  try {
    const categories = await Category.find().lean().exec();
    return res.json(categories);
  } catch (error) {
    console.error('Error fetching categories:', error);
    return res.status(500).json({
      message: 'Failed to fetch categories',
    });
  }
});

export default router;

