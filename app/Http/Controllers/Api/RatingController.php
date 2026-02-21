<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Rating;
use App\Models\Location;
use Illuminate\Http\Request;

class RatingController extends Controller
{
    public function index($locationId)
    {
        $ratings = Rating::where('location_id', $locationId)->with('user')->paginate(20);
        return response()->json($ratings);
    }

    public function store(Request $request, $locationId)
    {
        $data = $request->validate(['score'=>'required|integer|min:1|max:5','review'=>'nullable|string']);
        $location = Location::findOrFail($locationId);
        $rating = Rating::updateOrCreate(
            ['user_id'=>$request->user()->id, 'location_id'=>$location->id],
            ['score'=>$data['score'], 'review'=>$data['review'] ?? null]
        );
        return response()->json(['data'=>$rating]);
    }
}
