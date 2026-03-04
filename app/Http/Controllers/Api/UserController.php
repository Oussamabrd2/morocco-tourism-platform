<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\UserResource;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class UserController extends Controller
{
    public function current(Request $request): JsonResponse
    {
        $user = $request->user()->loadCount('posts');
        return response()->json(['data' => new UserResource($user)]);
    }

    public function show(int $id): JsonResponse
    {
        $user = User::withCount('posts')->findOrFail($id);
        return response()->json(['data' => new UserResource($user)]);
    }

    public function updateCurrent(Request $request): JsonResponse
    {
        $request->validate([
            'name' => 'sometimes|string|max:255',
            'email' => 'sometimes|email|unique:users,email,' . $request->user()->id,
            'avatar_url' => 'nullable|string|url',
            'bio' => 'nullable|string|max:500',
        ]);

        $user = $request->user();
        $user->update($request->only(['name', 'email', 'avatar_url', 'bio']));

        return response()->json(['data' => new UserResource($user->fresh())]);
    }

    public function update(Request $request, int $id): JsonResponse
    {
        $user = User::findOrFail($id);
        $this->authorize('update', $user);

        $request->validate([
            'name' => 'sometimes|string|max:255',
            'email' => 'sometimes|email|unique:users,email,' . $id,
            'avatar_url' => 'nullable|string|url',
            'bio' => 'nullable|string|max:500',
        ]);

        $user->update($request->only(['name', 'email', 'avatar_url', 'bio']));

        return response()->json(['data' => new UserResource($user->fresh())]);
    }
}
