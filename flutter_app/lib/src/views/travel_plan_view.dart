/// lib/views/travel_plan_view.dart
import 'package:flutter/material.dart';
import '../models/travel_plan_model.dart';
import '../services/travel_plan_service.dart';


class TravelPlanLauncher {
  static Future<void> show(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _TravelPlanDialog(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dialog — asks city + number of days
// ─────────────────────────────────────────────────────────────────────────────

class _TravelPlanDialog extends StatefulWidget {
  const _TravelPlanDialog();

  @override
  State<_TravelPlanDialog> createState() => _TravelPlanDialogState();
}

class _TravelPlanDialogState extends State<_TravelPlanDialog> {
  final _villeCtrl = TextEditingController();
  int _days = 3;
  bool _loading = false;
  String? _error;

  static const _moroccanCities = [
    'Marrakech', 'Casablanca', 'Fès', 'Rabat', 'Tanger',
    'Agadir', 'Meknès', 'Ouarzazate', 'Essaouira', 'Chefchaouen',
    'El Jadida', 'Tétouan', 'Ifrane', 'Errachidia', 'Laâyoune',
  ];

  @override
  void dispose() {
    _villeCtrl.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final ville = _villeCtrl.text.trim();
    if (ville.isEmpty) {
      setState(() => _error = 'Veuillez entrer une ville');
      return;
    }

    setState(() { _loading = true; _error = null; });

    try {
      final plan = await TravelPlanService().generate(
        ville: ville,
        days: _days,
      );
      if (!mounted) return;
      Navigator.pop(context); // close dialog
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => TravelPlanScreen(plan: plan)),
      );
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0F0F0F),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [

          // Handle bar
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade700,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Header
          Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.map_outlined, color: Colors.orangeAccent, size: 22),
            ),
            const SizedBox(width: 14),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Générer un Plan', style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                )),
                Text('Votre itinéraire personnalisé', style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                )),
              ],
            ),
          ]),
          const SizedBox(height: 28),

          // City field with autocomplete
          Autocomplete<String>(
            optionsBuilder: (val) => _moroccanCities
                .where((c) => c.toLowerCase().contains(val.text.toLowerCase())),
            onSelected: (v) => _villeCtrl.text = v,
            fieldViewBuilder: (_, ctrl, focus, __) {
              // sync controllers
              ctrl.text = _villeCtrl.text;
              ctrl.addListener(() => _villeCtrl.text = ctrl.text);
              return TextField(
                controller: ctrl,
                focusNode: focus,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                decoration: InputDecoration(
                  labelText: 'Ville',
                  labelStyle: const TextStyle(color: Colors.grey),
                  hintText: 'Ex: Marrakech',
                  hintStyle: const TextStyle(color: Colors.white24),
                  prefixIcon: const Icon(Icons.location_city_outlined,
                      color: Colors.orangeAccent, size: 20),
                  filled: true,
                  fillColor: const Color(0xFF1A1A1A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Colors.orangeAccent),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 16),
                ),
              );
            },
            optionsViewBuilder: (_, onSel, opts) => Align(
              alignment: Alignment.topLeft,
              child: Material(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: opts.length,
                    itemBuilder: (_, i) {
                      final opt = opts.elementAt(i);
                      return ListTile(
                        dense: true,
                        leading: const Icon(Icons.location_on_outlined,
                            color: Colors.orangeAccent, size: 16),
                        title: Text(opt, style: const TextStyle(
                            color: Colors.white, fontSize: 14)),
                        onTap: () => onSel(opt),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Days selector
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Nombre de jours',
                    style: TextStyle(color: Colors.white, fontSize: 14,
                        fontWeight: FontWeight.w600)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.orangeAccent.withOpacity(0.3)),
                  ),
                  child: Text('$_days jour${_days > 1 ? 's' : ''}',
                      style: const TextStyle(
                          color: Colors.orangeAccent,
                          fontWeight: FontWeight.w700,
                          fontSize: 13)),
                ),
              ]),
              const SizedBox(height: 12),
              Row(
                children: List.generate(7, (i) {
                  final d = i + 1;
                  final sel = _days == d;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _days = d),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: sel
                              ? Colors.orangeAccent
                              : Colors.black.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(10),
                          border: sel
                              ? null
                              : Border.all(color: Colors.grey.shade800),
                        ),
                        child: Text('$d',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: sel ? Colors.black : Colors.grey,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            )),
                      ),
                    ),
                  );
                }),
              ),
            ]),
          ),

          if (_error != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
              ),
              child: Row(children: [
                const Icon(Icons.error_outline, color: Colors.redAccent, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(_error!,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 13))),
              ]),
            ),
          ],

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              onPressed: _loading ? null : _generate,
              child: _loading
                  ? const SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.black, strokeWidth: 2))
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_awesome, size: 18),
                        SizedBox(width: 8),
                        Text('GÉNÉRER MON PLAN',
                            style: TextStyle(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1)),
                      ],
                    ),
            ),
          ),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TravelPlanScreen — displays the generated itinerary
// ─────────────────────────────────────────────────────────────────────────────

class TravelPlanScreen extends StatelessWidget {
  final TravelPlan plan;

