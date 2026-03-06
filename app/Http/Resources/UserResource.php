<?php
// app/Http/Resources/UserResource.php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class UserResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id'          => $this->id,
            'name'        => $this->name,
            'email'       => $this->email,
            'avatar_url'  => $this->avatar_url,
            'bio'         => $this->bio,
            'gender'      => $this->gender,
            'birth_date'  => $this->birth_date?->format('Y-m-d'),  // "1999-05-12"
            'age'         => $this->birth_date?->age,              // 25
            'role'        => $this->role ?? 'user',
            'is_blocked'  => (bool) ($this->is_blocked ?? false),
            'posts_count' => (int) ($this->posts_count ?? 0),
            'created_at'  => $this->created_at?->toISOString(),
        ];
    }
}
