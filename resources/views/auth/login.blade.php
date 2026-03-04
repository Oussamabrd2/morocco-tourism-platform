{{-- resources/views/auth/login.blade.php --}}
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ziarat Admin — Connexion</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;700;900&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Inter', sans-serif; background-color: #000; }
    </style>
</head>
<body class="min-h-screen flex items-center justify-center p-6">

    <div class="w-full max-w-md">

        {{-- Logo --}}
        <div class="text-center mb-10">
            <h1 class="text-5xl font-black text-orange-500 tracking-tighter mb-2">ZIARAT</h1>
            <p class="text-gray-500 uppercase tracking-widest text-xs font-bold">
                Administration Panel
            </p>
        </div>

        {{-- Card --}}
        <div class="bg-[#111] border border-gray-800 p-8 rounded-2xl shadow-2xl">

            {{-- Error --}}
            @if ($errors->any())
            <div class="mb-6 p-4 bg-red-900/20 border border-red-500/40 rounded-xl text-red-400 text-sm flex items-center gap-2">
                <svg class="w-4 h-4 flex-shrink-0" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clip-rule="evenodd"/>
                </svg>
                {{ $errors->first() }}
            </div>
            @endif

            {{-- FIX: action points to named route 'login' (POST /login) --}}
            <form method="POST" action="{{ route('login') }}">
                @csrf

                <div class="mb-5">
                    <label class="block text-gray-400 text-xs font-black uppercase mb-2 tracking-wider">
                        Email
                    </label>
                    <input
                        type="email"
                        name="email"
                        value="{{ old('email') }}"
                        required
                        autofocus
                        class="w-full bg-[#1A1A1A] border border-gray-800 text-white px-4 py-3 rounded-xl
                               focus:outline-none focus:border-orange-500 focus:ring-1 focus:ring-orange-500
                               transition-all placeholder-gray-600"
                    >
                </div>

                <div class="mb-8">
                    <label class="block text-gray-400 text-xs font-black uppercase mb-2 tracking-wider">
                        Mot de passe
                    </label>
                    <input
                        type="password"
                        name="password"
                        required
                        class="w-full bg-[#1A1A1A] border border-gray-800 text-white px-4 py-3 rounded-xl
                               focus:outline-none focus:border-orange-500 focus:ring-1 focus:ring-orange-500
                               transition-all placeholder-gray-600"
                    >
                </div>

                <button
                    type="submit"
                    class="w-full bg-gradient-to-r from-orange-500 to-red-500 text-black font-black
                           py-4 rounded-xl hover:opacity-90 active:scale-95 transition-all
                           uppercase tracking-wide text-sm"
                >
                    Se Connecter
                </button>
            </form>

            <p class="text-center text-gray-600 text-xs mt-6">
                Accès réservé aux administrateurs Ziarat
            </p>
        </div>
    </div>

</body>
</html>
