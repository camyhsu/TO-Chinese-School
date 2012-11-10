module Librarian::LibraryBooksHelper

  def display_checked_out_by(library_book)
    return '' unless library_book.checked_out?
    current_checkout_record = library_book.find_current_checkout_record
    return '' if current_checkout_record.nil?
    h current_checkout_record.checked_out_by.name
  end
end
