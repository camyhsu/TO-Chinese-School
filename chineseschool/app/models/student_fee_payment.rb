class StudentFeePayment < ActiveRecord::Base

  belongs_to :registration_payment
  belongs_to :student, class_name: 'Person', foreign_key: 'student_id'

  validates :registration_payment, :student, :registration_fee_in_cents, :tuition_in_cents, :book_charge_in_cents, presence: true

  validates :registration_fee_in_cents, numericality: {only_integer: true, allow_nil: false}
  validates :tuition_in_cents, numericality: {only_integer: true, allow_nil: false}
  validates :book_charge_in_cents, numericality: {only_integer: true, allow_nil: false}


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
  
  def fill_in_tuition_and_fee(school_year, grade, registration_count_before_this_student)
    self.registration_fee_in_cents = school_year.registration_fee_in_cents
    self.book_charge_in_cents = BookCharge.book_charge_in_cents_for school_year, grade
    calculate_tuition school_year, grade, registration_count_before_this_student
  end

  def calculate_tuition(school_year, grade, registration_count_before_this_student)
    if PacificDate.today <= school_year.pre_registration_end_date
      self.pre_registration = true
      self.tuition_in_cents = school_year.pre_registration_tuition_in_cents
    else
      self.tuition_in_cents = school_year.tuition_in_cents
    end
    apply_pre_k_discount school_year, grade
    apply_multiple_child_discount school_year, registration_count_before_this_student
    apply_late_registration_prorate school_year
  end

  def apply_pre_k_discount(school_year, grade)
    if Grade.grade_preschool == grade
      self.pre_k_discount = true
      self.tuition_in_cents -= school_year.tuition_discount_for_pre_k_in_cents
    end
  end

  def apply_multiple_child_discount(school_year, registration_count_before_this_student)
    if registration_count_before_this_student >= 2
      self.multiple_child_discount = true
      self.tuition_in_cents -= school_year.tuition_discount_for_three_or_more_child_in_cents
    end
  end
  
  def apply_late_registration_prorate(school_year)
    if PacificDate.today > school_year.registration_50_percent_date
      self.prorate_50 = true
      self.tuition_in_cents = (self.tuition_in_cents * 0.5).to_i
    elsif PacificDate.today > school_year.registration_75_percent_date
      self.prorate_75 = true
      self.tuition_in_cents = (self.tuition_in_cents * 0.75).to_i
    end
  end
end
