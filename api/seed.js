import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();

async function main() {
  // Asegurar que exista el usuario 1
  const user = await prisma.p2_usuario.findFirst({ where: { id: 1 } });
  if (!user) {
    // Si la tabla está vacía y usamos autoincrement, el primer insert será ID 1.
    // O forzamos el ID 1 (PostgreSQL permite hacer insert con ID explícito).
    await prisma.$executeRaw`INSERT INTO "p2_usuario" (id, nombre, rol) VALUES (1, 'Vigilante Demo', 'vigilante') ON CONFLICT DO NOTHING;`;
  }

  // Insertar un par de puntos de control de prueba
  // Ponemos un radio de 20 millones de metros para que el GPS no te rechace la marcación
  // sin importar en qué parte del mundo estés haciendo la prueba.
  await prisma.p2_punto_control.upsert({
    where: { codigo: 'PUNTO-A' },
    update: {},
    create: { codigo: 'PUNTO-A', nombre: 'Recepción', latitud: 0.0, longitud: 0.0, radio_m: 20000000, orden: 1 }
  });

  await prisma.p2_punto_control.upsert({
    where: { codigo: 'PUNTO-B' },
    update: {},
    create: { codigo: 'PUNTO-B', nombre: 'Bodega', latitud: 0.0, longitud: 0.0, radio_m: 20000000, orden: 2 }
  });

  console.log('✅ Base de datos poblada exitosamente con el Usuario 1 y Puntos de Control.');
}

main()
  .catch(console.error)
  .finally(async () => {
    await prisma.$disconnect();
  });
