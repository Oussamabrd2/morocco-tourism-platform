<?php
// app/Models/User.php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $fillable = [
        'name', 'email', 'password',
        'avatar_url', 'bio', 'role',
        'gender', 'google_uid', 'is_blocked',
    ];

    protected $hidden = [
        'password', 'remember_token', 'google_uid',
    ];

    protected $casts = [
        'email_verified_at' => 'datetime',
        'password'          => 'hashed',
        'is_blocked'        => 'boolean',
    ];

    public function posts()
    {
        return $this->hasMany(Post::class);
    }

    public function organizedActivities()
    {
        return $this->hasMany(Activity::class, 'organizer_id');
    }

    public function ratings()
    {
        return $this->hasMany(Rating::class);
    }

    public function activityParticipations()
    {
        return $this->hasMany(ActivityParticipant::class);
    }

    public function isAdmin(): bool     { return $this->role === 'admin'; }
    public function isOrganizer(): bool { return in_array($this->role, ['organizer', 'admin']); }
    public function isBlocked(): bool   { return (bool) $this->is_blocked; }
}
