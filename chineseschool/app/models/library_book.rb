class LibraryBook < ActiveRecord::Base

  LIBRARY_BOOK_TYPE_MIXED = 'S/T'
  LIBRARY_BOOK_TYPE_SIMPLIFIED = 'S'
  LIBRARY_BOOK_TYPE_TRADITIONAL = 'T'

  LIBRARY_BOOK_TYPES = [LIBRARY_BOOK_TYPE_MIXED, LIBRARY_BOOK_TYPE_SIMPLIFIED, LIBRARY_BOOK_TYPE_TRADITIONAL]

  has_many :library_book_checkouts
  validates_presence_of :title, :publisher, :book_type

  def find_name_of_current_checked_out_by
    current_check_out_record = LibraryBookCheckout.first :conditions => ['library_book_id = ? AND return_date IS NULL', self.id]
    return '' if current_check_out_record.nil?
    current_check_out_record.checked_out_by.name
  end
end
