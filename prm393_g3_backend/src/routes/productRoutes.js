import express from 'express';
import Product from '../models/product.js';
import { authenticate, requireAdmin } from '../middleware/authMiddleware.js';

const router = express.Router();

const adminOnly = [authenticate, requireAdmin];

// GET /api/products
router.get('/', async (req, res) => {
  try {
    const { brandId, categoryId, search } = req.query;

    const filter = {};
    if (brandId) {
      filter.brandId = brandId;
    }
    if (categoryId) {
      filter.categoryId = categoryId;
    }
    if (search) {
      filter.name = { $regex: search, $options: 'i' };
    }

    // Note: brandId and categoryId are strings, not ObjectIds, so we can't use populate
    // Frontend will need to fetch brand/category names separately if needed
    const products = await Product.find(filter).lean().exec();

    return res.json(products);
  } catch (error) {
    console.error('Error fetching products:', error);
    return res.status(500).json({
      message: 'Failed to fetch products',
    });
  }
});

// POST /api/products
router.post('/', ...adminOnly, async (req, res) => {
  try {
    const { name, brandId, categoryId, description, status } = req.body ?? {};
    if (typeof name !== 'string' || !name.trim()) {
      return res.status(400).json({ message: 'Name is required' });
    }
    if (brandId == null || String(brandId).trim() === '') {
      return res.status(400).json({ message: 'brandId is required' });
    }
    if (categoryId == null || String(categoryId).trim() === '') {
      return res.status(400).json({ message: 'categoryId is required' });
    }
    const product = await Product.create({
      name: name.trim(),
      brandId: String(brandId).trim(),
      categoryId: String(categoryId).trim(),
      description: typeof description === 'string' ? description.trim() : undefined,
      status: status === 'INACTIVE' ? 'INACTIVE' : 'ACTIVE',
    });
    return res.status(201).json(product.toObject());
  } catch (error) {
    console.error('Error creating product:', error);
    return res.status(500).json({ message: 'Failed to create product' });
  }
});

// GET /api/products/:id
router.get('/:id', async (req, res) => {
  try {
    // Note: brandId and categoryId are strings, not ObjectIds
    const product = await Product.findById(req.params.id).lean().exec();

    if (!product) {
      return res.status(404).json({ message: 'Product not found' });
    }

    return res.json(product);
  } catch (error) {
    console.error('Error fetching product by id:', error);
    return res.status(500).json({
      message: 'Failed to fetch product',
    });
  }
});

// PATCH /api/products/:id
router.patch('/:id', ...adminOnly, async (req, res) => {
  try {
    const { name, brandId, categoryId, description, status } = req.body ?? {};
    const updates = {};
    if (name !== undefined) {
      if (typeof name !== 'string' || !name.trim()) {
        return res.status(400).json({ message: 'Invalid name' });
      }
      updates.name = name.trim();
    }
    if (brandId !== undefined) {
      if (String(brandId).trim() === '') {
        return res.status(400).json({ message: 'Invalid brandId' });
      }
      updates.brandId = String(brandId).trim();
    }
    if (categoryId !== undefined) {
      if (String(categoryId).trim() === '') {
        return res.status(400).json({ message: 'Invalid categoryId' });
      }
      updates.categoryId = String(categoryId).trim();
    }
    if (description !== undefined) {
      updates.description = typeof description === 'string' ? description.trim() : '';
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
    const product = await Product.findByIdAndUpdate(req.params.id, { $set: updates }, { new: true })
      .lean()
      .exec();
    if (!product) {
      return res.status(404).json({ message: 'Product not found' });
    }
    return res.json(product);
  } catch (error) {
    console.error('Error updating product:', error);
    return res.status(500).json({ message: 'Failed to update product' });
  }
});

export default router;

