class LibraryBook < ActiveRecord::Base

  LIBRARY_BOOK_TYPE_MIXED = 'S/T'
  LIBRARY_BOOK_TYPE_SIMPLIFIED = 'S'
  LIBRARY_BOOK_TYPE_TRADITIONAL = 'T'

  LIBRARY_BOOK_TYPES = [LIBRARY_BOOK_TYPE_MIXED, LIBRARY_BOOK_TYPE_SIMPLIFIED, LIBRARY_BOOK_TYPE_TRADITIONAL]

  has_many :library_book_checkouts, :order => 'checked_out_date DESC'
  validates_presence_of :title, :publisher, :book_type

  def find_current_checkout_record
    LibraryBookCheckout.first :conditions => ['library_book_id = ? AND return_date IS NULL', self.id]
  end
end
