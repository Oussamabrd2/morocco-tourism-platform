<?php
// app/Http/Controllers/Admin/AdminController.php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Activity;
use App\Models\ActivityParticipant;
use App\Models\Location;
use App\Models\Post;
use App\Models\Rating;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\View\View;

class AdminController extends Controller
{
    // ── Dashboard ─────────────────────────────────────────────────────────────

    public function index(): View
    {
        // Stats cards
        $totalUsers      = User::count();
        $totalPosts      = Post::count();
        $totalReviews    = Rating::count();
        $totalActivities = Activity::count();
        $newUsersWeek    = User::where('created_at', '>=', now()->subDays(7))->count();

        // Chart: new users per month (last 6 months)
        $usersByMonth = User::selectRaw("DATE_FORMAT(created_at, '%Y-%m') as month, COUNT(*) as total")
            ->where('created_at', '>=', now()->subMonths(6))
            ->groupBy('month')
            ->orderBy('month')
            ->pluck('total', 'month');

        // Chart: posts per month (last 6 months)
        $postsByMonth = Post::selectRaw("DATE_FORMAT(created_at, '%Y-%m') as month, COUNT(*) as total")
            ->where('created_at', '>=', now()->subMonths(6))
            ->groupBy('month')
            ->orderBy('month')
            ->pluck('total', 'month');

        // Top location by rating
        $topLocation = Location::withAvg('ratings as avg_rating', 'score')
            ->withCount('ratings')
            ->orderByDesc('avg_rating')
            ->first();

        // Most popular activity
        $topActivity = Activity::withCount('participants')
            ->orderByDesc('participants_count')
            ->first();

        // Users table with search/filter
        $usersQuery = User::withCount('posts')->orderByDesc('created_at');
        if (request('search_user')) {
            $usersQuery->where(function ($q) {
                $q->where('name', 'like', '%' . request('search_user') . '%')
                  ->orWhere('email', 'like', '%' . request('search_user') . '%');
            });
        }
        if (request('filter_role') && request('filter_role') !== 'all') {
            $usersQuery->where('role', request('filter_role'));
        }
        if (request('filter_blocked')) {
            $usersQuery->where('is_blocked', request('filter_blocked') === 'blocked');
        }
        $users = $usersQuery->paginate(15)->withQueryString();

        // Posts with search
        $postsQuery = Post::with(['user', 'images'])->orderByDesc('created_at');
        if (request('search_post')) {
            $postsQuery->where('title', 'like', '%' . request('search_post') . '%');
        }
        $posts = $postsQuery->paginate(10)->withQueryString();

        // Activities with participants count + search
        $activitiesQuery = Activity::with('organizer')->withCount('participants')->orderByDesc('created_at');
        if (request('search_activity')) {
            $activitiesQuery->where('title', 'like', '%' . request('search_activity') . '%');
        }
        $activities = $activitiesQuery->paginate(10)->withQueryString();

        // Locations with rating
        $locationsQuery = Location::withAvg('ratings as avg_rating', 'score')
            ->withCount('ratings')
            ->orderBy('name');
        if (request('search_location')) {
            $locationsQuery->where('name', 'like', '%' . request('search_location') . '%');
        }
        $locations = $locationsQuery->paginate(10)->withQueryString();

        return view('admin.dashboard', compact(
            'totalUsers', 'totalPosts', 'totalReviews', 'totalActivities',
            'newUsersWeek', 'usersByMonth', 'postsByMonth',
            'topLocation', 'topActivity',
            'users', 'posts', 'activities', 'locations'
        ));
    }

    // ── Users ─────────────────────────────────────────────────────────────────

    public function updateRole(Request $request, int $id)
    {
        $request->validate(['role' => 'required|in:user,organizer,admin']);

        $user = User::findOrFail($id);

        if ($user->id === auth()->id()) {
            return back()->withErrors(['role' => 'Vous ne pouvez pas modifier votre propre rôle.']);
        }

        $user->update(['role' => $request->role]);

        return back()->with('success', "Rôle de {$user->name} mis à jour → {$request->role}");
    }

