<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Login - Ziarat</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-900 min-h-screen flex items-center justify-center">
    <div class="bg-gray-800 p-8 rounded-xl shadow-xl w-full max-w-md">
        <h1 class="text-2xl font-bold text-orange-500 mb-6">Admin Login</h1>
        @if ($errors->any())
            <div class="mb-4 p-3 bg-red-900/50 border border-red-500 rounded text-red-200 text-sm">
                {{ $errors->first() }}
            </div>
        @endif
        <form method="POST" action="{{ route('login') }}">
            @csrf
            <div class="mb-4">
                <label class="block text-gray-300 text-sm mb-2">Email</label>
                <input type="email" name="email" value="{{ old('email') }}" required
                    class="w-full px-4 py-2 rounded bg-gray-700 text-white border border-gray-600 focus:border-orange-500">
            </div>
            <div class="mb-6">
                <label class="block text-gray-300 text-sm mb-2">Password</label>
                <input type="password" name="password" required
                    class="w-full px-4 py-2 rounded bg-gray-700 text-white border border-gray-600 focus:border-orange-500">
            </div>
            <button type="submit" class="w-full py-2 bg-orange-500 hover:bg-orange-600 text-black font-bold rounded">
                Login
            </button>
        </form>
    </div>
</body>
</html>
