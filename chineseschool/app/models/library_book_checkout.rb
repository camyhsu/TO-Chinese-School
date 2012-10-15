class LibraryBookCheckout < ActiveRecord::Base

  belongs_to :library_book
  belongs_to :checked_out_by, :class_name => 'Person', :foreign_key => 'checked_out_by_id'

  validates_presence_of :library_book, :checked_out_by, :transaction_date, :checked_out_transaction
end
