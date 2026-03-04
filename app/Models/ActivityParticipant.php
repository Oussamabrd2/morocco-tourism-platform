<?php
// app/Models/ActivityParticipant.php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ActivityParticipant extends Model
{
    use HasFactory;

    protected $table = 'activity_participants';

    protected $fillable = ['activity_id', 'user_id', 'status'];

    protected $casts = [
        'activity_id' => 'integer',
        'user_id'     => 'integer',
    ];

    // ── Relationships ────────────────────────────────────────────────────────

    public function activity()
    {
        return $this->belongsTo(Activity::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    // ── Scopes ───────────────────────────────────────────────────────────────

    /**
     * Filter by user.
     * Usage: ActivityParticipant::forUser($userId)->get()
     */
    public function scopeForUser($query, int $userId)
    {
        return $query->where('user_id', $userId);
    }

    /**
     * Filter by activity.
     * Usage: ActivityParticipant::forActivity($activityId)->get()
     */
    public function scopeForActivity($query, int $activityId)
    {
        return $query->where('activity_id', $activityId);
    }

    /**
     * Filter joined only.
     */
    public function scopeJoined($query)
    {
        return $query->where('status', 'joined');
    }

    // ── Helpers ──────────────────────────────────────────────────────────────

    /**
     * Check if a specific user has joined a specific activity.
     * Usage: ActivityParticipant::hasJoined($userId, $activityId)
     */
    public static function hasJoined(int $userId, int $activityId): bool
    {
        return static::where('user_id', $userId)
            ->where('activity_id', $activityId)
            ->exists();
    }
}
