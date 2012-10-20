class Librarian::LibraryBooksController < ApplicationController

  def index
    @library_books = LibraryBook.all
    render :layout => 'jquery_datatable'
  end

  def new
    if request.post?
      @library_book = LibraryBook.new(params[:library_book])
      @library_book.checked_out = false
      if @library_book.save
        flash[:notice] = 'Library Book added successfully'
        redirect_to :action => :index
      end
    else
      @library_book = LibraryBook.new
    end
  end

  def edit
    @library_book = LibraryBook.find_by_id params[:id].to_i
    if request.post?
      if @library_book.update_attributes params[:library_book]
        flash[:notice] = 'Library Book updated successfully'
        redirect_to :action => :index
      end
    end
  end
end