    public function toggleBlock(int $id)
    {
        $user = User::findOrFail($id);

        if ($user->id === auth()->id()) {
            return back()->withErrors(['block' => 'Vous ne pouvez pas bloquer votre propre compte.']);
        }

        $user->update(['is_blocked' => ! $user->is_blocked]);

        $status = $user->is_blocked ? 'bloqué' : 'débloqué';

        return back()->with('success', "Utilisateur {$user->name} {$status}.");
    }

    public function exportUsers()
    {
        $users = User::withCount('posts')->orderByDesc('created_at')->get();

        $csv  = "ID,Nom,Email,Rôle,Posts,Bloqué,Inscrit le\n";
        foreach ($users as $u) {
            $csv .= implode(',', [
                $u->id,
                "\"{$u->name}\"",
                $u->email,
                $u->role,
                $u->posts_count,
                $u->is_blocked ? 'Oui' : 'Non',
                $u->created_at->format('d/m/Y'),
            ]) . "\n";
        }

        return response($csv, 200, [
            'Content-Type'        => 'text/csv; charset=UTF-8',
            'Content-Disposition' => 'attachment; filename="users_' . now()->format('Y-m-d') . '.csv"',
        ]);
    }

    // ── Posts ─────────────────────────────────────────────────────────────────

    public function deletePost(int $id)
    {
        $post = Post::with('images')->findOrFail($id);

        foreach ($post->images as $image) {
            $path = str_replace(asset('storage') . '/', '', $image->url);
            Storage::disk('public')->delete($path);
        }
        $post->images()->delete();
        $post->delete();

        return back()->with('success', 'Post supprimé.');
    }

    // ── Activities ────────────────────────────────────────────────────────────

    public function deleteActivity(int $id)
    {
        $activity = Activity::findOrFail($id);
        $activity->participants()->delete();
        $activity->delete();

        return back()->with('success', 'Activité supprimée.');
    }

    public function activityParticipants(int $id)
    {
        $activity     = Activity::with('organizer')->withCount('participants')->findOrFail($id);
        $participants = ActivityParticipant::where('activity_id', $id)
            ->with('user')
            ->orderByDesc('created_at')
            ->paginate(20);

        return view('admin.participants', compact('activity', 'participants'));
    }

    public function removeParticipant(int $activityId, int $userId)
    {
        ActivityParticipant::where('activity_id', $activityId)
            ->where('user_id', $userId)
            ->delete();

        return back()->with('success', 'Participant retiré.');
    }

    // ── Locations ─────────────────────────────────────────────────────────────

    public function storeLocation(Request $request)
    {
        $data = $request->validate([
            'name'        => 'required|string|max:255',
            'description' => 'nullable|string',
            'latitude'    => 'nullable|numeric|between:-90,90',
            'longitude'   => 'nullable|numeric|between:-180,180',
            'city'        => 'nullable|string|max:100',
            'country'     => 'nullable|string|max:100',
        ]);

        Location::create($data);

        return back()->with('success', 'Lieu ajouté.');
    }

    public function updateLocation(Request $request, int $id)
    {
        $data = $request->validate([
            'name'        => 'required|string|max:255',
            'description' => 'nullable|string',
            'latitude'    => 'nullable|numeric|between:-90,90',
            'longitude'   => 'nullable|numeric|between:-180,180',
            'city'        => 'nullable|string|max:100',
            'country'     => 'nullable|string|max:100',
        ]);

        Location::findOrFail($id)->update($data);

        return back()->with('success', 'Lieu mis à jour.');
    }

    public function deleteLocation(int $id)
    {
        Location::findOrFail($id)->delete();

        return back()->with('success', 'Lieu supprimé.');
    }
}
