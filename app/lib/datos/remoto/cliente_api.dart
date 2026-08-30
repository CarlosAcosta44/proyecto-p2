import 'package:dio/dio.dart';

class ClienteApi {
  // Ajustar base URL si se usa emulador de Android (10.0.2.2) u otra IP.
  final _dio = Dio(BaseOptions(
    baseUrl: 'http://192.168.11.10:3000/api',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
  ));

  ClienteApi() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // En un caso real inyectamos el token aquí.
        options.headers['Authorization'] = 'Bearer 1'; 
        return handler.next(options);
      }
    ));
  }

  Future<List<dynamic>> getPuntos() async {
    final res = await _dio.get('/puntos');
    return res.data;
  }

  Future<Map<String, dynamic>> abrirRonda() async {
    final res = await _dio.post('/rondas');
    return res.data;
  }

  Future<Map<String, dynamic>> registrarMarcacion(String rondaId, Map<String, dynamic> data) async {
    try {
      final res = await _dio.post('/rondas/$rondaId/marcaciones', data: data);
      return res.data;
    } on DioException catch (e) {
      if (e.response != null && e.response?.statusCode == 422) {
        // Devuelve el cuerpo (que incluye motivo de rechazo) para procesar
        return e.response?.data;
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> cerrarRonda(String rondaId) async {
    final res = await _dio.patch('/rondas/$rondaId/cerrar');
    return res.data;
  }
}
