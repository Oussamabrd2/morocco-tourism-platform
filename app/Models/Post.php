<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Post extends Model
{
    use HasFactory;

    protected $fillable = ['user_id', 'location_id', 'title', 'body'];

    protected $appends = ['image_url'];

    public function user() {
        return $this->belongsTo(User::class);
    }

    public function location() {
        return $this->belongsTo(Location::class);
    }

    public function images() {
        return $this->hasMany(PostImage::class);
    }

    public function getImageUrlAttribute() {
        $image = $this->images()->first();
        return $image ? $image->url : null;
    }
    public function ratings() {
        return $this->hasMany(Rating::class);
    }
    public function averageRating() {
        return $this->ratings()->avg('rating');
    }
    public function reviews() {
        return $this->hasMany(Rating::class)->whereNotNull('review');
    }
}