class Librarian::LibraryBooksController < ApplicationController

  def index
    @library_books = LibraryBook.all
    render :layout => 'jquery_datatable'
  end
end
