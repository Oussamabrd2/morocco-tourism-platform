<?php

use App\Http\Controllers\Admin\AdminController;
use App\Http\Controllers\Auth\WebLoginController;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

Route::get('/login', [WebLoginController::class, 'showLoginForm'])->name('login');
Route::post('/login', [WebLoginController::class, 'login']);
Route::post('/logout', [WebLoginController::class, 'logout'])->name('logout')->middleware('auth');

Route::middleware(['auth', 'admin'])->prefix('admin')->name('admin.')->group(function () {
    Route::get('/', [AdminController::class, 'index'])->name('dashboard');
    Route::post('/users/{id}/role', [AdminController::class, 'updateUserRole'])->name('users.role');
    Route::post('/posts/delete', [AdminController::class, 'deletePost'])->name('posts.delete');
    Route::post('/activities/delete', [AdminController::class, 'deleteActivity'])->name('activities.delete');
});
