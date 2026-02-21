<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Activity extends Model
{
    use HasFactory;

    protected $fillable = ['title','description','location_id','organizer_id','start_at','end_at','capacity','price'];

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
}