  const TravelPlanScreen({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ──────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: Colors.black,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1A0A00), Color(0xFF000000)],
                  ),
                ),
                child: Stack(children: [
                  // Decorative circles
                  Positioned(top: -20, right: -20,
                    child: Container(width: 120, height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.orange.withOpacity(0.06),
                      ),
                    ),
                  ),
                  Positioned(bottom: 0, left: -30,
                    child: Container(width: 80, height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.orange.withOpacity(0.04),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 70, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(plan.ville,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(children: [
                          _PillBadge(
                            icon: Icons.calendar_today,
                            label: '${plan.days} jour${plan.days > 1 ? "s" : ""}',
                            color: Colors.orangeAccent,
                          ),
                          const SizedBox(width: 8),
                          _PillBadge(
                            icon: Icons.place_outlined,
                            label: '${plan.totalPlaces} lieux disponibles',
                            color: Colors.blue,
                          ),
                        ]),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined, color: Colors.white),
                onPressed: () {}, // TODO: share plan
              ),
            ],
          ),

          // ── Day cards ────────────────────────────────────────────────────
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final entry = plan.sortedDays[i];
                final dayNum = int.tryParse(
                    entry.key.replaceAll('day_', '')) ?? (i + 1);
                return _DayCard(
                  dayNumber: dayNum,
                  places: entry.value,
                  isLast: i == plan.sortedDays.length - 1,
                );
              },
              childCount: plan.sortedDays.length,
            ),
          ),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 40),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Day card widget
// ─────────────────────────────────────────────────────────────────────────────

class _DayCard extends StatefulWidget {
  final int dayNumber;
  final List<TravelPlace> places;
  final bool isLast;

  const _DayCard({
    required this.dayNumber,
    required this.places,
    this.isLast = false,
  });

  @override
  State<_DayCard> createState() => _DayCardState();
}

class _DayCardState extends State<_DayCard> {
  bool _expanded = true;

  double get _totalDuree =>
      widget.places.fold(0, (sum, p) => sum + p.duree);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Timeline ──────────────────────────────────────────────────
          SizedBox(
            width: 40,
            child: Column(children: [
              const SizedBox(height: 20),
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: Colors.orangeAccent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Center(
                  child: Text('${widget.dayNumber}',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              if (!widget.isLast)
                Container(
                  width: 2,
                  height: _expanded
                      ? (widget.places.length * 88.0 + 60)
                      : 20,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.orange.withOpacity(0.5),
                        Colors.orange.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
            ]),
          ),

          const SizedBox(width: 12),

          // ── Card ──────────────────────────────────────────────────────
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16, top: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F0F0F),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF1E1E1E)),
              ),
              child: Column(children: [
                // Day header
                InkWell(
                  onTap: () => setState(() => _expanded = !_expanded),
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(18)),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
                    child: Row(children: [
                      Text('Jour ${widget.dayNumber}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('${widget.places.length} étapes',
                          style: const TextStyle(
                              color: Colors.orangeAccent, fontSize: 11,
                              fontWeight: FontWeight.w600)),
                      ),
                      const Spacer(),
                      Text('~${_totalDuree.toStringAsFixed(0)}h',
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 12)),
                      const SizedBox(width: 4),
                      Icon(
                        _expanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: Colors.grey,
                        size: 20,
                      ),
                    ]),
                  ),
                ),

                // Places list
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: _expanded
                      ? Column(
                          children: widget.places.asMap().entries.map((e) {
                            return _PlaceRow(
                              place: e.value,
                              index: e.key,
                              isLast: e.key == widget.places.length - 1,
                            );
                          }).toList(),
                        )
                      : const SizedBox.shrink(),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceRow extends StatelessWidget {
  final TravelPlace place;
  final int index;
  final bool isLast;

  const _PlaceRow({
    required this.place,
    required this.index,
    this.isLast = false,
  });

  static const Map<String, _CatStyle> _styles = {
    'place':      _CatStyle(Colors.blue,       Icons.account_balance_outlined, 'Lieu'),
    'restaurant': _CatStyle(Colors.red,        Icons.restaurant_outlined,      'Restaurant'),
    'activity':   _CatStyle(Colors.green,      Icons.directions_run,           'Activité'),
    'cafe':       _CatStyle(Colors.brown,      Icons.coffee_outlined,          'Café'),
  };

  _CatStyle get _style =>
      _styles[place.categorie] ?? const _CatStyle(Colors.grey, Icons.place_outlined, 'Lieu');

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: Colors.white.withOpacity(0.04))),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Row(children: [
          // Step number
          Container(
            width: 22, height: 22,
            decoration: BoxDecoration(
              color: _style.color.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(
                  color: _style.color.withOpacity(0.3), width: 1),
            ),
            child: Center(
              child: Text('${index + 1}',
                style: TextStyle(
                  color: _style.color,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                )),
            ),
          ),

          const SizedBox(width: 10),

          // Category icon
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: _style.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_style.icon, color: _style.color, size: 18),
          ),

          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(place.nom,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _style.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(_style.label,
                      style: TextStyle(
                          color: _style.color,
                          fontSize: 10,
                          fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.access_time, size: 11, color: Colors.grey.shade600),
                  const SizedBox(width: 2),
                  Text('${place.duree.toStringAsFixed(0)}h',
                    style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 11)),
                ]),
              ],
            ),
          ),

          // Coords
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _CoordChip(label: '${place.latitude.toStringAsFixed(3)}°N'),
              const SizedBox(height: 2),
              _CoordChip(label: '${place.longitude.toStringAsFixed(3)}°E'),
            ],
          ),
        ]),
      ),
    );
  }
}

class _CoordChip extends StatelessWidget {
  final String label;
  const _CoordChip({required this.label});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.04),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(label,
        style: TextStyle(color: Colors.grey.shade700, fontSize: 9,
            fontFamily: 'monospace')),
  );
}

class _PillBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _PillBadge({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.25)),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, color: color, size: 12),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(color: color, fontSize: 11,
          fontWeight: FontWeight.w600)),
    ]),
  );
}

// Helper class for category styling
class _CatStyle {
  final Color color;
  final IconData icon;
  final String label;
  const _CatStyle(this.color, this.icon, this.label);
}
