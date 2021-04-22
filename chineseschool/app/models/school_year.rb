class SchoolYear < ActiveRecord::Base

  TRACK_EVENT_DATE = Date.parse('2018-03-17')
  TRACK_EVENT_SIGN_UP_PREVIEW_START_DATE = Date.parse('2018-01-20')
  TRACK_EVENT_SIGN_UP_START_DATE = Date.parse('2018-01-27')
  TRACK_EVENT_SIGN_UP_END_DATE = Date.parse('2018-03-04')

  STUDENT_FINAL_MARK_DEADLINE = Date.parse('2020-05-20')

  # as of 2017-2018 school year
  # :registration_50_percent_date, :refund_75_percent_date, :refund_25_percent_date are no longer used
  # :refund_90_percent_date is added

  attr_accessible :name, :description, :start_date, :end_date, :age_cutoff_month, :registration_fee,
                  :early_registration_tuition, :tuition, :tuition_discount_for_three_or_more_child,
                  :tuition_discount_for_pre_k, :tuition_discount_for_instructor, :pva_membership_due, :ccca_membership_due,
                  :early_registration_start_date, :early_registration_end_date, :registration_start_date,
                  :registration_75_percent_date, :registration_end_date,
                  :refund_90_percent_date, :refund_50_percent_date, :refund_end_date

  belongs_to :previous_school_year, class_name: 'SchoolYear', foreign_key: 'previous_school_year_id'

  validates :name, :start_date, :end_date, :age_cutoff_month,
            :early_registration_start_date, :early_registration_end_date, :registration_start_date,
            :registration_75_percent_date, :registration_end_date,
            :refund_90_percent_date, :refund_50_percent_date, :refund_end_date,
            :registration_fee_in_cents, :early_registration_tuition_in_cents, :tuition_in_cents,
            :tuition_discount_for_three_or_more_child_in_cents, :tuition_discount_for_pre_k_in_cents,
            :tuition_discount_for_instructor_in_cents,
            :pva_membership_due_in_cents, :ccca_membership_due_in_cents, :previous_school_year,
            presence: true

  validates :registration_fee_in_cents, numericality: {only_integer: true, greater_than: 0, allow_nil: false}
  validates :early_registration_tuition_in_cents, numericality: {only_integer: true, greater_than: 0, allow_nil: false}
  validates :tuition_in_cents, numericality: {only_integer: true, greater_than: 0, allow_nil: false}
  validates :tuition_discount_for_three_or_more_child_in_cents, numericality: {only_integer: true, greater_than: 0, allow_nil: false}
  validates :tuition_discount_for_pre_k_in_cents, numericality: {only_integer: true, greater_than_or_equal_to: 0, allow_nil: false}
  validates :tuition_discount_for_instructor_in_cents, numericality: {only_integer: true, greater_than_or_equal_to: 0, allow_nil: false}
  validates :pva_membership_due_in_cents, numericality: {only_integer: true, greater_than: 0, allow_nil: false}
  validates :ccca_membership_due_in_cents, numericality: {only_integer: true, greater_than: 0, allow_nil: false}

  validate :date_order

  def registration_fee
    self.registration_fee_in_cents / 100.0
  end

  def registration_fee=(registration_fee)
    self.registration_fee_in_cents = (registration_fee * 100).to_i
  end

  def early_registration_tuition
    self.early_registration_tuition_in_cents / 100.0
  end

  def early_registration_tuition=(early_registration_tuition)
    self.early_registration_tuition_in_cents = (early_registration_tuition * 100).to_i
  end

  def tuition
    self.tuition_in_cents / 100.0
  end

  def tuition=(tuition)
    self.tuition_in_cents = (tuition * 100).to_i
  end

  def tuition_discount_for_three_or_more_child
    self.tuition_discount_for_three_or_more_child_in_cents / 100.0
  end

  def tuition_discount_for_three_or_more_child=(tuition_discount_for_three_or_more_child)
    self.tuition_discount_for_three_or_more_child_in_cents = (tuition_discount_for_three_or_more_child * 100).to_i
  end

  def tuition_discount_for_pre_k
    self.tuition_discount_for_pre_k_in_cents / 100.0
  end

  def tuition_discount_for_pre_k=(tuition_discount_for_pre_k)
    self.tuition_discount_for_pre_k_in_cents = (tuition_discount_for_pre_k * 100).to_i
  end

  def tuition_discount_for_instructor
    self.tuition_discount_for_instructor_in_cents / 100.0
  end

  def tuition_discount_for_instructor=(tuition_discount_for_instructor)
    self.tuition_discount_for_instructor_in_cents = (tuition_discount_for_instructor * 100).to_i
  end

  def pva_membership_due
    self.pva_membership_due_in_cents / 100.0
  end

  def pva_membership_due=(pva_membership_due)
    self.pva_membership_due_in_cents = (pva_membership_due * 100).to_i
  end

  def ccca_membership_due
    self.ccca_membership_due_in_cents / 100.0
  end

  def ccca_membership_due=(ccca_membership_due)
    self.ccca_membership_due_in_cents = (ccca_membership_due * 100).to_i
  end
  
  def wire_up_previous_school_year
    self.previous_school_year = SchoolYear.first :conditions => ["end_date <= ?", self.start_date], :order => 'end_date DESC'
  end

  def tuition_in_cents_refund_due(paid_student_fee_payment)
    if !self.school_has_started?
      tuition_in_cents_refund = paid_student_fee_payment.tuition_in_cents
    elsif !self.refund_end_date && PacificDate.today > self.refund_end_date
      tuition_in_cents_refund = 0
    elsif !self.refund_25_percent_date.nil? && PacificDate.today > self.refund_25_percent_date
      tuition_in_cents_refund = paid_student_fee_payment.tuition_in_cents * 0.25
    elsif !self.refund_50_percent_date.nil? && PacificDate.today > self.refund_50_percent_date
      tuition_in_cents_refund = paid_student_fee_payment.tuition_in_cents * 0.5
    elsif !self.refund_75_percent_date.nil? && PacificDate.today > self.refund_75_percent_date
      tuition_in_cents_refund = paid_student_fee_payment.tuition_in_cents * 0.75
    elsif !self.refund_90_percent_date.nil? && PacificDate.today > self.refund_90_percent_date
      tuition_in_cents_refund = paid_student_fee_payment.tuition_in_cents * 0.9
    else
      tuition_in_cents_refund = paid_student_fee_payment.tuition_in_cents
    end
    tuition_in_cents_refund
  end


  def pva_in_cents_refund_due(pva_fee_refund_in_cents)
    if !self.school_has_started?
      pva_in_cents_refund = pva_fee_refund_in_cents
    elsif !self.refund_end_date && PacificDate.today > self.refund_end_date
      pva_in_cents_refund = 0
    elsif !self.refund_25_percent_date.nil? && PacificDate.today > self.refund_25_percent_date
      pva_in_cents_refund = pva_fee_refund_in_cents * 0.25
    elsif !self.refund_50_percent_date.nil? && PacificDate.today > self.refund_50_percent_date
      pva_in_cents_refund = pva_fee_refund_in_cents * 0.5
    elsif !self.refund_75_percent_date.nil? && PacificDate.today > self.refund_75_percent_date
      pva_in_cents_refund = pva_fee_refund_in_cents * 0.75
    elsif !self.refund_90_percent_date.nil? && PacificDate.today > self.refund_90_percent_date
      pva_in_cents_refund = pva_fee_refund_in_cents * 0.9
    else
      pva_in_cents_refund = pva_fee_refund_in_cents
    end
    pva_in_cents_refund
  end

  def self.current_school_year
    self.find_current_and_future_school_years[0]
  end

  def self.next_school_year
    self.find_current_and_future_school_years[1]
  end
  
  def self.find_current_and_future_school_years
    self.all :conditions => ["end_date >= ?", PacificDate.today], :order => 'start_date ASC'
  end

  def self.find_active_registration_school_years
    self.all :conditions => ['early_registration_start_date <= ? AND registration_end_date >= ?', PacificDate.today, PacificDate.today], :order => 'start_date ASC'
  end

  def self.find_active_refund_school_years
    self.all :conditions => ['refund_end_date > ?', PacificDate.today], :order => 'start_date ASC'
  end
  
  def school_has_started?
    PacificDate.today >= self.start_date
  end

  def school_will_start_tomorrow?
    PacificDate.tomorrow >= self.start_date
  end

  def start_year
    self.start_date.year
  end

  def start_date_for_entering_student_final_mark
    # this is currently always May 1st of the school year
    Date.new(self.end_date.year, 5, 1)
  end

  private

  def date_order
    validate_start_end_date_order
    #validate_registration_date_order
    #validate_refund_date_order
  end

  def validate_start_end_date_order
    validate_date_in_order :start_date, :end_date
  end

  def validate_date_in_order(earlier_date_symbol, later_date_symbol)
    earlier_date = self.send earlier_date_symbol
    later_date = self.send later_date_symbol
    return if earlier_date.nil? or later_date.nil?
    if earlier_date > later_date
      errors.add(earlier_date_symbol, " can not be later than #{later_date_symbol.to_s.humanize}")
    end
  end
end
