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
  
  def fill_in_tuition_and_fee(school_year, grade, paid_and_pending_student_fee_payments)
    self.registration_fee_in_cents = school_year.registration_fee_in_cents
    self.book_charge_in_cents = BookCharge.book_charge_in_cents_for school_year, grade
    calculate_tuition school_year, grade, paid_and_pending_student_fee_payments
  end

  def calculate_tuition(school_year, grade, paid_and_pending_student_fee_payments)
    if PacificDate.today <= school_year.early_registration_end_date
      self.early_registration = true
      self.tuition_in_cents = school_year.early_registration_tuition_in_cents
    else
      self.tuition_in_cents = school_year.tuition_in_cents
    end
    apply_pre_k_discount school_year, grade
    apply_multiple_child_discount school_year, paid_and_pending_student_fee_payments.size
    apply_late_registration_prorate school_year
    apply_staff_and_instructor_discount school_year, paid_and_pending_student_fee_payments
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
    # as of 2017-2018 school year, registration_50_percent_date is no longer used
    if PacificDate.today > school_year.registration_75_percent_date
      self.prorate_75 = true
      self.tuition_in_cents = (self.tuition_in_cents * 0.75).to_i
    end
  end

  def apply_staff_and_instructor_discount(school_year, paid_and_pending_student_fee_payments)
    student_families = self.student.find_families_as_child
    if student_families.any? {|family| family.has_staff_for? school_year}
      # Only one tuition discount for staff
      unless paid_and_pending_student_fee_payments.any? {|student_fee_payment| student_fee_payment.staff_discount?}
        self.staff_discount = true
        self.tuition_in_cents = 0
      end
    else
      # if a family has both staff and instructor, only the staff discount applies
      # hence, we only need to check for instructor in the family if there is no staff in the family
      if student_families.any? {|family| family.has_instructor_for? school_year}
        number_of_instructor_discount_already_applied = 0
        paid_and_pending_student_fee_payments.each do |student_fee_payment|
          number_of_instructor_discount_already_applied += 1 if student_fee_payment.instructor_discount?
        end
        if number_of_instructor_discount_already_applied < 2
          self.instructor_discount = true
          self.tuition_in_cents -= school_year.tuition_discount_for_instructor_in_cents
        end
      end
    end
  end
end
