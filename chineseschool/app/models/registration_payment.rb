class RegistrationPayment < ActiveRecord::Base

  belongs_to :school_year
  belongs_to :paid_by, :class_name => 'Person', :foreign_key => 'paid_by_id'
  has_many :student_fee_payments

  validates_presence_of :school_year, :paid_by, :pva_due_in_cents, :ccca_due_in_cents

  validates_numericality_of :pva_due_in_cents, :only_integer => true, :allow_nil => false
  validates_numericality_of :ccca_due_in_cents, :only_integer => true, :allow_nil => false
  
  validate :calculate_grand_total


  private

  def calculate_grand_total
    
  end
end
