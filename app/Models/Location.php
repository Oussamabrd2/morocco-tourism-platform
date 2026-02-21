<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Location extends Model
{
    use HasFactory;

    protected $fillable = ['name','description','latitude','longitude','address','city','country','category_id'];

    public function posts()
    {
        return $this->hasMany(Post::class);
    }

    public function ratings()
    {
        return $this->hasMany(Rating::class);
    }

    public function activities()
    {
        return $this->hasMany(Activity::class);
    }
}
