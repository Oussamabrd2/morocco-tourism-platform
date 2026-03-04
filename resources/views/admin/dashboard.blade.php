{{-- resources/views/admin/dashboard.blade.php --}}
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ziarat Admin — Dashboard</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
    <style>
        :root { --orange: #fd7e14; --bg: #000; --card: #111; --border: #222; }
        * { box-sizing: border-box; }
        body { background: var(--bg); color: #fff; font-family: 'Segoe UI', sans-serif; margin: 0; }

        /* Nav */
        .navbar-admin { background: #0a0a0a; border-bottom: 1px solid var(--border);
            padding: .85rem 1.5rem; display: flex; justify-content: space-between; align-items: center; position: sticky; top:0; z-index:999; }
        .brand { font-size: 1.4rem; font-weight: 900; color: var(--orange); letter-spacing: -1px; }
        .brand small { color: #fff; font-weight: 300; font-size: .9rem; }

        /* Tabs */
        .tab-nav { background: #0a0a0a; border-bottom: 1px solid var(--border);
            display: flex; gap: 0; overflow-x: auto; padding: 0 1.5rem; }
        .tab-btn { padding: .75rem 1.25rem; background: none; border: none; color: #888;
            cursor: pointer; font-size: .85rem; font-weight: 600; text-transform: uppercase;
            letter-spacing: .5px; border-bottom: 2px solid transparent; white-space: nowrap; transition: all .2s; }
        .tab-btn.active, .tab-btn:hover { color: var(--orange); border-bottom-color: var(--orange); }

        /* Cards */
        .card  { background: var(--card); border: 1px solid var(--border); border-radius: 14px; }
        .stat-card { padding: 1.2rem 1.4rem; }
        .stat-card .label { font-size: .72rem; font-weight: 700; text-transform: uppercase;
            letter-spacing: .8px; color: #666; margin-bottom: .3rem; }
        .stat-card .value { font-size: 2rem; font-weight: 900; line-height: 1; }
        .stat-card .sub   { font-size: .72rem; color: #555; margin-top: .3rem; }

        /* Table */
        .table { --bs-table-bg: transparent; --bs-table-color: #ddd; border-color: #1e1e1e; font-size: .85rem; }
        .table thead th { background: #0d0d0d; color: #666; font-size: .72rem; text-transform: uppercase;
            letter-spacing: .6px; border-color: #1e1e1e; padding: .85rem 1rem; font-weight: 700; }
        .table tbody td { border-color: #1a1a1a; padding: .75rem 1rem; vertical-align: middle; }
        .table-hover tbody tr:hover td { background: #161616; }

        /* Badges */
        .role-badge { font-size: .7rem; font-weight: 700; padding: .25rem .65rem;
            border-radius: 20px; text-transform: uppercase; letter-spacing: .4px; }
        .role-admin     { background: rgba(253,126,20,.15); color: var(--orange); border: 1px solid rgba(253,126,20,.3); }
        .role-organizer { background: rgba(13,202,240,.1);  color: #0dcaf0;       border: 1px solid rgba(13,202,240,.25); }
        .role-user      { background: rgba(255,255,255,.05); color: #888;         border: 1px solid #2a2a2a; }
        .badge-blocked  { background: rgba(220,53,69,.15);  color: #dc3545;       border: 1px solid rgba(220,53,69,.3);
            font-size: .7rem; font-weight: 700; padding: .25rem .65rem; border-radius: 20px; }

        /* Search bar */
        .search-bar { background: #0d0d0d; border: 1px solid #2a2a2a; color: #fff;
            border-radius: 10px; padding: .5rem .9rem; font-size: .85rem; width: 100%; }
        .search-bar:focus { outline: none; border-color: var(--orange); }
        .search-bar::placeholder { color: #444; }
        select.search-bar { cursor: pointer; }

        /* Section title */
        .section-title { font-size: .8rem; font-weight: 800; text-transform: uppercase;
            letter-spacing: .8px; color: #555; margin-bottom: 1rem; padding-bottom: .5rem;
            border-bottom: 1px solid #1a1a1a; }
        .section-title span { color: var(--orange); }

        /* Flash */
        .flash { position: fixed; top: 1rem; right: 1rem; z-index: 9999; min-width: 280px; font-size: .85rem; }

        /* Tab content */
        .tab-pane { display: none; padding: 1.5rem; }
        .tab-pane.active { display: block; }

        /* Chart container */
        .chart-wrap { position: relative; height: 220px; }

        /* Pagination override */
        .pagination { --bs-pagination-bg: #111; --bs-pagination-border-color: #222;
            --bs-pagination-color: #888; --bs-pagination-hover-bg: #1a1a1a;
            --bs-pagination-hover-color: var(--orange); --bs-pagination-active-bg: var(--orange);
            --bs-pagination-active-border-color: var(--orange); font-size: .8rem; }

        /* Post thumbnail */
        .post-thumb { width: 52px; height: 52px; border-radius: 8px; overflow: hidden;
            background: #1a1a1a; flex-shrink: 0; display:flex; align-items:center; justify-content:center; }
        .post-thumb img { width:100%; height:100%; object-fit:cover; }

        /* Location form */
        .form-control-dark { background: #0d0d0d; border: 1px solid #2a2a2a; color: #fff;
            border-radius: 8px; font-size: .85rem; }
        .form-control-dark:focus { background: #0d0d0d; border-color: var(--orange);
            color: #fff; box-shadow: 0 0 0 2px rgba(253,126,20,.15); }

        /* Scrollbar */
        ::-webkit-scrollbar { width: 4px; height: 4px; }
        ::-webkit-scrollbar-track { background: #0a0a0a; }
        ::-webkit-scrollbar-thumb { background: #333; border-radius: 4px; }
    </style>
</head>
<body>

{{-- ── Flash ──────────────────────────────────────────────────────────────── --}}
@if(session('success'))
<div class="flash alert alert-success alert-dismissible fade show shadow-lg py-2" role="alert">
    <i class="fa-solid fa-circle-check me-2"></i>{{ session('success') }}
    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="alert"></button>
</div>
@endif
@if($errors->any())
<div class="flash alert alert-danger alert-dismissible fade show shadow-lg py-2" role="alert">
    <i class="fa-solid fa-circle-exclamation me-2"></i>{{ $errors->first() }}
    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="alert"></button>
</div>
@endif

{{-- ── Navbar ──────────────────────────────────────────────────────────────── --}}
<nav class="navbar-admin">
    <div class="brand">ZIARAT <small>ADMIN</small></div>
    <div class="d-flex align-items-center gap-3">
        <span style="font-size:.8rem;color:#555">
            <i class="fa-solid fa-circle-dot text-success me-1" style="font-size:.55rem"></i>
            {{ auth()->user()->name }}
        </span>
        <form action="{{ route('logout') }}" method="POST" class="m-0">
            @csrf
            <button class="btn btn-sm btn-outline-secondary" style="font-size:.75rem">
                <i class="fa-solid fa-right-from-bracket me-1"></i>Déconnexion
            </button>
        </form>
    </div>
</nav>

{{-- ── Tab Navigation ───────────────────────────────────────────────────────── --}}
<div class="tab-nav">
    <button class="tab-btn active" onclick="showTab('overview')">
        <i class="fa-solid fa-chart-pie me-1"></i>Vue d'ensemble
    </button>
    <button class="tab-btn" onclick="showTab('users')">
        <i class="fa-solid fa-users me-1"></i>Utilisateurs
        <span class="badge rounded-pill ms-1" style="background:var(--orange);font-size:.65rem"></span>
    </button>
    <button class="tab-btn" onclick="showTab('posts')">
        <i class="fa-solid fa-camera me-1"></i>Posts
    </button>
    <button class="tab-btn" onclick="showTab('activities')">
        <i class="fa-solid fa-person-hiking me-1"></i>Activités
    </button>
    <button class="tab-btn" onclick="showTab('locations')">
        <i class="fa-solid fa-map-location-dot me-1"></i>Lieux
    </button>
</div>

{{-- ════════════════════════════════════════════════════════════════════════════
     TAB 1 — OVERVIEW
════════════════════════════════════════════════════════════════════════════ --}}
<div id="tab-overview" class="tab-pane active">

    {{-- Stats row --}}
    <div class="row g-3 mb-4">
        @foreach([
            ['Utilisateurs',   $totalUsers,      'fa-users',         'var(--orange)', "+" . $newUsersWeek . " cette semaine"],
            ['Posts',          $totalPosts,       'fa-camera',        '#fff',          ''],
            ['Activités',      $totalActivities,  'fa-person-hiking', '#fff',          ''],
            ['Avis / Ratings', $totalReviews,     'fa-star',          '#ffc107',       ''],
        ] as [$label, $value, $icon, $color, $sub])
        <div class="col-6 col-lg-3">
            <div class="card stat-card">
                <div class="d-flex justify-content-between align-items-start">
                    <div>
                        <div class="label">{{ $label }}</div>
                        <div class="value" style="color:{{ $color }}">{{ number_format($value) }}</div>
                        @if($sub)<div class="sub text-success"><i class="fa-solid fa-arrow-up" style="font-size:.6rem"></i> {{ $sub }}</div>@endif
                    </div>
                    <i class="fa-solid {{ $icon }} fa-lg mt-1" style="color:{{ $color }};opacity:.2"></i>
                </div>
            </div>
        </div>
        @endforeach
    </div>

    {{-- Charts --}}
    <div class="row g-3 mb-4">
        <div class="col-md-6">
            <div class="card p-3">
                <div class="section-title"><span>Nouveaux</span> utilisateurs (6 mois)</div>
                <div class="chart-wrap"><canvas id="chartUsers"></canvas></div>
            </div>
        </div>
        <div class="col-md-6">
            <div class="card p-3">
                <div class="section-title"><span>Nouveaux</span> posts (6 mois)</div>
                <div class="chart-wrap"><canvas id="chartPosts"></canvas></div>
            </div>
        </div>
    </div>

    {{-- Top cards --}}
    <div class="row g-3">
        @if($topLocation)
        <div class="col-md-6">
            <div class="card p-3">
                <div class="section-title"><i class="fa-solid fa-trophy me-1" style="color:var(--orange)"></i><span>Lieu</span> le mieux noté</div>
                <div class="d-flex align-items-center gap-3">
                    <div style="width:44px;height:44px;background:#1a1a1a;border-radius:10px;display:flex;align-items:center;justify-content:center">
                        <i class="fa-solid fa-location-dot" style="color:var(--orange)"></i>
                    </div>
                    <div>
                        <div class="fw-bold">{{ $topLocation->name }}</div>
                        <div style="font-size:.75rem;color:#666">
                            <i class="fa-solid fa-star text-warning me-1" style="font-size:.65rem"></i>
                            {{ number_format($topLocation->avg_rating, 1) }} / 5
                            — {{ $topLocation->ratings_count }} avis
                        </div>
                    </div>
                </div>
            </div>
        </div>
        @endif
        @if($topActivity)
        <div class="col-md-6">
            <div class="card p-3">
                <div class="section-title"><i class="fa-solid fa-fire me-1" style="color:var(--orange)"></i><span>Activité</span> la plus populaire</div>
                <div class="d-flex align-items-center gap-3">
                    <div style="width:44px;height:44px;background:#1a1a1a;border-radius:10px;display:flex;align-items:center;justify-content:center">
                        <i class="fa-solid fa-person-hiking" style="color:var(--orange)"></i>
                    </div>
                    <div>
                        <div class="fw-bold">{{ Str::limit($topActivity->title, 35) }}</div>
                        <div style="font-size:.75rem;color:#666">
                            <i class="fa-solid fa-users me-1" style="font-size:.65rem"></i>
                            {{ $topActivity->participants_count }} participants
                        </div>
                    </div>
                </div>
            </div>
        </div>
        @endif
    </div>
</div>

{{-- ════════════════════════════════════════════════════════════════════════════
     TAB 2 — USERS
════════════════════════════════════════════════════════════════════════════ --}}
<div id="tab-users" class="tab-pane">

    {{-- Search / filter / export --}}
    <form method="GET" action="{{ route('admin.dashboard') }}#users" class="row g-2 mb-3" id="form-users">
        <input type="hidden" name="_tab" value="users">
        <div class="col-md-4">
            <input type="text" name="search_user" class="search-bar"
                placeholder=" Rechercher nom ou email..."
                value="{{ request('search_user') }}">
        </div>
        <div class="col-auto">
            <select name="filter_role" class="search-bar" onchange="this.form.submit()">
                <option value="all">Tous les rôles</option>
                <option value="user"      {{ request('filter_role') == 'user'      ? 'selected':'' }}>User</option>
                <option value="organizer" {{ request('filter_role') == 'organizer' ? 'selected':'' }}>Organizer</option>
                <option value="admin"     {{ request('filter_role') == 'admin'     ? 'selected':'' }}>Admin</option>
            </select>
        </div>
        <div class="col-auto">
            <select name="filter_blocked" class="search-bar" onchange="this.form.submit()">
                <option value="">Tous</option>
                <option value="active"  {{ request('filter_blocked') == 'active'  ? 'selected':'' }}>Actifs</option>
                <option value="blocked" {{ request('filter_blocked') == 'blocked' ? 'selected':'' }}>Bloqués</option>
            </select>
        </div>
        <div class="col-auto">
            <button type="submit" class="btn btn-sm" style="background:var(--orange);color:#000;font-weight:700;border-radius:8px">
                Filtrer
            </button>
        </div>
        <div class="col-auto ms-auto">
            <a href="{{ route('admin.users.export') }}" class="btn btn-sm btn-outline-secondary" style="font-size:.8rem">
                <i class="fa-solid fa-file-csv me-1"></i>Export CSV
            </a>
        </div>
    </form>

    <div class="card overflow-hidden">
        <div class="table-responsive">
            <table class="table table-hover m-0">
                <thead>
                    <tr>
                        <th>Utilisateur</th>
                        <th>Email</th>
                        <th>Rôle</th>
                        <th class="text-center">Posts</th>
                        <th class="text-center">Statut</th>
                        <th class="text-center">Inscrit</th>
                        <th class="text-center">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse($users as $user)
                    <tr>
                        <td>
                            <div class="d-flex align-items-center gap-2">
                                <div style="width:32px;height:32px;border-radius:50%;background:{{ $user->isAdmin() ? 'rgba(253,126,20,.2)' : '#1a1a1a' }};display:flex;align-items:center;justify-content:center;font-size:.8rem;font-weight:700;color:var(--orange);flex-shrink:0">
                                    {{ strtoupper(substr($user->name, 0, 1)) }}
                                </div>
                                <span class="fw-bold" style="font-size:.85rem">{{ $user->name }}</span>
                            </div>
                        </td>
                        <td style="color:#666;font-size:.8rem">{{ $user->email }}</td>
                        <td>
                            <form action="{{ route('admin.users.updateRole', $user->id) }}" method="POST">
                                @csrf @method('PATCH')
                                <select name="role" onchange="this.form.submit()"
                                    class="search-bar" style="padding:.3rem .6rem;width:auto"
                                    {{ $user->id === auth()->id() ? 'disabled' : '' }}>
                                    <option value="user"      {{ $user->role === 'user'      ? 'selected':'' }}>User</option>
                                    <option value="organizer" {{ $user->role === 'organizer' ? 'selected':'' }}>Organizer</option>
                                    <option value="admin"     {{ $user->role === 'admin'     ? 'selected':'' }}>Admin</option>
                                </select>
                            </form>
                        </td>
                        <td class="text-center">
                            <span style="font-weight:700;color:{{ $user->posts_count > 0 ? '#fff' : '#444' }}">
                                {{ $user->posts_count }}
                            </span>
                        </td>
                        <td class="text-center">
                            @if($user->is_blocked)
                                <span class="badge-blocked">Bloqué</span>
                            @else
                                <span style="font-size:.7rem;color:#28a745">
                                    <i class="fa-solid fa-circle" style="font-size:.5rem"></i> Actif
                                </span>
                            @endif
                        </td>
                        <td class="text-center" style="color:#555;font-size:.78rem">
                            {{ $user->created_at?->format('d/m/Y') ?? '—' }}
                        </td>
                        <td class="text-center">
                            @if($user->id !== auth()->id())
                            <form action="{{ route('admin.users.block', $user->id) }}" method="POST" class="d-inline">
                                @csrf @method('PATCH')
                                <button class="btn btn-sm {{ $user->is_blocked ? 'btn-outline-success' : 'btn-outline-warning' }}"
                                    style="font-size:.72rem;padding:.25rem .6rem;border-radius:8px"
                                    title="{{ $user->is_blocked ? 'Débloquer' : 'Bloquer' }}">
                                    <i class="fa-solid {{ $user->is_blocked ? 'fa-lock-open' : 'fa-lock' }}"></i>
                                </button>
                            </form>
                            @else
                            <span style="font-size:.7rem;color:#333">Vous</span>
                            @endif
                        </td>
                    </tr>
                    @empty
                    <tr><td colspan="7" class="text-center py-4" style="color:#444">Aucun utilisateur trouvé</td></tr>
                    @endforelse
                </tbody>
            </table>
        </div>
        @if($users->hasPages())
        <div class="p-3" style="border-top:1px solid #1a1a1a">
            {{ $users->links() }}
        </div>
        @endif
    </div>
</div>

{{-- ════════════════════════════════════════════════════════════════════════════
     TAB 3 — POSTS
════════════════════════════════════════════════════════════════════════════ --}}
<div id="tab-posts" class="tab-pane">
    <form method="GET" action="{{ route('admin.dashboard') }}" class="mb-3">
        <input type="hidden" name="_tab" value="posts">
        <div class="row g-2">
            <div class="col-md-5">
                <input type="text" name="search_post" class="search-bar"
                    placeholder=" Rechercher un post par titre..."
                    value="{{ request('search_post') }}">
            </div>
            <div class="col-auto">
                <button type="submit" class="btn btn-sm" style="background:var(--orange);color:#000;font-weight:700;border-radius:8px">Filtrer</button>
            </div>
        </div>
    </form>

    <div class="card overflow-hidden">
        <div class="table-responsive">
            <table class="table table-hover m-0">
                <thead>
                    <tr>
                        <th>Post</th>
                        <th>Auteur</th>
                        <th>Lieu</th>
                        <th class="text-center">Date</th>
                        <th class="text-center">Action</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse($posts as $post)
                    <tr>
                        <td>
                            <div class="d-flex align-items-center gap-3">
                                <div class="post-thumb">
                                    @if($post->images->first())
                                        <img src="{{ $post->images->first()->url }}" alt="" onerror="this.parentElement.innerHTML='<i class=\'fa-solid fa-image\' style=\'color:#333\'></i>'">
                                    @else
                                        <i class="fa-solid fa-image" style="color:#333"></i>
                                    @endif
                                </div>
                                <div>
                                    <div class="fw-bold" style="font-size:.85rem">{{ Str::limit($post->title, 45) }}</div>
                                    <div style="font-size:.72rem;color:#555">{{ Str::limit($post->body, 60) }}</div>
                                </div>
                            </div>
                        </td>
                        <td style="font-size:.82rem">{{ $post->user->name }}</td>
                        <td style="font-size:.78rem;color:#666">{{ $post->location?->name ?? '—' }}</td>
                        <td class="text-center" style="font-size:.78rem;color:#555">{{ $post->created_at?->format('d/m/Y') ?? '—' }}</td>
                        <td class="text-center">
                            <form action="{{ route('admin.posts.delete', $post->id) }}" method="POST"
                                onsubmit="return confirm('Supprimer ce post ?')">
                                @csrf @method('DELETE')
                                <button class="btn btn-sm btn-outline-danger" style="font-size:.75rem;border-radius:8px">
                                    <i class="fa-solid fa-trash"></i>
                                </button>
                            </form>
                        </td>
                    </tr>
                    @empty
                    <tr><td colspan="5" class="text-center py-4" style="color:#444">Aucun post trouvé</td></tr>
                    @endforelse
                </tbody>
            </table>
        </div>
        @if($posts->hasPages())
        <div class="p-3" style="border-top:1px solid #1a1a1a">{{ $posts->links() }}</div>
        @endif
    </div>
</div>

{{-- ════════════════════════════════════════════════════════════════════════════
     TAB 4 — ACTIVITIES
════════════════════════════════════════════════════════════════════════════ --}}
<div id="tab-activities" class="tab-pane">
    <form method="GET" action="{{ route('admin.dashboard') }}" class="mb-3">
        <input type="hidden" name="_tab" value="activities">
        <div class="row g-2">
            <div class="col-md-5">
                <input type="text" name="search_activity" class="search-bar"
                    placeholder=" Rechercher une activité..."
                    value="{{ request('search_activity') }}">
            </div>
            <div class="col-auto">
                <button type="submit" class="btn btn-sm" style="background:var(--orange);color:#000;font-weight:700;border-radius:8px">Filtrer</button>
            </div>
        </div>
    </form>

    <div class="card overflow-hidden">
        <div class="table-responsive">
            <table class="table table-hover m-0">
                <thead>
                    <tr>
                        <th>Activité</th>
                        <th>Organisateur</th>
                        <th class="text-center">Participants</th>
                        <th class="text-center">Capacité</th>
                        <th class="text-center">Prix</th>
                        <th class="text-center">Date</th>
                        <th class="text-center">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse($activities as $activity)
                    <tr>
                        <td>
                            <div class="fw-bold" style="font-size:.85rem">{{ Str::limit($activity->title, 40) }}</div>
                            @if($activity->description)
                            <div style="font-size:.72rem;color:#555">{{ Str::limit($activity->description, 55) }}</div>
                            @endif
                        </td>
                        <td style="font-size:.82rem">{{ $activity->organizer?->name ?? '—' }}</td>
                        <td class="text-center">
                            <span class="fw-bold" style="color:{{ $activity->participants_count >= ($activity->capacity ?? 999) ? '#dc3545' : '#fff' }}">
                                {{ $activity->participants_count }}
                            </span>
                        </td>
                        <td class="text-center" style="font-size:.82rem;color:#666">
                            {{ $activity->capacity ?? '∞' }}
                        </td>
                        <td class="text-center">
                            @if($activity->price && $activity->price > 0)
                                <span style="color:var(--orange);font-weight:700;font-size:.82rem">{{ $activity->price }} DH</span>
                            @else
                                <span style="color:#28a745;font-size:.8rem">Gratuit</span>
                            @endif
                        </td>
                        <td class="text-center" style="font-size:.78rem;color:#555">
                            {{ $activity->created_at?->format('d/m/Y') ?? '—' }}
                        </td>
                        <td class="text-center">
                            <div class="d-flex gap-1 justify-content-center">
                                {{-- View participants --}}
                                <a href="{{ route('admin.activities.participants', $activity->id) }}"
                                    class="btn btn-sm btn-outline-info" style="font-size:.75rem;border-radius:8px"
                                    title="Voir participants">
                                    <i class="fa-solid fa-users"></i>
                                    <span class="ms-1">{{ $activity->participants_count }}</span>
                                </a>
                                {{-- Delete --}}
                                <form action="{{ route('admin.activities.delete', $activity->id) }}" method="POST"
                                    onsubmit="return confirm('Supprimer cette activité et ses {{ $activity->participants_count }} participants ?')">
                                    @csrf @method('DELETE')
                                    <button class="btn btn-sm btn-outline-danger" style="font-size:.75rem;border-radius:8px">
                                        <i class="fa-solid fa-trash"></i>
                                    </button>
                                </form>
                            </div>
                        </td>
                    </tr>
                    @empty
                    <tr><td colspan="7" class="text-center py-4" style="color:#444">Aucune activité trouvée</td></tr>
                    @endforelse
                </tbody>
            </table>
        </div>
        @if($activities->hasPages())
        <div class="p-3" style="border-top:1px solid #1a1a1a">{{ $activities->links() }}</div>
        @endif
    </div>
</div>

{{-- ════════════════════════════════════════════════════════════════════════════
     TAB 5 — LOCATIONS
════════════════════════════════════════════════════════════════════════════ --}}
<div id="tab-locations" class="tab-pane">
    <div class="row g-4">

        {{-- Add location form --}}
        <div class="col-lg-4">
            <div class="card p-3">
                <div class="section-title"><span>Ajouter</span> un lieu</div>
                <form action="{{ route('admin.locations.store') }}" method="POST">
                    @csrf
                    <div class="mb-3">
                        <label class="form-label" style="font-size:.78rem;color:#666;font-weight:700;text-transform:uppercase">Nom *</label>
                        <input type="text" name="name" required class="form-control form-control-dark" placeholder="Ex: Chefchaouen">
                    </div>
                    <div class="mb-3">
                        <label class="form-label" style="font-size:.78rem;color:#666;font-weight:700;text-transform:uppercase">Description</label>
                        <textarea name="description" rows="2" class="form-control form-control-dark" placeholder="Description du lieu..."></textarea>
                    </div>
                    <div class="row g-2 mb-3">
                        <div class="col">
                            <label class="form-label" style="font-size:.78rem;color:#666;font-weight:700;text-transform:uppercase">Latitude</label>
                            <input type="number" step="any" name="latitude" class="form-control form-control-dark" placeholder="35.1688">
                        </div>
                        <div class="col">
                            <label class="form-label" style="font-size:.78rem;color:#666;font-weight:700;text-transform:uppercase">Longitude</label>
                            <input type="number" step="any" name="longitude" class="form-control form-control-dark" placeholder="-5.2690">
                        </div>
                    </div>
                    <div class="row g-2 mb-4">
                        <div class="col">
                            <input type="text" name="city" class="form-control form-control-dark" placeholder="Ville">
                        </div>
                        <div class="col">
                            <input type="text" name="country" class="form-control form-control-dark" placeholder="Pays">
                        </div>
                    </div>
                    <button type="submit" class="btn w-100 fw-bold" style="background:var(--orange);color:#000;border-radius:10px">
                        <i class="fa-solid fa-plus me-1"></i>Ajouter le lieu
                    </button>
                </form>
            </div>
        </div>

        {{-- Locations list --}}
        <div class="col-lg-8">
            <form method="GET" action="{{ route('admin.dashboard') }}" class="mb-3">
                <input type="hidden" name="_tab" value="locations">
                <div class="row g-2">
                    <div class="col">
                        <input type="text" name="search_location" class="search-bar"
                            placeholder=" Rechercher un lieu..."
                            value="{{ request('search_location') }}">
                    </div>
                    <div class="col-auto">
                        <button type="submit" class="btn btn-sm" style="background:var(--orange);color:#000;font-weight:700;border-radius:8px">Filtrer</button>
                    </div>
                </div>
            </form>

            <div class="card overflow-hidden">
                <div class="table-responsive">
                    <table class="table table-hover m-0">
                        <thead>
                            <tr>
                                <th>Lieu</th>
                                <th class="text-center">Note</th>
                                <th class="text-center">Avis</th>
                                <th>Coordonnées</th>
                                <th class="text-center">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            @forelse($locations as $loc)
                            <tr>
                                <td>
                                    <div class="fw-bold" style="font-size:.85rem">{{ $loc->name }}</div>
                                    @if($loc->city)
                                    <div style="font-size:.72rem;color:#555">
                                        <i class="fa-solid fa-city me-1" style="font-size:.6rem"></i>{{ $loc->city }}{{ $loc->country ? ', '.$loc->country : '' }}
                                    </div>
                                    @endif
                                </td>
                                <td class="text-center">
                                    @if($loc->avg_rating)
                                    <span style="color:#ffc107;font-weight:700;font-size:.85rem">
                                        <i class="fa-solid fa-star" style="font-size:.7rem"></i>
                                        {{ number_format($loc->avg_rating, 1) }}
                                    </span>
                                    @else
                                    <span style="color:#333;font-size:.8rem">—</span>
                                    @endif
                                </td>
                                <td class="text-center" style="font-size:.82rem;color:#666">{{ $loc->ratings_count }}</td>
                                <td style="font-size:.75rem;color:#555;font-family:monospace">
                                    @if($loc->latitude && $loc->longitude)
                                        {{ number_format($loc->latitude,4) }}, {{ number_format($loc->longitude,4) }}
                                    @else
                                        <span style="color:#333">Non défini</span>
                                    @endif
                                </td>
                                <td class="text-center">
                                    <div class="d-flex gap-1 justify-content-center">
                                        {{-- Edit modal trigger --}}
                                        <button class="btn btn-sm btn-outline-secondary" style="font-size:.75rem;border-radius:8px"
                                            onclick="openEditLocation({{ $loc->id }}, '{{ addslashes($loc->name) }}', '{{ addslashes($loc->description ?? '') }}', '{{ $loc->latitude }}', '{{ $loc->longitude }}', '{{ addslashes($loc->city ?? '') }}', '{{ addslashes($loc->country ?? '') }}')"
                                            title="Modifier">
                                            <i class="fa-solid fa-pen"></i>
                                        </button>
                                        {{-- Delete --}}
                                        <form action="{{ route('admin.locations.delete', $loc->id) }}" method="POST"
                                            onsubmit="return confirm('Supprimer ce lieu ? Les posts et activités liés seront aussi affectés.')">
                                            @csrf @method('DELETE')
                                            <button class="btn btn-sm btn-outline-danger" style="font-size:.75rem;border-radius:8px">
                                                <i class="fa-solid fa-trash"></i>
                                            </button>
                                        </form>
                                    </div>
                                </td>
                            </tr>
                            @empty
                            <tr><td colspan="5" class="text-center py-4" style="color:#444">Aucun lieu trouvé</td></tr>
                            @endforelse
                        </tbody>
                    </table>
                </div>
                @if($locations->hasPages())
                <div class="p-3" style="border-top:1px solid #1a1a1a">{{ $locations->links() }}</div>
                @endif
            </div>
        </div>
    </div>
</div>

{{-- ── Edit Location Modal ──────────────────────────────────────────────────── --}}
<div class="modal fade" id="editLocationModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content" style="background:#111;border:1px solid #222">
            <div class="modal-header" style="border-color:#222">
                <h6 class="modal-title fw-bold" style="color:var(--orange)">
                    <i class="fa-solid fa-pen me-2"></i>Modifier le lieu
                </h6>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <form id="editLocationForm" method="POST">
                @csrf @method('PATCH')
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label" style="font-size:.78rem;color:#666;font-weight:700;text-transform:uppercase">Nom *</label>
                        <input type="text" name="name" id="edit_name" required class="form-control form-control-dark">
                    </div>
                    <div class="mb-3">
                        <label class="form-label" style="font-size:.78rem;color:#666;font-weight:700;text-transform:uppercase">Description</label>
                        <textarea name="description" id="edit_description" rows="2" class="form-control form-control-dark"></textarea>
                    </div>
                    <div class="row g-2 mb-3">
                        <div class="col">
                            <label class="form-label" style="font-size:.78rem;color:#666;font-weight:700;text-transform:uppercase">Latitude</label>
                            <input type="number" step="any" name="latitude" id="edit_latitude" class="form-control form-control-dark">
                        </div>
                        <div class="col">
                            <label class="form-label" style="font-size:.78rem;color:#666;font-weight:700;text-transform:uppercase">Longitude</label>
                            <input type="number" step="any" name="longitude" id="edit_longitude" class="form-control form-control-dark">
                        </div>
                    </div>
                    <div class="row g-2">
                        <div class="col">
                            <input type="text" name="city" id="edit_city" class="form-control form-control-dark" placeholder="Ville">
                        </div>
                        <div class="col">
                            <input type="text" name="country" id="edit_country" class="form-control form-control-dark" placeholder="Pays">
                        </div>
                    </div>
                </div>
                <div class="modal-footer" style="border-color:#222">
                    <button type="button" class="btn btn-sm btn-outline-secondary" data-bs-dismiss="modal">Annuler</button>
                    <button type="submit" class="btn btn-sm fw-bold" style="background:var(--orange);color:#000;border-radius:8px">
                        Enregistrer
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

{{-- ── Scripts ──────────────────────────────────────────────────────────────── --}}
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
// ── Tab system ────────────────────────────────────────────────────────────────
function showTab(name) {
    document.querySelectorAll('.tab-pane').forEach(p => p.classList.remove('active'));
    document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
    document.getElementById('tab-' + name).classList.add('active');
    event.currentTarget.classList.add('active');
    localStorage.setItem('adminTab', name);
}

// Restore last active tab
const savedTab = new URLSearchParams(location.search).get('_tab') || localStorage.getItem('adminTab');
if (savedTab) {
    const btn = [...document.querySelectorAll('.tab-btn')].find(b => b.getAttribute('onclick')?.includes(savedTab));
    if (btn) { btn.classList.add('active'); document.querySelectorAll('.tab-btn')[0].classList.remove('active'); }
    const pane = document.getElementById('tab-' + savedTab);
    if (pane) { pane.classList.add('active'); document.getElementById('tab-overview').classList.remove('active'); }
}

// ── Charts ────────────────────────────────────────────────────────────────────
const chartDefaults = {
    type: 'bar',
    options: {
        responsive: true, maintainAspectRatio: false,
        plugins: { legend: { display: false } },
        scales: {
            x: { grid: { color: '#1a1a1a' }, ticks: { color: '#555', font: { size: 11 } } },
            y: { grid: { color: '#1a1a1a' }, ticks: { color: '#555', font: { size: 11 } }, beginAtZero: true },
        },
    },
};

const usersData  = @json($usersByMonth);
const postsData  = @json($postsByMonth);

new Chart(document.getElementById('chartUsers'), {
    ...chartDefaults,
    data: {
        labels: Object.keys(usersData),
        datasets: [{ data: Object.values(usersData), backgroundColor: 'rgba(253,126,20,.7)',
            borderColor: '#fd7e14', borderWidth: 1, borderRadius: 6 }],
    },
});

new Chart(document.getElementById('chartPosts'), {
    ...chartDefaults,
    data: {
        labels: Object.keys(postsData),
        datasets: [{ data: Object.values(postsData), backgroundColor: 'rgba(255,255,255,.1)',
            borderColor: '#444', borderWidth: 1, borderRadius: 6 }],
    },
});

// ── Edit location modal ───────────────────────────────────────────────────────
function openEditLocation(id, name, desc, lat, lng, city, country) {
    document.getElementById('editLocationForm').action = `/admin/locations/${id}`;
    document.getElementById('edit_name').value        = name;
    document.getElementById('edit_description').value = desc;
    document.getElementById('edit_latitude').value    = lat;
    document.getElementById('edit_longitude').value   = lng;
    document.getElementById('edit_city').value        = city;
    document.getElementById('edit_country').value     = country;
    new bootstrap.Modal(document.getElementById('editLocationModal')).show();
}

// ── Auto-dismiss flash ────────────────────────────────────────────────────────
setTimeout(() => {
    document.querySelectorAll('.flash').forEach(el => {
        bootstrap.Alert.getOrCreateInstance(el)?.close();
    });
}, 4000);

// ── Search on Enter ───────────────────────────────────────────────────────────
document.querySelectorAll('.search-bar[type=text]').forEach(input => {
    input.addEventListener('keydown', e => {
        if (e.key === 'Enter') e.target.closest('form').submit();
    });
});
</script>
</body>
</html>
