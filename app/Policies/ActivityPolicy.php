<?php

namespace App\Policies;

use App\Models\Activity;
use App\Models\User;

class ActivityPolicy
{
    public function create(User $user)
    {
        return $user->isOrganizer();
    }

    public function update(User $user, Activity $activity)
    {
        return $user->id === $activity->organizer_id;
    }

    public function delete(User $user, Activity $activity)
    {
        return $user->id === $activity->organizer_id || $user->isAdmin();
    }

    public function join(User $user, Activity $activity)
    {
        // any authenticated user can join (controller checks capacity)
        return $user !== null;
    }
}
