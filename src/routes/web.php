<?php

use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| contains the "web" middleware group. Now create something great!
|
*/

Route::get('/', function () {
    return view('welcome');
});
Route::get('/books', 'App\Http\Controllers\BookController@index')->name('books.index');
Route::get('/books/create', 'App\Http\Controllers\BookController@create')->name('books.create');
Route::get('/books/{id}', 'App\Http\Controllers\BookController@edit')->name('books.edit');
Route::post('/books', 'App\Http\Controllers\BookController@store')->name('books.store');
Route::put('/books/{id}', 'App\Http\Controllers\BookController@update')->name('books.update');
Route::delete('/books/{id}', 'App\Http\Controllers\BookController@destroy')->name('books.destroy');