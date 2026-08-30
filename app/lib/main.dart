import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentacion/paginas/escaner_ronda.dart';
import 'presentacion/providers/ronda_provider.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ronda Segura',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const HomeRonda(),
    );
  }
}

class HomeRonda extends ConsumerWidget {
  const HomeRonda({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rondaId = ref.watch(estadoRondaProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ronda Segura'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (rondaId == null) ...[
              ElevatedButton(
                onPressed: () async {
                  final repo = ref.read(rondaRepoProvider);
                  try {
                    await repo.sincronizarPuntos(); // Traer puntos al inicio
                    final id = await repo.abrirRonda();
                    ref.read(estadoRondaProvider.notifier).state = id;
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ronda iniciada')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al iniciar ronda: $e')),
                      );
                    }
                  }
                },
                child: const Text('Iniciar Ronda'),
              ),
            ] else ...[
              const Text('Ronda en curso'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EscanerRonda()),
                  );
                },
                child: const Text('Ir a escanear'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final repo = ref.read(rondaRepoProvider);
                  try {
                    await repo.sincronizarMarcacionesPendientes(rondaId);
                    final cumplimiento = await repo.cerrarRonda(rondaId);
                    ref.read(estadoRondaProvider.notifier).state = null;
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Ronda cerrada. Cumplimiento: $cumplimiento%')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al cerrar ronda: $e')),
                      );
                    }
                  }
                },
                child: const Text('Sincronizar y Cerrar Ronda'),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
