class SchoolYear < ActiveRecord::Base

  belongs_to :previous_school_year, :class_name => 'SchoolYear', :foreign_key => 'previous_school_year_id'

  validates_presence_of :name, :start_date, :end_date, :age_cutoff_month,
      :registration_start_date, :pre_registration_end_date, 
      :registration_75_percent_date, :registration_50_percent_date,
      :registration_end_date, :refund_75_percent_date,
      :refund_50_percent_date, :refund_25_percent_date,
      :refund_end_date, :registration_fee_in_cents,
      :pre_registration_tuition_in_cents, :tuition_in_cents,
      :tuition_discount_for_three_or_more_child_in_cents, :tuition_discount_for_pre_k_in_cents,
      :book_charge_in_cents, :pva_membership_due_in_cents, :ccca_membership_due_in_cents

  validates_numericality_of :registration_fee_in_cents, :only_integer => true, :greater_than => 0, :allow_nil => false
  validates_numericality_of :pre_registration_tuition_in_cents, :only_integer => true, :greater_than => 0, :allow_nil => false
  validates_numericality_of :tuition_in_cents, :only_integer => true, :greater_than => 0, :allow_nil => false
  validates_numericality_of :tuition_discount_for_three_or_more_child_in_cents, :only_integer => true, :greater_than => 0, :allow_nil => false
  validates_numericality_of :tuition_discount_for_pre_k_in_cents, :only_integer => true, :greater_than => 0, :allow_nil => false
  validates_numericality_of :book_charge_in_cents, :only_integer => true, :greater_than => 0, :allow_nil => false
  validates_numericality_of :pva_membership_due_in_cents, :only_integer => true, :greater_than => 0, :allow_nil => false
  validates_numericality_of :ccca_membership_due_in_cents, :only_integer => true, :greater_than => 0, :allow_nil => false

  validate :date_order

  def registration_fee
    self.registration_fee_in_cents / 100.0
  end

  def registration_fee=(registration_fee)
    self.registration_fee_in_cents = (registration_fee * 100).to_i
  end

  def pre_registration_tuition
    self.pre_registration_tuition_in_cents / 100.0
  end

  def pre_registration_tuition=(pre_registration_tuition)
    self.pre_registration_tuition_in_cents = (pre_registration_tuition * 100).to_i
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

  def book_charge
    self.book_charge_in_cents / 100.0
  end

  def book_charge=(book_charge)
    self.book_charge_in_cents = (book_charge * 100).to_i
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
    self.all :conditions => ['registration_start_date <= ? AND registration_end_date >= ?', PacificDate.today, PacificDate.today], :order => 'start_date ASC'
  end
  
  def school_has_started?
    PacificDate.today >= self.start_date
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
