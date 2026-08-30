import express from 'express';
import { abrirRonda, registrarMarcacion, obtenerEstadoRonda, cerrarRonda } from '../controladores/rondas.js';

const router = express.Router();

router.post('/', abrirRonda);
router.get('/:id', obtenerEstadoRonda);
router.post('/:id/marcaciones', registrarMarcacion);
router.patch('/:id/cerrar', cerrarRonda);

export default router;
