<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Activity;
use App\Models\ActivityParticipant;
use Illuminate\Http\Request;

class ActivityController extends Controller
{
    public function index(Request $request)
    {
        $activities = Activity::with('location','organizer')->paginate(20);
        return response()->json($activities);
    }

    public function show($id)
    {
        $activity = Activity::with('participants.user','location','organizer')->findOrFail($id);
        return response()->json(['data'=>$activity]);
    }

    public function store(Request $request)
    {
        $this->authorize('create', Activity::class);
        $data = $request->validate(['title'=>'required|string','description'=>'nullable|string','location_id'=>'nullable|exists:locations,id','start_at'=>'nullable|date','end_at'=>'nullable|date','capacity'=>'nullable|integer','price'=>'nullable|numeric']);
        $data['organizer_id'] = $request->user()->id;
        $activity = Activity::create($data);
        return response()->json(['data'=>$activity],201);
    }

    public function join(Request $request, $id)
    {
        $activity = Activity::findOrFail($id);
        if ($activity->capacity && $activity->participants()->count() >= $activity->capacity) {
            return response()->json(['message'=>'Activity is full'], 422);
        }
        $participant = ActivityParticipant::firstOrCreate(['activity_id'=>$id,'user_id'=>$request->user()->id], ['status'=>'joined']);
        return response()->json(['data'=>$participant]);
    }

    public function cancel(Request $request, $id)
    {
        $participant = ActivityParticipant::where('activity_id',$id)->where('user_id',$request->user()->id)->first();
        if ($participant) {
            $participant->delete();
        }
        return response()->json(['message'=>'Cancelled']);
    }
}
