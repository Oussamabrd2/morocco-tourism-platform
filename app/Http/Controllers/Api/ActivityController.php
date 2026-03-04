<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\ActivityResource;
use App\Models\Activity;
use App\Models\ActivityParticipant;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ActivityController extends Controller
{
    /**
     * List activities. Role policy: only organizer/admin can create.
     */
    public function index(Request $request): JsonResponse
    {
        $activities = Activity::with(['location', 'organizer'])
            ->withCount('participants')
            ->latest()
            ->paginate(20);

        $collection = $activities->getCollection()->map(fn ($a) => new ActivityResource($a));
        $activities->setCollection($collection);

        return response()->json([
            'data' => $collection->values(),
            'meta' => [
                'current_page' => $activities->currentPage(),
                'last_page' => $activities->lastPage(),
                'per_page' => $activities->perPage(),
                'total' => $activities->total(),
            ],
        ]);
    }

    public function show(int $id): JsonResponse
    {
        $activity = Activity::with(['location', 'organizer', 'participants.user'])->findOrFail($id);
        return response()->json(['data' => new ActivityResource($activity)]);
    }

    public function store(Request $request): JsonResponse
    {
        $this->authorize('create', Activity::class);

        $data = $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'nullable|string',
            'location_id' => 'nullable|exists:locations,id',
            'start_at' => 'nullable|date',
            'end_at' => 'nullable|date|after_or_equal:start_at',
            'capacity' => 'nullable|integer|min:1',
            'price' => 'nullable|numeric|min:0',
        ]);

        $data['organizer_id'] = $request->user()->id;
        $activity = Activity::create($data);
        $activity->load(['location', 'organizer']);

        return response()->json(['data' => new ActivityResource($activity)], 201);
    }

    public function join(Request $request, int $id): JsonResponse
    {
        $activity = Activity::findOrFail($id);

        if ($activity->capacity && $activity->participants()->count() >= $activity->capacity) {
            return response()->json(['message' => 'Activity is full'], 422);
        }

        $participant = ActivityParticipant::firstOrCreate(
            ['activity_id' => $id, 'user_id' => $request->user()->id],
            ['status' => 'joined']
        );

        return response()->json(['message' => 'Joined', 'data' => $participant]);
    }

    public function cancel(Request $request, int $id): JsonResponse
    {
        ActivityParticipant::where('activity_id', $id)
            ->where('user_id', $request->user()->id)
            ->delete();

        return response()->json(['message' => 'Cancelled']);
    }
}
