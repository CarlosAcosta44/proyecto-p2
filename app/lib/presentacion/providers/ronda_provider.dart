import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../datos/local/base_local.dart';
import '../../datos/remoto/cliente_api.dart';
import '../../dominio/repositorios/ronda_repository.dart';

final apiProvider = Provider((ref) => ClienteApi());
final localProvider = Provider((ref) => BaseLocal());

final rondaRepoProvider = Provider((ref) {
  return RondaRepository(ref.watch(localProvider), ref.watch(apiProvider));
});

final estadoRondaProvider = StateProvider<String?>((ref) => null);
