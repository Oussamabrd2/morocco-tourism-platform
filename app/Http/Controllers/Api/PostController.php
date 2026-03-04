<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\PostResource;
use App\Models\Post;
use App\Models\PostImage;
use App\Models\Rating;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;

class PostController extends Controller
{
    /**
     * List posts with user, images, location. Consistent JSON wrapper.
     */
    public function index(): JsonResponse
    {
        $posts = Post::with(['user', 'images', 'location.ratings'])
            ->latest()
            ->paginate(20);

        return response()->json([
            'data' => PostResource::collection($posts),
            'meta' => [
                'current_page' => $posts->currentPage(),
                'last_page' => $posts->lastPage(),
                'per_page' => $posts->perPage(),
                'total' => $posts->total(),
            ],
        ]);
    }

    /**
     * Get single post.
     */
    public function show(int $id): JsonResponse
    {
        $post = Post::with(['user', 'images', 'location'])->findOrFail($id);
        return response()->json(['data' => new PostResource($post)]);
    }

    /**
     * Create post. Requires auth. Validates title, body, location_id, score, optional image.
     */
    public function store(Request $request): JsonResponse
    {
        $request->validate([
            'title' => 'required|string|max:255',
            'body' => 'required|string',
            'location_id' => 'nullable|exists:locations,id',
            'score' => 'nullable|integer|min:1|max:5',
            'image' => 'nullable|image|max:5120',
        ]);

        return DB::transaction(function () use ($request) {
            $post = Post::create([
                'user_id' => auth()->id(),
                'title' => $request->title,
                'body' => $request->body,
                'location_id' => $request->location_id,
            ]);

            if ($request->hasFile('image')) {
                $path = $request->file('image')->store('posts', 'public');
                PostImage::create([
                    'post_id' => $post->id,
                    'url' => asset('storage/' . $path),
                ]);
            }

            if ($request->location_id && $request->has('score')) {
                Rating::updateOrCreate(
                    ['user_id' => auth()->id(), 'location_id' => $request->location_id],
                    ['post_id' => $post->id, 'score' => $request->score]
                );
            }

            $post->load(['user', 'images', 'location']);
            return response()->json(['data' => new PostResource($post)], 201);
        });
    }

    /**
     * Delete post. Owner or admin only.
     */
    public function destroy(int $id): JsonResponse
    {
        $post = Post::findOrFail($id);
        $this->authorize('delete', $post);

        DB::transaction(function () use ($post) {
            $post->images()->each(fn (PostImage $img) => Storage::disk('public')->delete(
                str_replace('/storage/', '', parse_url($img->url, PHP_URL_PATH))
            ));
            $post->images()->delete();
            $post->delete();
        });

        return response()->json(['message' => 'Post deleted']);
    }
}
