import { prisma } from '../prisma.js';
import { distanciaMetros } from '../servicios/geocerca.js';

export async function abrirRonda(req, res, next) {
  try {
    // mock autenticacion: tomamos el primer usuario, o req.usuario_id
    const usuarioId = req.usuario_id || 1; 
    
    // Calcula vencimiento en 1 hora
    const vence_en = new Date();
    vence_en.setHours(vence_en.getHours() + 1);

    const ronda = await prisma.p2_ronda.create({
      data: {
        usuario_id: usuarioId,
        vence_en
      }
    });
    res.status(201).json(ronda);
  } catch (e) {
    next(e);
  }
}

export async function registrarMarcacion(req, res, next) {
  try {
    const { codigo, latitud, longitud, precisionM, escaneadaEn } = req.body;
    const punto = await prisma.p2_punto_control.findUnique({ where: { codigo } });
    if (!punto) return res.status(404).json({ error: 'Punto no reconocido' });

    const distancia = distanciaMetros(latitud, longitud, punto.latitud, punto.longitud);

    const tolerancia = punto.radio_m + Math.min(precisionM, 30);
    const aceptada = distancia <= tolerancia;

    const marcacion = await prisma.p2_marcacion.create({
      data: { 
        ronda_id: req.params.id, 
        punto_id: punto.id, 
        latitud, 
        longitud,
        precision_m: precisionM, 
        distancia_m: distancia, 
        aceptada,
        motivo_rechazo: aceptada ? null : `Fuera de rango: ${distancia.toFixed(0)} m`,
        escaneada_en: new Date(escaneadaEn) 
      },
    });

    res.status(aceptada ? 201 : 422).json(marcacion);
  } catch (e) {
    if (e.code === 'P2002') {
      return res.status(400).json({ error: 'Ya existe una marcación para este punto en esta ronda' });
    }
    next(e);
  }
}

export async function obtenerEstadoRonda(req, res, next) {
  try {
    const rondaId = req.params.id;
    const ronda = await prisma.p2_ronda.findUnique({
      where: { id: rondaId },
      include: { marcaciones: true }
    });
    if (!ronda) return res.status(404).json({ error: 'Ronda no encontrada' });
    
    res.status(200).json(ronda);
  } catch (e) {
    next(e);
  }
}

export async function cerrarRonda(req, res, next) {
  try {
    const rondaId = req.params.id;
    
    // Contamos puntos totales y visitados (marcaciones aceptadas)
    const puntos = await prisma.p2_punto_control.count();
    const marcaciones = await prisma.p2_marcacion.findMany({
      where: { ronda_id: rondaId, aceptada: true }
    });
    
    const visitados = new Set(marcaciones.map(m => m.punto_id)).size;
    const cumplimiento = puntos > 0 ? Math.round((visitados / puntos) * 100) : 0;
    
    await prisma.p2_ronda.update({
      where: { id: rondaId },
      data: { estado: 'cerrada' }
    });
    
    res.status(200).json({ cumplimiento });
  } catch (e) {
    next(e);
  }
}
