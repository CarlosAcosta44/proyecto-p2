import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/ronda_provider.dart';

class EscanerRonda extends ConsumerStatefulWidget {
  const EscanerRonda({Key? key}) : super(key: key);

  @override
  ConsumerState<EscanerRonda> createState() => _EscanerRondaState();
}

class _EscanerRondaState extends ConsumerState<EscanerRonda> {
  bool _procesando = false;

  void _mostrarExito(String mensaje) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  mensaje,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _mostrarError(String mensaje) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  mensaje,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  late final MobileScannerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ronda en curso')),
      body: MobileScanner(
        controller: _controller,
        onDetect: (captura) async {
          if (captura.barcodes.isEmpty) return;
          final codigo = captura.barcodes.first.rawValue;
          if (codigo == null || _procesando) return;
          _procesando = true;

          Position? pos;
          try {
            pos = await Geolocator.getCurrentPosition(
              locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
            ).timeout(const Duration(seconds: 5));
          } catch (_) {}

          if (pos == null) {
            try {
              pos = await Geolocator.getLastKnownPosition().timeout(const Duration(seconds: 2));
            } catch (_) {}
          }
          
          if (pos == null) {
            pos = Position(
              longitude: 0.0, latitude: 0.0, timestamp: DateTime.now(), 
              accuracy: 10, altitude: 0.0, heading: 0.0, speed: 0.0, speedAccuracy: 0.0, 
              altitudeAccuracy: 0.0, headingAccuracy: 0.0
            );
          }

          final repo = ref.read(rondaRepoProvider);
          final rondaId = ref.read(estadoRondaProvider);

          if (rondaId == null) {
            _mostrarError('No hay una ronda abierta.');
            _procesando = false;
            return;
          }

          try {
            final r = await repo.marcar(
              rondaId: rondaId,
              codigo: codigo,
              latitud: pos.latitude,
              longitud: pos.longitude,
              precisionM: pos.accuracy,
              escaneadaEn: DateTime.now().toUtc().toIso8601String(),
            );

            if (r['aceptada'] == true) {
              await HapticFeedback.mediumImpact();
              _mostrarExito('¡Punto registrado exitosamente!');
              if (mounted) {
                Navigator.pop(context); // Cierra la cámara
              }
            } else {
              await HapticFeedback.vibrate();
              _mostrarError(r['motivo_rechazo'] ?? 'Punto rechazado');
            }
          } catch (e) {
            await HapticFeedback.vibrate();
            _mostrarError('Error: código inválido o sin conexión.');
          } finally {
            await Future.delayed(const Duration(seconds: 2));
            _procesando = false;
          }
        },
      ),
    );
  }
}
