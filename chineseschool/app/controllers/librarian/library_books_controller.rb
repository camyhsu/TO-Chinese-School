class Librarian::LibraryBooksController < ApplicationController

  verify :only => [:check_out_library_book, :return_library_book], :method => :post,
         :add_flash => {:notice => 'Illegal GET'}, :redirect_to => {:controller => '/signout', :action => 'index'}

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

  def checkout_history
    @library_book = LibraryBook.find_by_id params[:id].to_i
  end

  def check_out_library_book
    @library_book = LibraryBook.find_by_id params[:id].to_i
    library_book_checkout = LibraryBookCheckout.new
    library_book_checkout.checked_out_by = Person.find_by_id params[:checked_out_by][:id]
    library_book_checkout.checked_out_date = Date.parse params[:check_out_date]
    library_book_checkout.note = params[:note]
    library_book_checkout.library_book = @library_book
    if library_book_checkout.valid?
      LibraryBook.transaction do
        library_book_checkout.save!
        @library_book.checked_out = true
        @library_book.save!
      end
    end
    render :action => :checkout_history
  end

  def return_library_book
    @library_book = LibraryBook.find_by_id params[:id].to_i
    current_checkout_record = @library_book.find_current_checkout_record
    current_checkout_record.return_date = Date.parse params[:return_date]
    current_checkout_record.note += " -- "
    current_checkout_record.note += params[:note]
    if current_checkout_record.valid?
      LibraryBook.transaction do
        current_checkout_record.save!
        @library_book.checked_out = false
        @library_book.save!
      end
    end
    render :action => :checkout_history
  end
end
