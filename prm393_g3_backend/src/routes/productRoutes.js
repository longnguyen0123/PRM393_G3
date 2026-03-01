import express from 'express';
import Product from '../models/product.js';

const router = express.Router();

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

export default router;

