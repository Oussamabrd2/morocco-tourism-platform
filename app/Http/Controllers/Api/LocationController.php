<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Location;
use Illuminate\Http\Request;

class LocationController extends Controller
{
    public function index(Request $request)
    {
        $query = Location::query();
        // bbox filter
        if ($request->has(['lat_min','lat_max','lng_min','lng_max'])) {
            $query->whereBetween('latitude', [$request->lat_min, $request->lat_max])
                  ->whereBetween('longitude', [$request->lng_min, $request->lng_max]);
        }
        return response()->json($query->paginate(20));
    }

    public function show($id)
    {
        $location = Location::with(['posts','ratings'])->findOrFail($id);
        $avg = $location->ratings()->avg('score');
        return response()->json(['data'=>$location, 'average_rating' => $avg]);
    }
}
