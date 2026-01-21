import { Router } from 'express';
import productController from '../controllers/productController.js';

const router = Router();

router.get('/', productController.getAll);
router.get('/:id', productController.getById);
router.post('/', productController.create);
router.patch('/:id/stock', productController.updateStock);

export default router;
