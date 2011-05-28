class StudentFeePayment < ActiveRecord::Base

  belongs_to :registration_payment
  belongs_to :student, :class_name => 'Person', :foreign_key => 'student_id'

  validates_presence_of :registration_payment, :student, :registration_fee_in_cents, :tuition_in_cents, :book_charge_in_cents

  validates_numericality_of :registration_fee_in_cents, :only_integer => true, :allow_nil => false
  validates_numericality_of :tuition_in_cents, :only_integer => true, :allow_nil => false
  validates_numericality_of :book_charge_in_cents, :only_integer => true, :allow_nil => false


  def registration_fee
    self.registration_fee_in_cents / 100.0
  end

  def book_charge
    self.book_charge_in_cents / 100.0
  end

  def tuition
    self.tuition_in_cents / 100.0
  end
  
  def total_in_cents
    self.registration_fee_in_cents + self.book_charge_in_cents + self.tuition_in_cents
  end
  
  def fill_in_tuition_and_fee(school_year, grade, existing_student_count_in_family)
    self.registration_fee_in_cents = school_year.registration_fee_in_cents
    self.book_charge_in_cents = school_year.book_charge_in_cents
    calculate_tuition school_year, grade, existing_student_count_in_family
  end

  def calculate_tuition(school_year, grade, existing_student_count_in_family)
    if Date.today <= school_year.pre_registration_end_date
      self.pre_registration = true
      self.tuition_in_cents = school_year.pre_registration_tuition_in_cents
    else
      self.tuition_in_cents = school_year.tuition_in_cents
    end
    apply_pre_k_discount school_year, grade
    apply_multiple_child_discount school_year, existing_student_count_in_family
  end

  def apply_pre_k_discount(school_year, grade)
    if Grade::GRADE_PRESCHOOL == grade
      self.pre_k_discount = true
      self.tuition_in_cents -= school_year.tuition_discount_for_pre_k_in_cents
    end
  end

  def apply_multiple_child_discount(school_year, existing_student_count_in_family)
    if existing_student_count_in_family >= 2
      self.multiple_child_discount = true
      self.tuition_in_cents -= school_year.tuition_discount_for_three_or_more_child_in_cents
    end
  end
end
