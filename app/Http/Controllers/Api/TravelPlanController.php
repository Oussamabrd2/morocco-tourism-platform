<?php
// app/Http/Controllers/Api/TravelPlanController.php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;

class TravelPlanController extends Controller
{
    // Nombre de lieux par jour (min / max)
    private const MIN_PER_DAY = 3;
    private const MAX_PER_DAY = 4;

    // Ordre logique des catégories dans une journée
    private const CATEGORY_ORDER = ['place', 'restaurant', 'activity', 'cafe'];

    public function generate(Request $request): JsonResponse
    {
        // ── Validation ────────────────────────────────────────────────────────
        $request->validate([
            'ville' => 'required|string|min:2|max:100',
            'days'  => 'required|integer|min:1|max:14',
        ]);

        $ville = trim($request->input('ville'));
        $days  = (int) $request->input('days');

        // ── Récupération des lieux ─────────────────────────────────────────────
        $places = DB::table('places')
            ->where('ville', 'LIKE', "%{$ville}%")
            ->select('id', 'nom', 'ville', 'categorie', 'latitude', 'longitude', 'duree')
            ->get();

        if ($places->isEmpty()) {
            return response()->json([
                'success' => false,
                'message' => "Aucun lieu trouvé pour la ville : {$ville}",
            ], 404);
        }

        // ── Génération du plan ─────────────────────────────────────────────────
        $plan = $this->buildPlan($places, $days);

        return response()->json([
            'success' => true,
            'ville'   => $ville,
            'days'    => $days,
            'total_places' => $places->count(),
            'plan'    => $plan,
        ]);
    }

    // ── Logique de génération ──────────────────────────────────────────────────

    private function buildPlan(Collection $places, int $days): array
    {
        // Mélanger aléatoirement
        $shuffled = $places->shuffle();

        // Grouper par catégorie pour assurer de la variété
        $byCategory = $shuffled->groupBy('categorie');

        $plan = [];
        $used = collect(); // IDs déjà utilisés

        for ($day = 1; $day <= $days; $day++) {
            $dayPlaces = $this->pickPlacesForDay($byCategory, $used, $shuffled);
            $used = $used->merge($dayPlaces->pluck('id'));

            $plan["day_{$day}"] = $dayPlaces->map(fn($p) => [
                'id'        => $p->id,
                'nom'       => $p->nom,
                'ville'     => $p->ville,
                'categorie' => $p->categorie,
                'latitude'  => (float) $p->latitude,
                'longitude' => (float) $p->longitude,
                'duree'     => (float) ($p->duree ?? 1),
            ])->values()->toArray();
        }

        return $plan;
    }

    private function pickPlacesForDay(
        Collection $byCategory,
        Collection $used,
        Collection $all
    ): Collection {
        $count    = rand(self::MIN_PER_DAY, self::MAX_PER_DAY);
        $selected = collect();

        // 1. Essayer de prendre un lieu de chaque catégorie (variété)
        foreach (self::CATEGORY_ORDER as $cat) {
            if ($selected->count() >= $count) break;

            $available = ($byCategory->get($cat) ?? collect())
                ->whereNotIn('id', $used->merge($selected->pluck('id'))->toArray());

            if ($available->isNotEmpty()) {
                $selected->push($available->first());
            }
        }

        // 2. Compléter avec n'importe quel lieu restant si pas assez
        if ($selected->count() < $count) {
            $remaining = $all->whereNotIn(
                'id',
                $used->merge($selected->pluck('id'))->toArray()
            )->shuffle()->take($count - $selected->count());

            $selected = $selected->merge($remaining);
        }

        // 3. Si toujours pas assez (ville avec peu de lieux) → recycler
        if ($selected->count() < self::MIN_PER_DAY) {
            $recycled = $all->shuffle()->take($count - $selected->count());
            $selected = $selected->merge($recycled);
        }

        // Trier par catégorie pour un ordre logique dans la journée
        return $selected->sortBy(fn($p) => array_search(
            $p->categorie,
            self::CATEGORY_ORDER
        ) ?? 99);
    }
}
