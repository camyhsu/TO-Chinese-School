class LibraryBook < ActiveRecord::Base

  LIBRARY_BOOK_TYPE_MIXED = 'S/T'
  LIBRARY_BOOK_TYPE_SIMPLIFIED = 'S'
  LIBRARY_BOOK_TYPE_TRADITIONAL = 'T'

  LIBRARY_BOOK_TYPES = [LIBRARY_BOOK_TYPE_MIXED, LIBRARY_BOOK_TYPE_SIMPLIFIED, LIBRARY_BOOK_TYPE_TRADITIONAL]

  has_many :library_book_checkouts, order: 'checked_out_date DESC'
  validates :title, :publisher, :book_type, presence: true

  def find_current_checkout_record
    LibraryBookCheckout.first :conditions => ['library_book_id = ? AND return_date IS NULL', self.id]
  end

  def self.find_eligible_checkout_people
    people = InstructorAssignment.find_instructors
    people << Role.find_people_with_role(Role::ROLE_NAME_PRINCIPAL)
    people << Role.find_people_with_role(Role::ROLE_NAME_LIBRARIAN)
    people << Role.find_people_with_role(Role::ROLE_NAME_INSTRUCTION_OFFICER)
    people.flatten.uniq.sort { |x, y| x.english_name <=> y.english_name }
  end
end
