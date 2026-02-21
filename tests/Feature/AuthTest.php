<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\User;

class AuthTest extends TestCase
{
    use RefreshDatabase;

    public function test_register_returns_token_and_user()
    {
        $payload = [
            'name' => 'Test User',
            'email' => 'test@example.com',
            'password' => 'secret123',
        ];

        $resp = $this->postJson('/api/v1/auth/register', $payload);

        $resp->assertStatus(201)->assertJsonStructure(['data' => ['user' => ['id','name','email'], 'token']]);
        $this->assertDatabaseHas('users', ['email' => 'test@example.com']);
    }

    public function test_login_returns_token()
    {
        $user = User::factory()->create(['password' => bcrypt('password123')]);

        $resp = $this->postJson('/api/v1/auth/login', ['email' => $user->email, 'password' => 'password123']);

        $resp->assertStatus(200)->assertJsonStructure(['data' => ['user' => ['id','email'], 'token']]);
    }

    public function test_logout_revokes_token()
    {
        $user = User::factory()->create();
        $token = $user->createToken('test')->plainTextToken;

        $resp = $this->withHeader('Authorization', 'Bearer '.$token)->postJson('/api/v1/auth/logout');

        $resp->assertStatus(200)->assertJson(['message' => 'Logged out']);
    }
}
