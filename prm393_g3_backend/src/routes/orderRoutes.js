import { Router } from 'express';
import orderController from '../controllers/orderController.js';

const router = Router();

router.get('/', orderController.getAll);
router.post('/', orderController.create);

export default router;
