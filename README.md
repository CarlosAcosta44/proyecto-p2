# Proyecto P2: Ronda Segura

Ronda Segura es una aplicación móvil y backend diseñada para el control y seguimiento de rondas de vigilancia. Permite a los guardias de seguridad escanear códigos QR distribuidos geográficamente en puntos de control para validar su asistencia en tiempo real, midiendo la precisión de su ubicación vía GPS.

## Arquitectura del Proyecto

El proyecto está dividido en dos partes principales:
- **Backend (`api/`)**: Desarrollado en Node.js con Express y Prisma ORM. Se conecta a una base de datos PostgreSQL alojada en NeonDB. Provee los endpoints REST para iniciar rondas, sincronizar puntos de control y registrar marcaciones.
- **Frontend (`app/`)**: Aplicación móvil desarrollada en Flutter. Utiliza `mobile_scanner` para la lectura de códigos QR, `geolocator` para validar la distancia del vigilante frente al punto de control y `Riverpod` para el manejo de estado. Tiene soporte offline mediante SQLite (`sqflite`).

## Códigos QR de Prueba

Para probar el escáner de la aplicación móvil directamente desde la pantalla de la computadora, puedes utilizar los siguientes códigos QR correspondientes a los puntos de control insertados por defecto en la base de datos de pruebas. Tienen un radio de tolerancia GPS gigante (20,000 km) para permitir pruebas en interiores desde cualquier ubicación.

| Punto A (Recepción) | Punto B (Bodega) |
|:---:|:---:|
| ![QR Punto A](docs/assets/qr_punto_a.png) | ![QR Punto B](docs/assets/qr_punto_b.png) |

## ¿Cómo descargar e instalar el APK?

Puedes descargar la última versión compilada de la aplicación (APK) directamente desde la sección de **Releases** en este repositorio de GitHub. 
1. Ve a la pestaña "Releases" a la derecha de la página del repositorio.
2. Descarga el archivo `app-release.apk` (o `app-debug.apk`).
3. Pásalo a tu celular Android e instálalo (es posible que debas permitir la instalación desde "Orígenes desconocidos").

> **Nota para producción**: Para que la app instalada en el celular funcione en cualquier red (y no solo en el Wi-Fi de tu casa), el backend (`api/`) debe estar desplegado en un servidor en la nube con una IP o Dominio público. Si ejecutas el backend localmente en tu PC (`localhost` o IP local `192.168.x.x`), el celular solo podrá conectarse si ambos dispositivos están en la misma red Wi-Fi.
