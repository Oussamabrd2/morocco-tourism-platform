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
        'name',
        'email',
        'password',
        'google_uid',
        'avatar_url',
        'bio',
        'gender',       // ← Man | Woman | Non-binary | Prefer not to say
        'birth_date',   // ← date de naissance
        'role',
        'is_blocked',
    ];

    protected $hidden = [
        'password',
        'remember_token',
        'google_uid',
    ];

    protected $casts = [
        'email_verified_at' => 'datetime',
        'password'          => 'hashed',
        'birth_date'        => 'date',       // ← cast en Carbon date
        'is_blocked'        => 'boolean',
    ];

    // ── Relations ────────────────────────────────────────────────────────────

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

    // ── Helpers ───────────────────────────────────────────────────────────────

    public function isAdmin(): bool     { return $this->role === 'admin'; }
    public function isOrganizer(): bool { return in_array($this->role, ['organizer', 'admin']); }
    public function isBlocked(): bool   { return (bool) $this->is_blocked; }

    // Calcul de l'âge depuis birth_date
    public function getAgeAttribute(): ?int
    {
        return $this->birth_date?->age;
    }
}
