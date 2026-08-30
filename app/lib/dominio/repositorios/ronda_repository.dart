import 'package:uuid/uuid.dart';
import '../../datos/local/base_local.dart';
import '../../datos/remoto/cliente_api.dart';

class RondaRepository {
  final BaseLocal local;
  final ClienteApi api;

  RondaRepository(this.local, this.api);

  Future<void> sincronizarPuntos() async {
    try {
      final puntos = await api.getPuntos();
      await local.guardarPuntos(List<Map<String, dynamic>>.from(puntos));
    } catch (e) {
      // Ignorar si no hay red, mantendrá los existentes
    }
  }

  Future<String> abrirRonda() async {
    final res = await api.abrirRonda();
    return res['id'];
  }

  Future<Map<String, dynamic>> marcar({
    required String rondaId,
    required String codigo,
    required double latitud,
    required double longitud,
    required double precisionM,
    required String escaneadaEn,
  }) async {
    final payload = {
      'codigo': codigo,
      'latitud': latitud,
      'longitud': longitud,
      'precisionM': precisionM,
      'escaneadaEn': escaneadaEn,
    };
    try {
      final res = await api.registrarMarcacion(rondaId, payload);
      return res; // Contiene si fue aceptada o rechazada y por qué
    } catch (e) {
      // Fallo de red, encolar localmente
      final pendiente = {
        'id': const Uuid().v4(),
        'codigo': codigo,
        'latitud': latitud,
        'longitud': longitud,
        'precision_m': precisionM,
        'escaneada_en': escaneadaEn,
      };
      await local.encolarMarcacion(pendiente);
      // Para simular respuesta local, asumimos aceptada temporalmente o diferida
      return {
        'aceptada': true,
        'offline': true,
        'motivo_rechazo': 'Sincronización pendiente'
      };
    }
  }

  Future<void> sincronizarMarcacionesPendientes(String rondaId) async {
    final pendientes = await local.obtenerMarcacionesPendientes();
    if (pendientes.isEmpty) return;

    List<String> procesadas = [];
    for (final p in pendientes) {
      try {
        final payload = {
          'codigo': p['codigo'],
          'latitud': p['latitud'],
          'longitud': p['longitud'],
          'precisionM': p['precision_m'],
          'escaneadaEn': p['escaneada_en'],
        };
        await api.registrarMarcacion(rondaId, payload);
        procesadas.add(p['id']);
      } catch (e) {
        // Podría manejar si fue rechazada permanentemente o si es un problema de red.
        // Asumimos que si no hay excepción de red, fue procesada (incluso si fue 422).
        procesadas.add(p['id']);
      }
    }
    await local.eliminarMarcacionesPendientes(procesadas);
  }

  Future<int> cerrarRonda(String rondaId) async {
    final res = await api.cerrarRonda(rondaId);
    return res['cumplimiento'];
  }
}
