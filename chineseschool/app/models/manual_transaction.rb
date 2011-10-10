class ManualTransaction < ActiveRecord::Base
  
  TRANSACTION_TYPE_REGISTRATION = 'Registration'
  TRANSACTION_TYPE_WITHDRAWAL = 'Withdrawal'
  TRANSACTION_TYPE_TEXTBOOK_PURCHASE = 'Textbook Purchase'
  TRANSACTION_TYPE_OTHER_PAYMENT = 'Other Payment'
  TRANSACTION_TYPE_OTHER_REFUND = 'Other Refund'
  
  PAYMENT_METHOD_CHECK = 'Check'
  PAYMENT_METHOD_CASH = 'Cash'
  PAYMENT_METHODS = [PAYMENT_METHOD_CHECK, PAYMENT_METHOD_CASH]
  
  belongs_to :recorded_by, :class_name => 'Person', :foreign_key => 'recorded_by_id'
  belongs_to :student, :class_name => 'Person', :foreign_key => 'student_id'
  belongs_to :transaction_by, :class_name => 'Person', :foreign_key => 'transaction_by_id'
  
  validates_presence_of :student, :transaction_by, :amount_in_cents, :transaction_type, :transaction_date, :payment_method
  validates_presence_of :check_number, :if => Proc.new { |manual_transaction| manual_transaction.payment_method == PAYMENT_METHOD_CHECK }
  
  validates_numericality_of :amount_in_cents, :only_integer => true, :greater_than => 0, :allow_nil => false
  
  
  def amount
    self.amount_in_cents / 100.0
  end

  def amount=(amount)
    self.amount_in_cents = (amount.to_f * 100).to_i
  end
  
  def find_available_transaction_types
    available_transaction_types = []
    student_status_flag = self.student.student_status_flag_for SchoolYear.current_school_year
    if student_status_flag.nil? or !student_status_flag.registered?
      available_transaction_types << TRANSACTION_TYPE_REGISTRATION
    else
      available_transaction_types << TRANSACTION_TYPE_WITHDRAWAL
    end
    available_transaction_types << TRANSACTION_TYPE_TEXTBOOK_PURCHASE
    available_transaction_types << TRANSACTION_TYPE_OTHER_PAYMENT
    available_transaction_types << TRANSACTION_TYPE_OTHER_REFUND
    available_transaction_types
  end
end
