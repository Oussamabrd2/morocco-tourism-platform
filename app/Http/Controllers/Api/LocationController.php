<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\LocationResource;
use App\Models\Location;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class LocationController extends Controller
{
    /**
     * List locations. Optional bbox filter. Includes average_rating and reviews_count.
     */
    public function index(Request $request): JsonResponse
    {
        $query = Location::query()
            ->withCount('ratings')
            ->withAvg('ratings as ratings_avg_score', 'score');

        if ($request->has(['lat_min', 'lat_max', 'lng_min', 'lng_max'])) {
            $query->whereBetween('latitude', [$request->lat_min, $request->lat_max])
                ->whereBetween('longitude', [$request->lng_min, $request->lng_max]);
        }

        $locations = $query->orderBy('name')->paginate(20);
        $collection = $locations->getCollection()->map(fn ($loc) => new LocationResource($loc));
        $locations->setCollection($collection);

        return response()->json([
            'data' => $collection->values(),
            'meta' => [
                'current_page' => $locations->currentPage(),
                'last_page' => $locations->lastPage(),
                'per_page' => $locations->perPage(),
                'total' => $locations->total(),
            ],
        ]);
    }

    /**
     * Get single location with average rating and reviews count.
     */
    public function show(int $id): JsonResponse
    {
        $location = Location::withCount('ratings')
            ->withAvg('ratings as ratings_avg_score', 'score')
            ->findOrFail($id);
        return response()->json(['data' => new LocationResource($location)]);
    }
}
