{{-- resources/views/admin/participants.blade.php --}}
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Participants — {{ $activity->title }}</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root { --orange: #fd7e14; }
        body  { background: #000; color: #fff; font-family: 'Segoe UI', sans-serif; }
        .navbar-admin { background: #0a0a0a; border-bottom: 1px solid #1e1e1e;
            padding: .85rem 1.5rem; display: flex; justify-content: space-between; align-items: center; }
        .card  { background: #111; border: 1px solid #222; border-radius: 14px; }
        .table { --bs-table-bg: transparent; --bs-table-color: #ddd; border-color: #1e1e1e; font-size: .85rem; }
        .table thead th { background: #0d0d0d; color: #666; font-size: .72rem; text-transform: uppercase;
            letter-spacing: .6px; border-color: #1e1e1e; padding: .85rem 1rem; font-weight: 700; }
        .table tbody td { border-color: #1a1a1a; padding: .75rem 1rem; vertical-align: middle; }
        .table-hover tbody tr:hover td { background: #161616; }
        .flash { position: fixed; top: 1rem; right: 1rem; z-index: 9999; min-width: 280px; font-size: .85rem; }
        .pagination { --bs-pagination-bg: #111; --bs-pagination-border-color: #222;
            --bs-pagination-color: #888; --bs-pagination-hover-bg: #1a1a1a;
            --bs-pagination-hover-color: var(--orange); --bs-pagination-active-bg: var(--orange);
            --bs-pagination-active-border-color: var(--orange); font-size: .8rem; }
    </style>
</head>
<body>

{{-- Flash --}}
@if(session('success'))
<div class="flash alert alert-success alert-dismissible fade show shadow-lg py-2">
    <i class="fa-solid fa-circle-check me-2"></i>{{ session('success') }}
    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="alert"></button>
</div>
@endif

{{-- Navbar --}}
<nav class="navbar-admin">
    <div style="font-size:1.3rem;font-weight:900;color:var(--orange);letter-spacing:-1px">
        ZIARAT <small style="color:#fff;font-weight:300;font-size:.9rem">ADMIN</small>
    </div>
    <a href="{{ route('admin.dashboard') }}" class="btn btn-sm btn-outline-secondary" style="font-size:.8rem">
        <i class="fa-solid fa-arrow-left me-1"></i>Retour au dashboard
    </a>
</nav>

<div class="container-fluid p-4">

    {{-- Activity info --}}
    <div class="card p-4 mb-4">
        <div class="row align-items-center">
            <div class="col-md-8">
                <div style="font-size:.72rem;color:#555;font-weight:700;text-transform:uppercase;letter-spacing:.8px;margin-bottom:.4rem">
                    Activité
                </div>
                <h4 class="fw-black mb-1">{{ $activity->title }}</h4>
                @if($activity->organizer)
                <div style="font-size:.82rem;color:#666">
                    <i class="fa-solid fa-person me-1" style="color:var(--orange)"></i>
                    Organisé par <strong>{{ $activity->organizer->name }}</strong>
                </div>
                @endif
            </div>
            <div class="col-md-4">
                <div class="row g-3 text-center">
                    <div class="col-6">
                        <div style="font-size:.7rem;color:#555;text-transform:uppercase;font-weight:700">Participants</div>
                        <div style="font-size:2rem;font-weight:900;color:var(--orange)">
                            {{ $activity->participants_count }}
                        </div>
                    </div>
                    <div class="col-6">
                        <div style="font-size:.7rem;color:#555;text-transform:uppercase;font-weight:700">Capacité</div>
                        <div style="font-size:2rem;font-weight:900;color:#fff">
                            {{ $activity->capacity ?? '∞' }}
                        </div>
                    </div>
                </div>

                {{-- Capacity bar --}}
                @if($activity->capacity)
                @php $ratio = min(1, $activity->participants_count / $activity->capacity); @endphp
                <div style="margin-top:.75rem">
                    <div style="background:#1a1a1a;border-radius:6px;height:8px;overflow:hidden">
                        <div style="height:100%;width:{{ round($ratio*100) }}%;background:{{ $ratio >= 1 ? '#dc3545' : ($ratio >= .75 ? 'var(--orange)' : '#28a745') }};border-radius:6px;transition:width .4s"></div>
                    </div>
                    <div style="font-size:.72rem;color:#555;margin-top:.3rem;text-align:right">
                        {{ round($ratio*100) }}% rempli
                    </div>
                </div>
                @endif
            </div>
        </div>
    </div>

    {{-- Participants table --}}
    <div style="font-size:.8rem;font-weight:800;text-transform:uppercase;letter-spacing:.8px;color:#555;margin-bottom:1rem">
        <i class="fa-solid fa-users me-1" style="color:var(--orange)"></i>
        Liste des participants
        <span style="color:var(--orange)">({{ $participants->total() }})</span>
    </div>

    <div class="card overflow-hidden">
        <div class="table-responsive">
            <table class="table table-hover m-0">
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Participant</th>
                        <th>Email</th>
                        <th>Rôle</th>
                        <th class="text-center">Inscrit le</th>
                        <th class="text-center">Action</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse($participants as $i => $p)
                    <tr>
                        <td style="color:#444;font-size:.78rem">
                            {{ ($participants->currentPage() - 1) * $participants->perPage() + $i + 1 }}
                        </td>
                        <td>
                            <div class="d-flex align-items-center gap-2">
                                <div style="width:34px;height:34px;border-radius:50%;background:#1a1a1a;
                                    display:flex;align-items:center;justify-content:center;
                                    font-weight:700;font-size:.82rem;color:var(--orange);flex-shrink:0">
                                    {{ strtoupper(substr($p->user->name, 0, 1)) }}
                                </div>
                                <span class="fw-bold" style="font-size:.85rem">{{ $p->user->name }}</span>
                            </div>
                        </td>
                        <td style="font-size:.8rem;color:#666">{{ $p->user->email }}</td>
                        <td>
                            <span style="font-size:.72rem;font-weight:700;padding:.25rem .65rem;border-radius:20px;text-transform:uppercase;
                                background:{{ $p->user->role === 'admin' ? 'rgba(253,126,20,.15)' : ($p->user->role === 'organizer' ? 'rgba(13,202,240,.1)' : 'rgba(255,255,255,.05)') }};
                                color:{{ $p->user->role === 'admin' ? 'var(--orange)' : ($p->user->role === 'organizer' ? '#0dcaf0' : '#888') }};
                                border:1px solid {{ $p->user->role === 'admin' ? 'rgba(253,126,20,.3)' : ($p->user->role === 'organizer' ? 'rgba(13,202,240,.25)' : '#2a2a2a') }}">
                                {{ $p->user->role }}
                            </span>
                        </td>
                        <td class="text-center" style="font-size:.78rem;color:#555">
                            {{ $p->created_at?->format('d/m/Y à H:i') ?? '—' }}
                        </td>
                        <td class="text-center">
                            <form action="{{ route('admin.activities.participants.remove', [$activity->id, $p->user->id]) }}"
                                method="POST"
                                onsubmit="return confirm('Retirer {{ $p->user->name }} de cette activité ?')">
                                @csrf @method('DELETE')
                                <button class="btn btn-sm btn-outline-danger" style="font-size:.75rem;border-radius:8px"
                                    title="Retirer ce participant">
                                    <i class="fa-solid fa-user-minus"></i>
                                </button>
                            </form>
                        </td>
                    </tr>
                    @empty
                    <tr>
                        <td colspan="6" class="text-center py-5" style="color:#444">
                            <i class="fa-solid fa-users-slash fa-2x mb-3 d-block" style="color:#222"></i>
                            Aucun participant pour cette activité
                        </td>
                    </tr>
                    @endforelse
                </tbody>
            </table>
        </div>

        @if($participants->hasPages())
        <div class="p-3" style="border-top:1px solid #1a1a1a">
            {{ $participants->links() }}
        </div>
        @endif
    </div>

</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    setTimeout(() => {
        document.querySelectorAll('.flash').forEach(el => bootstrap.Alert.getOrCreateInstance(el)?.close());
    }, 4000);
</script>
</body>
</html>
