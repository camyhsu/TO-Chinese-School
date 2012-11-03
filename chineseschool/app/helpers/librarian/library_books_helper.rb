module Librarian::LibraryBooksHelper

  def display_checked_out_by(library_book)
    if library_book.checked_out?
      h library_book.find_name_of_current_checked_out_by
    else
      ''
    end
  end
end
