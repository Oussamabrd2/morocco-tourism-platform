/// lib/views/guide_view.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/location_model.dart';

class GuideView extends StatefulWidget {
  const GuideView({super.key});
  @override
  State<GuideView> createState() => _GuideViewState();
}

class _GuideViewState extends State<GuideView> {
  late Future<List<LocationModel>> _future;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _future = ApiService().fetchLocations();
  }

  Future<void> _onRefresh() async =>
      setState(() => _future = ApiService().fetchLocations());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Guide des Lieux',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 22)),
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(16),
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
          child: RefreshIndicator(
            onRefresh: _onRefresh, color: Colors.orange,
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
                final locs = (snapshot.data ?? [])
                    .where((l) => l.name.toLowerCase().contains(_search))
                    .toList();
                if (locs.isEmpty) {
                  return Center(
                      child: Text(_search.isEmpty ? 'Aucun lieu' : 'Pas de résultats',
                          style: const TextStyle(color: Colors.grey)));
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: locs.length,
                  itemBuilder: (_, i) => _card(locs[i]),
                );
              },
            ),
          ),
        ),
      ]),
    );
  }

  Widget _card(LocationModel loc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade900)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: const CircleAvatar(
            backgroundColor: Colors.orange,
            child: Icon(Icons.location_on, color: Colors.black)),
        title: Text(loc.name,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, children: [
          if (loc.description.isNotEmpty)
            Text(loc.description,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
                maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Row(children: [
            const Icon(Icons.star, color: Colors.amber, size: 14),
            const SizedBox(width: 4),
            Text('${loc.averageRating.toStringAsFixed(1)}/5',
                style: const TextStyle(color: Colors.amber, fontSize: 12)),
            const SizedBox(width: 12),
            Text('${loc.reviewsCount} avis',
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ]),
        ]),
      ),
    );
  }
}
