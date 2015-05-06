class SchoolYear < ActiveRecord::Base

  TRACK_EVENT_DATE = Date.parse('2015-03-28')
  TRACK_EVENT_SIGN_UP_PREVIEW_START_DATE = Date.parse('2015-01-23')
  TRACK_EVENT_SIGN_UP_START_DATE = Date.parse('2015-01-31')
  TRACK_EVENT_SIGN_UP_END_DATE = Date.parse('2015-03-01')

  attr_accessible :name, :description, :start_date, :end_date, :age_cutoff_month, :registration_fee,
                  :early_registration_tuition, :tuition, :tuition_discount_for_three_or_more_child,
                  :tuition_discount_for_pre_k, :pva_membership_due, :ccca_membership_due,
                  :early_registration_start_date, :early_registration_end_date, :registration_start_date,
                  :registration_75_percent_date, :registration_50_percent_date, :registration_end_date,
                  :refund_75_percent_date, :refund_50_percent_date, :refund_25_percent_date, :refund_end_date

  belongs_to :previous_school_year, class_name: 'SchoolYear', foreign_key: 'previous_school_year_id'

  validates :name, :start_date, :end_date, :age_cutoff_month,
            :early_registration_start_date, :early_registration_end_date, :registration_start_date,
            :registration_75_percent_date, :registration_50_percent_date, :registration_end_date,
            :refund_75_percent_date, :refund_50_percent_date, :refund_25_percent_date, :refund_end_date,
            :registration_fee_in_cents, :early_registration_tuition_in_cents, :tuition_in_cents,
            :tuition_discount_for_three_or_more_child_in_cents, :tuition_discount_for_pre_k_in_cents,
            :pva_membership_due_in_cents, :ccca_membership_due_in_cents, :previous_school_year,
            presence: true

  validates :registration_fee_in_cents, numericality: {only_integer: true, greater_than: 0, allow_nil: false}
  validates :early_registration_tuition_in_cents, numericality: {only_integer: true, greater_than: 0, allow_nil: false}
  validates :tuition_in_cents, numericality: {only_integer: true, greater_than: 0, allow_nil: false}
  validates :tuition_discount_for_three_or_more_child_in_cents, numericality: {only_integer: true, greater_than: 0, allow_nil: false}
  validates :tuition_discount_for_pre_k_in_cents, numericality: {only_integer: true, greater_than_or_equal_to: 0, allow_nil: false}
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
    active_registration_years = self.all :conditions => ['early_registration_start_date <= ? AND registration_end_date >= ?', PacificDate.today, PacificDate.today], :order => 'start_date ASC'
    active_registration_years.reject { |school_year| (school_year.early_registration_end_date < PacificDate.today) && (school_year.registration_start_date > PacificDate.today) }
  end
  
  def school_has_started?
    PacificDate.today >= self.start_date
  end

  def start_year
    self.start_date.year
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
