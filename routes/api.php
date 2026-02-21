<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\UserController;
use App\Http\Controllers\Api\PostController;
use App\Http\Controllers\Api\LocationController;
use App\Http\Controllers\Api\RatingController;
use App\Http\Controllers\Api\ActivityController;

Route::prefix('v1')->group(function () {

    // Auth
    Route::post('auth/register', [AuthController::class, 'register']);
    Route::post('auth/login', [AuthController::class, 'login']);

    // Public Posts
    Route::get('posts', [PostController::class, 'index']);
    Route::get('posts/{id}', [PostController::class, 'show']);

    // Public Locations
    Route::get('locations', [LocationController::class, 'index']);
    Route::get('locations/{id}', [LocationController::class, 'show']);
    Route::get('locations/{id}/ratings', [RatingController::class, 'index']);

    // Public Activities
    Route::get('activities', [ActivityController::class, 'index']);
    Route::get('activities/{id}', [ActivityController::class, 'show']);

    Route::middleware('auth:sanctum')->group(function () {

        Route::post('auth/logout', [AuthController::class, 'logout']);

        // User
        Route::get('user', [UserController::class, 'current']);
        Route::get('users/{id}', [UserController::class, 'show']);
        Route::put('users/{id}', [UserController::class, 'update']);
        Route::put('user', [UserController::class, 'updateCurrent']);

        // Posts (Protected)
        Route::post('posts', [PostController::class, 'store']);
        Route::delete('posts/{id}', [PostController::class, 'destroy']);

        // Ratings
        Route::post('locations/{id}/ratings', [RatingController::class, 'store']);

        // Activities
        Route::post('activities', [ActivityController::class, 'store']);
        Route::post('activities/{id}/join', [ActivityController::class, 'join']);
        Route::post('activities/{id}/cancel', [ActivityController::class, 'cancel']);
    });
});
