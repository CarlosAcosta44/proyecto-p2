import express from 'express';
import { listarPuntos } from '../controladores/puntos.js';

const router = express.Router();

router.get('/', listarPuntos);

export default router;
