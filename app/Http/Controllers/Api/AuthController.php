<?php
// app/Http/Controllers/Api/AuthController.php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\LoginRequest;
use App\Http\Requests\RegisterRequest;
use App\Http\Resources\UserResource;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    // ── Register ──────────────────────────────────────────────────────────────

    public function register(RegisterRequest $request): JsonResponse
    {
        $data = $request->validated();

        $user = User::create([
            'name'       => $data['name'],
            'email'      => $data['email'],
            'password'   => Hash::make($data['password']),
            'gender'     => $data['gender']     ?? null,  // ← saved
            'birth_date' => $data['birth_date'] ?? null,  // ← saved
            'role'       => 'user',                       // never from client
        ]);

        $token = $user->createToken('api-token')->plainTextToken;

        // FIX: resolve() avoids double 'data' wrapping from JsonResource
        return response()->json([
            'success' => true,
            'data' => [
                'token' => $token,
                'user'  => (new UserResource($user))->resolve(),
            ],
        ], 201);
    }

    // ── Login ─────────────────────────────────────────────────────────────────

    public function login(LoginRequest $request): JsonResponse
    {
        $creds = $request->validated();
        $user  = User::where('email', $creds['email'])->first();

        if (! $user || ! Hash::check($creds['password'], $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Email ou mot de passe incorrect',
            ], 401);
        }

        if ($user->is_blocked) {
            return response()->json([
                'success' => false,
                'message' => 'Votre compte a été suspendu. Contactez le support.',
            ], 403);
        }

        $user->tokens()->delete();
        $token = $user->createToken('api-token')->plainTextToken;

        return response()->json([
            'success' => true,
            'data' => [
                'token' => $token,
                'user'  => (new UserResource($user->loadCount('posts')))->resolve(),
            ],
        ], 200);
    }

    // ── Logout ────────────────────────────────────────────────────────────────

    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'success' => true,
            'message' => 'Déconnecté avec succès',
        ], 200);
    }

    // ── Google OAuth ──────────────────────────────────────────────────────────

    public function googleLogin(Request $request): JsonResponse
    {
        $request->validate([
            'google_uid' => 'required|string',
            'name'       => 'required|string',
            'email'      => 'required|email',
        ]);

        $user = User::firstOrCreate(
            ['email' => $request->email],
            [
                'name'       => $request->name,
                'google_uid' => $request->google_uid,
                'password'   => Hash::make(str()->random(32)),
                'role'       => 'user',
            ]
        );

        if (! $user->google_uid) {
            $user->update(['google_uid' => $request->google_uid]);
        }

        if ($user->is_blocked) {
            return response()->json([
                'success' => false,
                'message' => 'Votre compte a été suspendu.',
            ], 403);
        }

        $user->tokens()->delete();
        $token = $user->createToken('google-token')->plainTextToken;

        return response()->json([
            'success' => true,
            'data' => [
                'token' => $token,
                'user'  => (new UserResource($user))->resolve(),
            ],
        ], 200);
    }
}
