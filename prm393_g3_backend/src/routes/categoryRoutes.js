import express from 'express';
import Category from '../models/categories.js';
import { authenticate, requireCatalogEditor } from '../middleware/authMiddleware.js';

const router = express.Router();

const catalogEditor = [authenticate, requireCatalogEditor];

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

// POST /api/categories
router.post('/', ...catalogEditor, async (req, res) => {
  try {
    const { name, status } = req.body ?? {};
    if (typeof name !== 'string' || !name.trim()) {
      return res.status(400).json({ message: 'Name is required' });
    }
    const nextStatus = status === 'INACTIVE' ? 'INACTIVE' : 'ACTIVE';
    const category = await Category.create({
      name: name.trim(),
      status: nextStatus,
    });
    return res.status(201).json(category.toObject());
  } catch (error) {
    console.error('Error creating category:', error);
    return res.status(500).json({ message: 'Failed to create category' });
  }
});

// PATCH /api/categories/:id
router.patch('/:id', ...catalogEditor, async (req, res) => {
  try {
    const { name, status } = req.body ?? {};
    const updates = {};
    if (name !== undefined) {
      if (typeof name !== 'string' || !name.trim()) {
        return res.status(400).json({ message: 'Invalid name' });
      }
      updates.name = name.trim();
    }
    if (status !== undefined) {
      if (!['ACTIVE', 'INACTIVE'].includes(status)) {
        return res.status(400).json({ message: 'Invalid status' });
      }
      updates.status = status;
    }
    if (Object.keys(updates).length === 0) {
      return res.status(400).json({ message: 'No fields to update' });
    }
    const category = await Category.findByIdAndUpdate(req.params.id, { $set: updates }, { new: true })
      .lean()
      .exec();
    if (!category) {
      return res.status(404).json({ message: 'Category not found' });
    }
    return res.json(category);
  } catch (error) {
    console.error('Error updating category:', error);
    return res.status(500).json({ message: 'Failed to update category' });
  }
});

export default router;

