<?php
// app/Http/Controllers/Api/ActivityController.php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\ActivityResource;
use App\Models\Activity;
use App\Models\ActivityParticipant;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ActivityController extends Controller
{
    // ── List ─────────────────────────────────────────────────────────────────

    public function index(Request $request): JsonResponse
    {
        $userId = $request->user()?->id;

        $activities = Activity::with(['location', 'organizer'])
            ->withCount('participants')
            ->latest()
            ->paginate(20);

        $collection = $activities->getCollection()
            ->map(fn ($a) => new ActivityResource($a, $userId));

        $activities->setCollection($collection);

        return response()->json([
            'success' => true,
            'data'    => $collection->values(),
            'meta'    => [
                'current_page' => $activities->currentPage(),
                'last_page'    => $activities->lastPage(),
                'per_page'     => $activities->perPage(),
                'total'        => $activities->total(),
            ],
        ]);
    }

    // ── Show ─────────────────────────────────────────────────────────────────

    public function show(Request $request, int $id): JsonResponse
    {
        $userId = $request->user()?->id;

        $activity = Activity::with(['location', 'organizer'])
            ->withCount('participants')
            ->findOrFail($id);

        return response()->json([
            'success' => true,
            'data'    => new ActivityResource($activity, $userId),
        ]);
    }

    // ── Create (organizer / admin only via ActivityPolicy) ───────────────────

    public function store(Request $request): JsonResponse
    {
        $this->authorize('create', Activity::class);

        $data = $request->validate([
            'title'       => 'required|string|max:255',
            'description' => 'nullable|string',
            'location_id' => 'nullable|exists:locations,id',
            'start_at'    => 'nullable|date',
            'end_at'      => 'nullable|date|after_or_equal:start_at',
            'capacity'    => 'nullable|integer|min:1',
            'price'       => 'nullable|numeric|min:0',
        ]);

        $data['organizer_id'] = $request->user()->id;

        $activity = Activity::create($data);
        $activity->load(['location', 'organizer']);
        $activity->loadCount('participants');

        return response()->json([
            'success' => true,
            'message' => 'Activité créée avec succès',
            'data'    => new ActivityResource($activity, $request->user()->id),
        ], 201);
    }

    // ── Join ─────────────────────────────────────────────────────────────────

    public function join(Request $request, int $id): JsonResponse
    {
        $activity = Activity::withCount('participants')->findOrFail($id);

        if ($activity->capacity && $activity->participants_count >= $activity->capacity) {
            return response()->json([
                'success' => false,
                'message' => 'Cette activité est complète',
            ], 422);
        }

        $alreadyJoined = ActivityParticipant::where('activity_id', $id)
            ->where('user_id', $request->user()->id)
            ->exists();

        if ($alreadyJoined) {
            return response()->json([
                'success' => false,
                'message' => 'Vous participez déjà à cette activité',
            ], 422);
        }

        ActivityParticipant::create([
            'activity_id' => $id,
            'user_id'     => $request->user()->id,
            'status'      => 'joined',
        ]);

        $activity->refresh()->load(['location', 'organizer']);
        $activity->loadCount('participants');

        return response()->json([
            'success' => true,
            'message' => 'Vous avez rejoint l\'activité',
            'data'    => new ActivityResource($activity, $request->user()->id),
        ]);
    }

    // ── Cancel (DELETE /activities/{id}/join) ────────────────────────────────

    public function cancel(Request $request, int $id): JsonResponse
    {
        $deleted = ActivityParticipant::where('activity_id', $id)
            ->where('user_id', $request->user()->id)
            ->delete();

        if (! $deleted) {
            return response()->json([
                'success' => false,
                'message' => 'Vous n\'êtes pas inscrit à cette activité',
            ], 404);
        }

        $activity = Activity::with(['location', 'organizer'])
            ->withCount('participants')
            ->findOrFail($id);

        return response()->json([
            'success' => true,
            'message' => 'Participation annulée',
            'data'    => new ActivityResource($activity, $request->user()->id),
        ]);
    }
}
