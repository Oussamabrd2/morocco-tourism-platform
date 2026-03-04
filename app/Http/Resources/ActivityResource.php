<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ActivityResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'title' => $this->title,
            'description' => $this->description ?? '',
            'location_id' => $this->location_id,
            'location' => $this->whenLoaded('location', fn () => [
                'id' => $this->location?->id,
                'name' => $this->location?->name,
                'city' => $this->location?->city,
            ]),
            'organizer' => $this->whenLoaded('organizer', fn () => [
                'id' => $this->organizer?->id,
                'name' => $this->organizer?->name,
            ]),
            'start_at' => $this->start_at?->toIso8601String(),
            'end_at' => $this->end_at?->toIso8601String(),
            'capacity' => $this->capacity ?? 0,
            'price' => $this->price ? (float) $this->price : null,
            'participants_count' => $this->when(
                isset($this->participants_count),
                fn () => $this->participants_count,
                fn () => $this->participants()->count()
            ),
            'user_joined' => $this->when(
                auth()->check(),
                fn () => $this->participants()->where('user_id', auth()->id())->exists()
            ),
        ];
    }
}
