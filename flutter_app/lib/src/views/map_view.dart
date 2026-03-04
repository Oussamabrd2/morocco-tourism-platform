/// lib/views/map_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/api_service.dart';
import '../models/location_model.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});
  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  late Future<List<LocationModel>> _future;
  String _search = '';
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _future = ApiService().fetchLocations();
  }

  Future<void> _onRefresh() async =>
      setState(() => _future = ApiService().fetchLocations());

  LatLng _center(List<LocationModel> locs) {
    if (locs.isEmpty) return const LatLng(31.7917, -7.0926); // Morocco center
    double lat = 0, lng = 0;
    for (final l in locs) { lat += l.latitude ?? 0; lng += l.longitude ?? 0; }
    return LatLng(lat / locs.length, lng / locs.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
          title: const Text('Carte Touristique', style: TextStyle(color: Colors.white))),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Rechercher un lieu...',
              hintStyle: const TextStyle(color: Colors.grey),
              prefixIcon: const Icon(Icons.search, color: Colors.orange),
              filled: true, fillColor: const Color(0xFF1A1A1A),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
            ),
            onChanged: (v) => setState(() => _search = v.toLowerCase()),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<LocationModel>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.orange));
              }
              if (snapshot.hasError) {
                return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text('${snapshot.error}', style: const TextStyle(color: Colors.white)),
                  TextButton(onPressed: _onRefresh,
                      child: const Text('Réessayer', style: TextStyle(color: Colors.orange))),
                ]));
              }
              final all = snapshot.data ?? [];
              final filtered = all
                  .where((l) => l.name.toLowerCase().contains(_search))
                  .where((l) => l.latitude != null && l.longitude != null)
                  .toList();

              if (filtered.isEmpty) {
                return Center(
                    child: Text(_search.isEmpty ? 'Aucun lieu avec coordonnées' : 'Pas de résultats',
                        style: const TextStyle(color: Colors.grey)));
              }

              return FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _center(filtered),
                  initialZoom: 10,
                  interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.ziarat.app',
                  ),
                  MarkerLayer(
                    markers: filtered.map((l) => Marker(
                      point: LatLng(l.latitude!, l.longitude!),
                      width: 40, height: 40,
                      child: GestureDetector(
                        onTap: () => _showSheet(context, l),
                        child: const Icon(Icons.location_on, color: Colors.orange, size: 40),
                      ),
                    )).toList(),
                  ),
                ],
              );
            },
          ),
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: () async {
          final locs = (await _future)
              .where((l) => l.latitude != null && l.longitude != null).toList();
          if (locs.isNotEmpty) _mapController.move(_center(locs), 12);
        },
        child: const Icon(Icons.my_location, color: Colors.white),
      ),
    );
  }

  void _showSheet(BuildContext ctx, LocationModel loc) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(loc.name,
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (loc.description.isNotEmpty)
            Text(loc.description, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.star, color: Colors.amber, size: 18),
            const SizedBox(width: 4),
            Text('${loc.averageRating.toStringAsFixed(1)}/5 • ${loc.reviewsCount} avis',
                style: const TextStyle(color: Colors.amber)),
          ]),
        ]),
      ),
    );
  }
}
