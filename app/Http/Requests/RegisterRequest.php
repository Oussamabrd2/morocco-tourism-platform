<?php
// app/Http/Requests/RegisterRequest.php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class RegisterRequest extends FormRequest
{
    public function authorize(): bool { return true; }

    public function rules(): array
    {
        return [
            'name'       => 'required|string|min:3|max:255',
            'email'      => 'required|email|unique:users,email',
            'password'   => 'required|string|min:8',
            'gender'     => 'nullable|in:Man,Woman,Non-binary,Prefer not to say',
            'birth_date' => 'nullable|date|before:today|after:1900-01-01',
        ];
    }

    public function messages(): array
    {
        return [
            'name.min'          => 'Le nom doit contenir au moins 3 caractères',
            'email.unique'      => 'Cet email est déjà utilisé',
            'password.min'      => 'Le mot de passe doit contenir au moins 8 caractères',
            'birth_date.before' => 'La date de naissance doit être dans le passé',
        ];
    }
}
