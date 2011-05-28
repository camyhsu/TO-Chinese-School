class StudentFeePayment < ActiveRecord::Base

  belongs_to :registration_payment
  belongs_to :student, :class_name => 'Person', :foreign_key => 'student_id'

  validates_presence_of :registration_payment, :student, :registration_fee_in_cents, :tuition_in_cents, :book_charge_in_cents

  validates_numericality_of :registration_fee_in_cents, :only_integer => true, :allow_nil => false
  validates_numericality_of :tuition_in_cents, :only_integer => true, :allow_nil => false
  validates_numericality_of :book_charge_in_cents, :only_integer => true, :allow_nil => false
  
end
