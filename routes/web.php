<?php
// routes/web.php

use App\Http\Controllers\Admin\AdminController;
use App\Http\Controllers\Auth\WebLoginController;
use Illuminate\Support\Facades\Route;

// ── Auth ──────────────────────────────────────────────────────────────────────
Route::get('/',       fn () => redirect()->route('login'));
Route::get('/login',  [WebLoginController::class, 'showLoginForm'])->name('login');
Route::post('/login', [WebLoginController::class, 'login']);
Route::post('/logout', [WebLoginController::class, 'logout'])
    ->name('logout')->middleware('auth');

// ── Admin ─────────────────────────────────────────────────────────────────────
Route::middleware(['auth', 'admin'])
    ->prefix('admin')
    ->name('admin.')
    ->group(function () {

        // Dashboard
        Route::get('/', [AdminController::class, 'index'])->name('dashboard');

        // Users
        Route::patch('/users/{id}/role',   [AdminController::class, 'updateRole'])->name('users.updateRole');
        Route::patch('/users/{id}/block',  [AdminController::class, 'toggleBlock'])->name('users.block');
        Route::get('/users/export',        [AdminController::class, 'exportUsers'])->name('users.export');

        // Posts
        Route::delete('/posts/{id}',       [AdminController::class, 'deletePost'])->name('posts.delete');

        // Activities
        Route::delete('/activities/{id}',         [AdminController::class, 'deleteActivity'])->name('activities.delete');
        Route::get('/activities/{id}/participants',[AdminController::class, 'activityParticipants'])->name('activities.participants');
        Route::delete('/activities/{activityId}/participants/{userId}',
            [AdminController::class, 'removeParticipant'])->name('activities.participants.remove');

        // Locations
        Route::post('/locations',          [AdminController::class, 'storeLocation'])->name('locations.store');
        Route::patch('/locations/{id}',    [AdminController::class, 'updateLocation'])->name('locations.update');
        Route::delete('/locations/{id}',   [AdminController::class, 'deleteLocation'])->name('locations.delete');
    });
