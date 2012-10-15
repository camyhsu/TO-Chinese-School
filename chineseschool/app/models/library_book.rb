class LibraryBook < ActiveRecord::Base

  validates_presence_of :title, :publisher, :book_type, :checked_out

end
