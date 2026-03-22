import express from 'express';
import Brand from '../models/brand.js';
import { authenticate, requireAdmin } from '../middleware/authMiddleware.js';

const router = express.Router();

const adminOnly = [authenticate, requireAdmin];

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

// POST /api/brands
router.post('/', ...adminOnly, async (req, res) => {
  try {
    const { name, status } = req.body ?? {};
    if (typeof name !== 'string' || !name.trim()) {
      return res.status(400).json({ message: 'Name is required' });
    }
    const nextStatus = status === 'INACTIVE' ? 'INACTIVE' : 'ACTIVE';
    const brand = await Brand.create({
      name: name.trim(),
      status: nextStatus,
    });
    return res.status(201).json(brand.toObject());
  } catch (error) {
    console.error('Error creating brand:', error);
    return res.status(500).json({ message: 'Failed to create brand' });
  }
});

// PATCH /api/brands/:id
router.patch('/:id', ...adminOnly, async (req, res) => {
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
    const brand = await Brand.findByIdAndUpdate(req.params.id, { $set: updates }, { new: true })
      .lean()
      .exec();
    if (!brand) {
      return res.status(404).json({ message: 'Brand not found' });
    }
    return res.json(brand);
  } catch (error) {
    console.error('Error updating brand:', error);
    return res.status(500).json({ message: 'Failed to update brand' });
  }
});

export default router;

