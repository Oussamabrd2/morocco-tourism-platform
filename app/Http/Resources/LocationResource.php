<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class LocationResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $avg = isset($this->ratings_avg_score) ? (float) $this->ratings_avg_score : null;
        $count = isset($this->ratings_count) ? (int) $this->ratings_count : null;
        if ($avg === null) {
            $avg = (float) ($this->ratings()->avg('score') ?? 0);
        }
        if ($count === null) {
            $count = $this->ratings()->count();
        }

        return [
            'id' => $this->id,
            'name' => $this->name,
            'description' => $this->description,
            'latitude' => (float) $this->latitude,
            'longitude' => (float) $this->longitude,
            'address' => $this->address,
            'city' => $this->city,
            'country' => $this->country,
            'image_url' => null,
            'average_rating' => round($avg ?? 0, 1),
            'reviews_count' => $count ?? 0,
        ];
    }
}
