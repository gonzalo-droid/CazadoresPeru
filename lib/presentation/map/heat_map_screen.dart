// ignore_for_file: uri_does_not_exist, undefined_class, undefined_function, undefined_identifier, undefined_method, non_type_as_type_argument, const_initialized_with_non_constant_value, non_constant_map_value
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/constants/app_colors.dart';
import '../../core/router/app_router.dart';
import '../../domain/entities/criminal_summary.dart';
import '../shared/widgets/criminal_photo.dart';
import '../shared/widgets/reward_badge.dart';
import 'map_provider.dart';

// Coordenadas aproximadas de centros de departamentos del Perú
const _depCoords = <String, LatLng>{
  'AMAZONAS': LatLng(-5.5, -78.0),
  'ANCASH': LatLng(-9.5, -77.5),
  'APURÍMAC': LatLng(-14.0, -73.0),
  'AREQUIPA': LatLng(-16.4, -71.5),
  'AYACUCHO': LatLng(-13.2, -74.2),
  'CAJAMARCA': LatLng(-7.2, -78.5),
  'CALLAO': LatLng(-12.0, -77.1),
  'CUSCO': LatLng(-13.5, -71.9),
  'HUANCAVELICA': LatLng(-12.8, -75.0),
  'HUÁNUCO': LatLng(-9.9, -76.2),
  'ICA': LatLng(-14.1, -75.7),
  'JUNÍN': LatLng(-11.8, -75.2),
  'LA LIBERTAD': LatLng(-8.1, -78.0),
  'LAMBAYEQUE': LatLng(-6.7, -79.9),
  'LIMA': LatLng(-12.0, -76.9),
  'LORETO': LatLng(-4.5, -75.0),
  'MADRE DE DIOS': LatLng(-12.6, -69.2),
  'MOQUEGUA': LatLng(-17.2, -70.9),
  'PASCO': LatLng(-10.7, -75.2),
  'PIURA': LatLng(-5.2, -80.6),
  'PUNO': LatLng(-15.8, -70.0),
  'SAN MARTÍN': LatLng(-6.5, -76.4),
  'TACNA': LatLng(-17.9, -70.3),
  'TUMBES': LatLng(-3.6, -80.5),
  'UCAYALI': LatLng(-8.4, -74.5),
};

class HeatMapScreen extends ConsumerStatefulWidget {
  const HeatMapScreen({super.key});

  @override
  ConsumerState<HeatMapScreen> createState() => _HeatMapScreenState();
}

class _HeatMapScreenState extends ConsumerState<HeatMapScreen> {
  GoogleMapController? _mapController;

  static const _peru = LatLng(-9.19, -75.01);
  static const _initialCamera = CameraPosition(
    target: _peru,
    zoom: 5.0,
  );

  @override
  Widget build(BuildContext context) {
    final filterDelito = ref.watch(mapFilterNotifierProvider);
    final dataAsync = ref.watch(
      criminalsByDepartamentoProvider(idDelito: filterDelito),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de Calor'),
      ),
      body: Stack(
        children: [
          dataAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) =>
                const Center(child: Text('Error cargando datos del mapa')),
            data: (byDep) {
              final markers = _buildMarkers(byDep, context);
              return GoogleMap(
                initialCameraPosition: _initialCamera,
                markers: markers,
                onMapCreated: (c) => _mapController = c,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: true,
                mapType: MapType.normal,
              );
            },
          ),

          // Filter pill
          Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.filter_alt_outlined, size: 18),
                    const Gap(8),
                    Text(
                      filterDelito != null
                          ? 'Delito: $filterDelito'
                          : 'Todos los delitos',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const Spacer(),
                    if (filterDelito != null)
                      GestureDetector(
                        onTap: () => ref
                            .read(mapFilterNotifierProvider.notifier)
                            .setDelito(null),
                        child: const Icon(Icons.close, size: 18),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Set<Marker> _buildMarkers(
    Map<String, List<CriminalSummary>> byDep,
    BuildContext context,
  ) {
    final markers = <Marker>{};

    for (final entry in byDep.entries) {
      final dep = entry.key;
      final criminals = entry.value;
      final coords = _depCoords[dep.toUpperCase()];
      if (coords == null) continue;

      final count = criminals.length;
      final color = count > 20
          ? BitmapDescriptor.hueRed
          : count > 10
              ? BitmapDescriptor.hueOrange
              : BitmapDescriptor.hueGreen;

      markers.add(
        Marker(
          markerId: MarkerId(dep),
          position: coords,
          icon: BitmapDescriptor.defaultMarkerWithHue(color),
          infoWindow: InfoWindow(
            title: dep,
            snippet: '$count requisitoriados',
            onTap: () => _showDepartamentoSheet(context, dep, criminals),
          ),
        ),
      );
    }

    return markers;
  }

  void _showDepartamentoSheet(
    BuildContext context,
    String dep,
    List<CriminalSummary> criminals,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, ctrl) => Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(dep, style: Theme.of(context).textTheme.headlineSmall),
                  const Gap(8),
                  Chip(label: Text('${criminals.length}')),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                controller: ctrl,
                itemCount: criminals.length,
                itemBuilder: (ctx, i) {
                  final c = criminals[i];
                  return ListTile(
                    leading: CriminalPhoto(base64Photo: c.foto, size: 48),
                    title: Text(
                      c.displayName,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      c.allDelitos.isNotEmpty ? c.allDelitos.first : '',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: RewardBadge(amount: c.montoRecompensa),
                    onTap: () {
                      Navigator.pop(ctx);
                      context.push(
                        '${AppRoutes.detail}/${c.hashRequisitoriado}',
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
