<?php

namespace App\Http\Controllers;

use App\Models\Book;
use Illuminate\Http\Request;

class BookController extends Controller
{
    public function index()
    {
        $books = Book::all()->sortByDesc('created_at');
        return view('books.index', ['books' => $books]); 
    }

        public function create()
    {
        return view('books.create');
    }

    public function edit($id)
    {
        $book = Book::findOrFail($id);
        return view('books.edit', ['book' => $book]); 
    }

    public function store(Request $request)
    {
        try {
            $book = Book::create([
                'title' => $request->title,
                'body' => $request->body,
            ]);
        } catch (Exception $e)  {
            \Log::error($e);
            throw new ErrorException($e);
        }

        session()->flash('flash_message', '投稿が完了しました');

        return redirect()->route('books.index');
    }

    public function update(Request $request, $id)
    {
        try {
            $book = Book::findOrFail($id);
            $book->fill($request->all());
            $book->save();
        } catch (Exception $e)  {
            \Log::error($e);
            throw new ErrorException($e);
        }

        session()->flash('flash_message', '更新が完了しました');
        return redirect()->route('books.index');
    }

    public function destroy($id)
    {
        try {
            Book::findOrFail($id)->delete();
        } catch (Exception $e)  {
            \Log::error($e);
            throw new ErrorException($e);
        }

        return redirect()->route('books.index');
    }
}
