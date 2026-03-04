<?php
// app/Models/Activity.php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Activity extends Model
{
    use HasFactory;

    protected $fillable = [
        'title',
        'description',
        'location_id',
        'organizer_id',
        'start_at',
        'end_at',
        'capacity',
        'price',
    ];

    protected $casts = [
        'start_at' => 'datetime',
        'end_at'   => 'datetime',
        'price'    => 'decimal:2',
        'capacity' => 'integer',
    ];

    public function location()
    {
        return $this->belongsTo(Location::class);
    }

    public function organizer()
    {
        return $this->belongsTo(User::class, 'organizer_id');
    }

    public function participants()
    {
        return $this->hasMany(ActivityParticipant::class);
    }

    // Convenience: check if a specific user has joined
    public function isJoinedBy(int $userId): bool
    {
        return $this->participants()->where('user_id', $userId)->exists();
    }

    // Check if activity is full
    public function isFull(): bool
    {
        if (! $this->capacity) return false;
        return $this->participants()->count() >= $this->capacity;
    }
}
