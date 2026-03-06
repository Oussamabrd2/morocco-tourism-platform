<?php
// database/migrations/2024_01_03_add_profile_fields_to_users_table.php
// USE THIS if you already ran migrate — otherwise use the main migration above

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            if (! Schema::hasColumn('users', 'gender')) {
                $table->string('gender')->nullable()->after('bio');
            }
            if (! Schema::hasColumn('users', 'birth_date')) {
                $table->date('birth_date')->nullable()->after('gender');
            }
            if (! Schema::hasColumn('users', 'avatar_url')) {
                $table->string('avatar_url')->nullable()->after('bio');
            }
            if (! Schema::hasColumn('users', 'google_uid')) {
                $table->string('google_uid')->nullable()->unique()->after('password');
            }
            if (! Schema::hasColumn('users', 'role')) {
                $table->string('role')->default('user')->after('bio');
            }
            if (! Schema::hasColumn('users', 'is_blocked')) {
                $table->boolean('is_blocked')->default(false)->after('role');
            }
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn(['gender', 'birth_date', 'avatar_url', 'google_uid', 'role', 'is_blocked']);
        });
    }
};
