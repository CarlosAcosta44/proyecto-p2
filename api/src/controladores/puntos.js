import { prisma } from '../prisma.js';

export async function listarPuntos(req, res, next) {
  try {
    const puntos = await prisma.p2_punto_control.findMany({
      orderBy: { orden: 'asc' }
    });
    res.status(200).json(puntos);
  } catch (e) {
    next(e);
  }
}
