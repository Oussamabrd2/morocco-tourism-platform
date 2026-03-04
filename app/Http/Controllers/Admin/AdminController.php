<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Activity;
use App\Models\Post;
use App\Models\Rating;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\View\View;

class AdminController extends Controller
{
    /**
     * Admin dashboard view (web).
     */
    public function index(): View
    {
        return view('admin.dashboard', [
            'totalUsers' => User::count(),
            'totalPosts' => Post::count(),
            'totalReviews' => Rating::count(),
            'totalActivities' => Activity::count(),
            'users' => User::withCount('posts')->orderBy('created_at', 'desc')->paginate(15),
        ]);
    }

    /**
     * Update user role (API for AJAX or return redirect).
     */
    public function updateUserRole(Request $request, int $id): JsonResponse
    {
        $request->validate(['role' => 'required|in:user,organizer,admin']);

        $user = User::findOrFail($id);
        $user->update(['role' => $request->role]);

        return response()->json(['message' => 'Role updated', 'data' => $user->fresh()]);
    }

    /**
     * Delete post. Admin only.
     */
    public function deletePost(Request $request)
    {
        $request->validate(['id' => 'required|integer|exists:posts,id']);
        $post = Post::findOrFail($request->id);
        $post->delete();
        return $request->expectsJson()
            ? response()->json(['message' => 'Post deleted'])
            : redirect()->route('admin.dashboard')->with('success', 'Post deleted');
    }

    /**
     * Delete activity. Admin only.
     */
    public function deleteActivity(Request $request)
    {
        $request->validate(['id' => 'required|integer|exists:activities,id']);
        $activity = Activity::findOrFail($request->id);
        $activity->participants()->delete();
        $activity->delete();
        return $request->expectsJson()
            ? response()->json(['message' => 'Activity deleted'])
            : redirect()->route('admin.dashboard')->with('success', 'Activity deleted');
    }
}
