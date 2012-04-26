class BookCharge < ActiveRecord::Base
  
  belongs_to :school_year
  belongs_to :grade
  
  validates_presence_of :school_year, :grade, :book_charge_in_cents
  validates_numericality_of :book_charge_in_cents, :only_integer => true, :greater_than => -1, :allow_nil => false
  
  def book_charge
    self.book_charge_in_cents / 100.0
  end

  def book_charge=(book_charge)
    self.book_charge_in_cents = (book_charge * 100).to_i
  end
  
  def self.book_charge_in_cents_for(school_year, grade)
    book_charge = BookCharge.first :conditions => ['school_year_id = ? AND grade_id = ?', school_year.id, grade.id]
    book_charge.book_charge_in_cents
  end
end
