import { Router } from 'express';
import productRoutes from './productRoutes.js';
import storeRoutes from './storeRoutes.js';
import orderRoutes from './orderRoutes.js';

const router = Router();

router.use('/products', productRoutes);
router.use('/stores', storeRoutes);
router.use('/orders', orderRoutes);

export default router;
