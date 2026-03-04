<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>Admin Dashboard - Ziarat</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-900 text-gray-100 min-h-screen">
    <nav class="bg-gray-800 py-4 px-6 flex justify-between items-center">
        <h1 class="text-xl font-bold text-orange-500">Admin Dashboard</h1>
        <form method="POST" action="{{ route('logout') }}" class="inline">
            @csrf
            <button type="submit" class="text-gray-400 hover:text-white">Logout</button>
        </form>
    </nav>

    <main class="p-6 max-w-7xl mx-auto">
        {{-- Stats --}}
        <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-8">
            <div class="bg-gray-800 rounded-lg p-4">
                <p class="text-gray-400 text-sm">Total Users</p>
                <p class="text-2xl font-bold text-orange-500">{{ $totalUsers }}</p>
            </div>
            <div class="bg-gray-800 rounded-lg p-4">
                <p class="text-gray-400 text-sm">Total Posts</p>
                <p class="text-2xl font-bold text-orange-500">{{ $totalPosts }}</p>
            </div>
            <div class="bg-gray-800 rounded-lg p-4">
                <p class="text-gray-400 text-sm">Total Reviews</p>
                <p class="text-2xl font-bold text-orange-500">{{ $totalReviews }}</p>
            </div>
            <div class="bg-gray-800 rounded-lg p-4">
                <p class="text-gray-400 text-sm">Total Activities</p>
                <p class="text-2xl font-bold text-orange-500">{{ $totalActivities }}</p>
            </div>
        </div>

        {{-- Users --}}
        <section class="mb-8">
            <h2 class="text-lg font-semibold mb-4">Users</h2>
            <div class="bg-gray-800 rounded-lg overflow-hidden">
                <table class="w-full">
                    <thead class="bg-gray-700">
                        <tr>
                            <th class="text-left p-3">ID</th>
                            <th class="text-left p-3">Name</th>
                            <th class="text-left p-3">Email</th>
                            <th class="text-left p-3">Role</th>
                            <th class="text-left p-3">Posts</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach($users as $u)
                        <tr class="border-t border-gray-700">
                            <td class="p-3">{{ $u->id }}</td>
                            <td class="p-3">{{ $u->name }}</td>
                            <td class="p-3">{{ $u->email }}</td>
                            <td class="p-3">
                                <form method="POST" action="{{ route('admin.users.role', $u->id) }}" class="inline" onsubmit="this.submit(); return false;">
                                    @csrf
                                    <select name="role" onchange="this.form.submit()"
                                        class="bg-gray-700 border border-gray-600 rounded px-2 py-1 text-sm {{ $u->role === 'admin' ? 'text-orange-400' : '' }}">
                                        <option value="user" {{ $u->role === 'user' ? 'selected' : '' }}>user</option>
                                        <option value="organizer" {{ $u->role === 'organizer' ? 'selected' : '' }}>organizer</option>
                                        <option value="admin" {{ $u->role === 'admin' ? 'selected' : '' }}>admin</option>
                                    </select>
                                </form>
                            </td>
                            <td class="p-3">{{ $u->posts_count ?? 0 }}</td>
                        </tr>
                        @endforeach
                    </tbody>
                </table>
                <div class="p-3">{{ $users->links() }}</div>
            </div>
        </section>

        {{-- Delete Posts / Activities - links to API or simple forms --}}
        <section class="grid md:grid-cols-2 gap-6">
            <div class="bg-gray-800 rounded-lg p-4">
                <h2 class="text-lg font-semibold mb-3">Delete Post</h2>
                <form method="POST" action="{{ route('admin.posts.delete') }}" class="flex gap-2">
                    @csrf
                    <input type="number" name="id" placeholder="Post ID" required class="flex-1 bg-gray-700 rounded px-3 py-2">
                    <button type="submit" class="px-4 py-2 bg-red-600 hover:bg-red-700 rounded">Delete</button>
                </form>
            </div>
            <div class="bg-gray-800 rounded-lg p-4">
                <h2 class="text-lg font-semibold mb-3">Delete Activity</h2>
                <form method="POST" action="{{ route('admin.activities.delete') }}" class="flex gap-2">
                    @csrf
                    <input type="number" name="id" placeholder="Activity ID" required class="flex-1 bg-gray-700 rounded px-3 py-2">
                    <button type="submit" class="px-4 py-2 bg-red-600 hover:bg-red-700 rounded">Delete</button>
                </form>
            </div>
        </section>
    </main>
</body>
</html>
