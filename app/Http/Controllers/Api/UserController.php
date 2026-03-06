<?php
// app/Http/Controllers/Api/UserController.php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\UserResource;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;

class UserController extends Controller
{
    // ── Get current authenticated user ───────────────────────────────────────

    public function current(Request $request): JsonResponse
    {
        $user = $request->user()->loadCount('posts');
        return response()->json([
            'success' => true,
            'data'    => new UserResource($user),
        ]);
    }

    // ── Get any user by ID (public profile) ──────────────────────────────────

    public function show(int $id): JsonResponse
    {
        $user = User::withCount('posts')->findOrFail($id);
        return response()->json([
            'success' => true,
            'data'    => new UserResource($user),
        ]);
    }

    // ── Update current user profile ───────────────────────────────────────────

    public function updateCurrent(Request $request): JsonResponse
    {
        $user = $request->user();

        $request->validate([
            'name'             => 'sometimes|string|min:3|max:255',
            'email'            => 'sometimes|email|unique:users,email,' . $user->id,
            'bio'              => 'nullable|string|max:500',
            'gender'           => 'nullable|in:Man,Woman,Non-binary,Prefer not to say',
            'avatar_url'       => 'nullable|string|max:500',
            // Password change requires current password
            'password'         => 'sometimes|string|min:8|confirmed',
            'current_password' => 'required_with:password|string',
        ]);

        // FIX: role is never accepted here — users cannot self-promote
        $data = $request->only(['name', 'email', 'bio', 'gender', 'avatar_url']);

        // FIX: password change requires current_password verification
        if ($request->filled('password')) {
            if (! Hash::check($request->current_password, $user->password)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Mot de passe actuel incorrect',
                    'errors'  => ['current_password' => ['Mot de passe actuel incorrect']],
                ], 422);
            }
            $data['password'] = $request->password;
        }

        $user->update($data);

        return response()->json([
            'success' => true,
            'message' => 'Profil mis à jour',
            'data'    => new UserResource($user->fresh()->loadCount('posts')),
        ]);
    }

    // ── Upload avatar ─────────────────────────────────────────────────────────

    public function uploadAvatar(Request $request): JsonResponse
    {
        $request->validate([
            'avatar' => 'required|image|mimes:jpg,jpeg,png,webp|max:2048',
        ]);

        $user = $request->user();

        // Delete old avatar from storage
        if ($user->avatar_url) {
            $old = str_replace(asset('storage') . '/', '', $user->avatar_url);
            Storage::disk('public')->delete($old);
        }

        $path = $request->file('avatar')->store('avatars', 'public');
        $url  = asset('storage/' . $path);

        $user->update(['avatar_url' => $url]);

        return response()->json([
            'success'    => true,
            'message'    => 'Avatar mis à jour',
            'avatar_url' => $url,
            'data'       => new UserResource($user->fresh()),
        ]);
    }

    // ── Admin: update any user ────────────────────────────────────────────────

    public function update(Request $request, int $id): JsonResponse
    {
        $user = User::findOrFail($id);
        $this->authorize('update', $user);

        $request->validate([
            'name'       => 'sometimes|string|min:3|max:255',
            'email'      => 'sometimes|email|unique:users,email,' . $id,
            'bio'        => 'nullable|string|max:500',
            'avatar_url' => 'nullable|string|max:500',
        ]);

        $user->update($request->only(['name', 'email', 'bio', 'avatar_url']));

        return response()->json([
            'success' => true,
            'data'    => new UserResource($user->fresh()),
        ]);
    }
}
