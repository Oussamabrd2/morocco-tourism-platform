<?php
// routes/api.php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\UserController;
use App\Http\Controllers\Api\PostController;
use App\Http\Controllers\Api\LocationController;
use App\Http\Controllers\Api\RatingController;
use App\Http\Controllers\Api\ActivityController;

Route::prefix('v1')->group(function () {

    // ── Auth (public) ────────────────────────────────────────────────────────
    Route::post('auth/register', [AuthController::class, 'register']);
    Route::post('auth/login',    [AuthController::class, 'login']);
    Route::post('auth/google',   [AuthController::class, 'googleLogin']);

    // ── Posts (public read) ──────────────────────────────────────────────────
    Route::get('posts',      [PostController::class, 'index']);
    Route::get('posts/{id}', [PostController::class, 'show']);

    // ── Locations (public read) ──────────────────────────────────────────────
    Route::get('locations',              [LocationController::class, 'index']);
    Route::get('locations/{id}',         [LocationController::class, 'show']);
    Route::get('locations/{id}/ratings', [RatingController::class, 'index']);

    // ── Activities (public read) ─────────────────────────────────────────────
    Route::get('activities',      [ActivityController::class, 'index']);
    Route::get('activities/{id}', [ActivityController::class, 'show']);

    // ── Protected (Sanctum token required) ───────────────────────────────────
    Route::middleware('auth:sanctum')->group(function () {

        // Auth
        Route::post('auth/logout', [AuthController::class, 'logout']);

        // User profile
        Route::get('user',             [UserController::class, 'current']);
        Route::put('user',             [UserController::class, 'updateCurrent']);
        Route::post('user/avatar',     [UserController::class, 'uploadAvatar']);  // multipart/form-data
        Route::get('users/{id}',       [UserController::class, 'show']);
        Route::put('users/{id}',       [UserController::class, 'update']);        // admin only

        // Posts
        Route::post('posts',        [PostController::class, 'store']);
        Route::delete('posts/{id}', [PostController::class, 'destroy']);

        // Ratings
        Route::post('locations/{id}/ratings', [RatingController::class, 'store']);

        // Activities
        Route::post('activities',             [ActivityController::class, 'store']);
        Route::post('activities/{id}/join',   [ActivityController::class, 'join']);
        Route::delete('activities/{id}/join', [ActivityController::class, 'cancel']);
    });
});
