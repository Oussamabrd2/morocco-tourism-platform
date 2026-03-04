<?php
// app/Http/Resources/ActivityResource.php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class ActivityResource extends JsonResource
{
    private ?int $userId;

    public function __construct($resource, ?int $userId = null)
    {
        parent::__construct($resource);
        $this->userId = $userId;
    }

    public function toArray($request): array
    {
        $participantsCount = (int) ($this->participants_count ?? 0);
        $capacity          = $this->capacity;

        // Seats info
        $seatsRemaining = $capacity ? max(0, $capacity - $participantsCount) : null;
        $isFull         = $capacity ? $participantsCount >= $capacity : false;

        // user_joined: check DB only when userId is known
        $userJoined = false;
        if ($this->userId) {
            $userJoined = $this->participants()
                ->where('user_id', $this->userId)
                ->exists();
        }

        return [
            'id'               => $this->id,
            'title'            => $this->title,
            'description'      => $this->description ?? '',
            'capacity'         => $capacity,
            'price'            => $this->price !== null ? (float) $this->price : null,
            'start_at'         => $this->start_at,
            'end_at'           => $this->end_at,
            'participants_count' => $participantsCount,
            'seats_remaining'  => $seatsRemaining,
            'is_full'          => $isFull,
            'user_joined'      => $userJoined,
            'created_at'       => $this->created_at?->toISOString(),

            'location' => $this->whenLoaded('location', fn () => $this->location ? [
                'id'   => $this->location->id,
                'name' => $this->location->name,
            ] : null),

            'organizer' => $this->whenLoaded('organizer', fn () => $this->organizer ? [
                'id'   => $this->organizer->id,
                'name' => $this->organizer->name,
            ] : null),
        ];
    }
}
