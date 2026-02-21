<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;

class UserController extends Controller
{
    /**
     * Get the current authenticated user
     */
    public function current(Request $request)
    {
        return response()->json(['data' => $request->user()]);
    }

    /**
     * Get a specific user by ID
     */
    public function show($id)
    {
        $user = User::with('posts')->findOrFail($id);
        return response()->json(['data' => $user]);
    }

    /**
     * Update current authenticated user
     */
    public function updateCurrent(Request $request)
    {
        $user = $request->user();
        $data = $request->only(['name', 'email', 'avatar_url', 'bio']);
        $user->update($data);
        return response()->json(['data' => $user]);
    }

    /**
     * Update a specific user (needs authorization)
     */
    public function update(Request $request, $id)
    {
        $user = User::findOrFail($id);
        $this->authorize('update', $user);
        $data = $request->only(['name', 'email', 'avatar_url', 'bio']);
        $user->update($data);
        return response()->json(['data' => $user]);
    }
}
