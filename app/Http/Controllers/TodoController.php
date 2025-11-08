<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Todo;

class TodoController extends Controller
{
    // List all todos for the authenticated user
    public function index(Request $request)
    {
        $todos = $request->user()->todos()->orderBy('created_at', 'desc')->get();
        return response()->json($todos);
    }

    // Store a new todo
    public function store(Request $request)
    {
        $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'nullable|string',
            'status' => 'nullable|in:pending,in_progress,completed',
            'priority' => 'nullable|in:low,medium,high',
            'due_date' => 'nullable|date',
        ]);

        $todo = $request->user()->todos()->create($request->all());

        return response()->json($todo, 201);
    }

    // Show a specific todo
    public function show(Request $request, Todo $todo)
    {
        // Ensure the authenticated user owns the todo
        if ($request->user()->id !== $todo->user_id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        return response()->json($todo);
    }

    // Update a todo
    public function update(Request $request, Todo $todo)
    {
        if ($request->user()->id !== $todo->user_id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $request->validate([
            'title' => 'sometimes|required|string|max:255',
            'description' => 'nullable|string',
            'status' => 'nullable|in:pending,in_progress,completed',
            'priority' => 'nullable|in:low,medium,high',
            'due_date' => 'nullable|date',
        ]);

        $todo->update($request->all());

        return response()->json($todo);
    }

    // Delete a todo
    public function destroy(Request $request, Todo $todo)
    {
        if ($request->user()->id !== $todo->user_id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $todo->delete();

        return response()->json(['message' => 'Todo deleted successfully']);
    }
}
