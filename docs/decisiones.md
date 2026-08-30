# Decisiones Técnicas

- **Base de Datos Compartida**: Se utiliza el prefijo `p2_` para todas las tablas (`p2_punto_control`, `p2_ronda`, `p2_marcacion`, `p2_usuario`) dado que la base de datos es NeonDB compartida con otros proyectos.
- **Validación de Geocerca**: Se hace en el servidor (backend) porque el cliente es manipulable (se puede simular la ubicación). Toda regla de negocio vive en el backend.
- **Tolerancia del GPS**: Al validar la distancia (Haversine), se suma el radio base del punto (ej. 40m) y la imprecisión del GPS (`Math.min(precisionM, 30)`) para no castigar al usuario por una mala señal de GPS, hasta un tope de 30m extra.
- **SQLite y Offline First**: La aplicación en Flutter utiliza `sqflite` para guardar los puntos de control y poder validar de manera aproximada offline, y almacena las lecturas en una cola para sincronizarlas al servidor luego conservando `latitud`, `longitud` original y el `escaneadaEn`.
- **Usuarios de Prueba**: Se crea una tabla `p2_usuario` básica, simulando un contexto real, donde un usuario puede abrir una ronda. No se incluyeron módulos de autenticación complejos, sino que se inyecta un mock authentication para facilitar pruebas del P2.
- **Librería de escáner**: Se utiliza `mobile_scanner` configurado con `DetectionSpeed.noDuplicates` para que lea los códigos en ráfaga (sin requerir presionar un botón de captura).
- **Vibración y Haptic Feedback**: Se configuró la vibración utilizando `HapticFeedback` nativo de Flutter, donde el impacto medio significa que el punto fue registrado y una vibración normal ocurre si el punto fue rechazado o la señal GPS es mala.
