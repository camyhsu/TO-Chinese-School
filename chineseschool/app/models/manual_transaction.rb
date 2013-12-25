class ManualTransaction < ActiveRecord::Base
  
  TRANSACTION_TYPE_REGISTRATION = 'Registration'
  TRANSACTION_TYPE_WITHDRAWAL = 'Withdrawal'
  TRANSACTION_TYPE_TEXTBOOK_PURCHASE = 'Textbook Purchase'
  TRANSACTION_TYPE_OTHER_PAYMENT = 'Other Payment'
  TRANSACTION_TYPE_OTHER_REFUND = 'Other Refund'
  
  PAYMENT_METHOD_CHECK = 'Check'
  PAYMENT_METHOD_CASH = 'Cash'
  PAYMENT_METHODS = [PAYMENT_METHOD_CHECK, PAYMENT_METHOD_CASH]

  attr_accessible :student_id, :transaction_type, :transaction_date, :payment_method,
                  :check_number, :amount, :note

  belongs_to :recorded_by, class_name: 'Person', foreign_key: 'recorded_by_id'
  belongs_to :student, class_name: 'Person', foreign_key: 'student_id'
  belongs_to :transaction_by, class_name: 'Person', foreign_key: 'transaction_by_id'
  
  validates :student, :transaction_by, :amount_in_cents, :transaction_type, :transaction_date, :payment_method, presence: true
  validates :check_number, presence: true, if: Proc.new { |manual_transaction| manual_transaction.payment_method == PAYMENT_METHOD_CHECK }
  
  validates :amount_in_cents, numericality: {only_integer: true, greater_than_or_equal_to: 0, allow_nil: false}
  
  
  def amount
    self.amount_in_cents / 100.0
  end

  def amount=(amount)
    self.amount_in_cents = (amount.to_f * 100).to_i
  end
  
  def amount_with_sign
    if (self.transaction_type == TRANSACTION_TYPE_WITHDRAWAL or self.transaction_type == TRANSACTION_TYPE_OTHER_REFUND)
      -1 * self.amount
    else
      self.amount
    end
  end
  
  def find_available_transaction_types
    available_transaction_types = []
    student_status_flag = self.student.student_status_flag_for SchoolYear.current_school_year
    if student_status_flag && student_status_flag.registered?
      available_transaction_types << TRANSACTION_TYPE_WITHDRAWAL
    end
    available_transaction_types << TRANSACTION_TYPE_TEXTBOOK_PURCHASE
    available_transaction_types << TRANSACTION_TYPE_OTHER_PAYMENT
    available_transaction_types << TRANSACTION_TYPE_OTHER_REFUND
    available_transaction_types
  end
  
  def save_with_side_effects
    #if self.transaction_type == TRANSACTION_TYPE_REGISTRATION
    #  begin
    #    ManualTransaction.transaction do
    #      save!
    #      set_student_status_to_registered
    #    end
    #    true
    #  rescue => e
    #    puts "Saving manual transaction failed - Exception => #{e.inspect}"
    #    errors.add_to_base 'System Transaction Failed' if errors.empty?
    #    false
    #  end
    if self.transaction_type == TRANSACTION_TYPE_WITHDRAWAL
      begin
        ManualTransaction.transaction do
          save!
          move_student_class_assignment_to_withdrawal_record
        end
        true
      rescue => e
        puts "Saving manual transaction failed - Exception => #{e.inspect}"
        errors.add_to_base 'System Transaction Failed' if errors.empty?
        false
      end
    else
      save
    end
  end
  
  def set_student_status_to_registered
    current_school_year = SchoolYear.current_school_year
    student_status_flag = self.student.student_status_flag_for current_school_year
    if student_status_flag.nil?
      student_status_flag = StudentStatusFlag.new
      student_status_flag.school_year = current_school_year
      student_status_flag.student = self.student
    end
    student_status_flag.registered = true
    student_status_flag.last_status_change_date = self.transaction_date
    student_status_flag.save!
  end
  
  def move_student_class_assignment_to_withdrawal_record
    current_school_year = SchoolYear.current_school_year
    withdrawal_record = WithdrawalRecord.new
    withdrawal_record.school_year = current_school_year
    withdrawal_record.student = self.student
    withdrawal_record.withdrawal_date = self.transaction_date
    
    # Grab the registration time and set the student status to NOT registered
    student_status_flag = self.student.student_status_flag_for current_school_year
    unless student_status_flag.nil?
      withdrawal_record.registration_date = student_status_flag.last_status_change_date
      student_status_flag.registered = false
      student_status_flag.last_status_change_date = self.transaction_date
      student_status_flag.save!
    end
    
    # Move class assignment data to withdrawal record and destroy the class assignment
    student_class_assignment = self.student.student_class_assignment_for current_school_year
    unless student_class_assignment.nil?
      withdrawal_record.grade_id = student_class_assignment.grade_id
      withdrawal_record.school_class_id = student_class_assignment.school_class_id
      withdrawal_record.elective_class_id = student_class_assignment.elective_class_id
      student_class_assignment.destroy
    end
    withdrawal_record.save!
  end
end
