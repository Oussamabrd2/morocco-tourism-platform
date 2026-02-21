<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Post;
use Illuminate\Http\Request;
use Illuminate\Foundation\Auth\Access\AuthorizesRequests;

class PostController extends Controller
{
    use AuthorizesRequests;

    public function __construct()
    {
        $this->middleware('auth:sanctum')->only(['store', 'destroy']);
    }

    public function index(Request $request)
    {
        $posts = Post::with(['user', 'images', 'location'])
            ->latest()
            ->paginate(10);

        return response()->json($posts);
    }

    public function show($id)
    {
        $post = Post::with(['user', 'images', 'location', 'comments'])
            ->findOrFail($id);

        return response()->json(['data' => $post]);
    }

    public function store(Request $request)
    {
        $this->authorize('create', Post::class);

        $data = $request->validate([
            'title' => 'nullable|string',
            'body' => 'nullable|string',
            'place_name' => 'nullable|string',
            'description' => 'nullable|string',
            'location_id' => 'nullable|exists:locations,id',
            'rating' => 'nullable|numeric|min:0|max:5',
        ]);

        $data['user_id'] = $request->user()->id;

        if (isset($data['place_name']) && empty($data['title'])) {
            $data['title'] = $data['place_name'];
        }

        if (isset($data['description']) && empty($data['body'])) {
            $data['body'] = $data['description'];
        }

        $post = Post::create($data);

        return response()->json(['data' => $post], 201);
    }

    public function destroy(Request $request, $id)
    {
        $post = Post::findOrFail($id);

        $this->authorize('delete', $post);

        $post->delete();

        return response()->json(['message' => 'Deleted successfully']);
    }
}
