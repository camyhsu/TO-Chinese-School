class RegistrationPayment < ActiveRecord::Base

  belongs_to :school_year
  belongs_to :paid_by, :class_name => 'Person', :foreign_key => 'paid_by_id'
  has_many :student_fee_payments, :dependent => :destroy
  has_many :gateway_transactions
  has_one :in_person_registration_transaction

  validates_presence_of :school_year, :paid_by, :pva_due_in_cents, :ccca_due_in_cents

  validates_numericality_of :pva_due_in_cents, :only_integer => true, :allow_nil => false
  validates_numericality_of :ccca_due_in_cents, :only_integer => true, :allow_nil => false
  validates_numericality_of :grand_total_in_cents, :only_integer => true, :allow_nil => false


  def pva_due
    self.pva_due_in_cents / 100.0
  end

  def ccca_due
    self.ccca_due_in_cents / 100.0
  end

  def grand_total
    self.grand_total_in_cents / 100.0
  end
  
  def fill_in_due(completed_registration_count_in_family)
    self.pva_due_in_cents = calculate_pva_due_in_cents completed_registration_count_in_family
    self.ccca_due_in_cents = calculate_ccca_due_in_cents completed_registration_count_in_family
  end
  
  def calculate_grand_total
    self.grand_total_in_cents = self.pva_due_in_cents + self.ccca_due_in_cents
    self.student_fee_payments.each do |student_fee_payment|
      self.grand_total_in_cents = self.grand_total_in_cents + student_fee_payment.total_in_cents
    end
  end

  def find_first_approved_gateway_transaction
    self.gateway_transactions.first :conditions => ['approval_status = ?', GatewayTransaction::APPROVAL_STATUS_APPROVED]
  end

  def student_names
    self.student_fee_payments.collect { |fee_payment| fee_payment.student.name }
  end

  def self.find_paid_payments_paid_by(paid_by)
    self.all :conditions => ['paid_by_id = ? AND paid = true', paid_by.id], :order => 'updated_at DESC'
  end

  def self.find_paid_payments_for_school_year(school_year)
    self.all :conditions => ['school_year_id = ? AND paid = true', school_year.id], :order => 'updated_at DESC'
  end
  
  def self.find_paid_payments_for_date(date)
    self.all :conditions => ['paid = true AND updated_at >= ? AND updated_at < ?', PacificDate.start_time_utc_for(date), PacificDate.start_time_utc_for(date + 1)], :order => 'updated_at DESC'
  end

  def self.find_pending_payments_for(paid_by, school_year)
    self.all :conditions => ['paid_by_id = ? AND school_year_id = ? AND paid = false', paid_by.id, school_year.id], :order => 'updated_at DESC'
  end

  def self.find_pending_in_person_payments_for(school_year)
    self.all :conditions => ['school_year_id = ? AND paid = false AND request_in_person IS TRUE', school_year.id], :order => 'updated_at DESC'
  end

  
  private
  
  def calculate_pva_due_in_cents(completed_registration_count_in_family)
    # PVA membership due is up to 2 parents per family per school year
    return 0 if completed_registration_count_in_family > 1
    return self.school_year.pva_membership_due_in_cents if completed_registration_count_in_family == 1
    return self.school_year.pva_membership_due_in_cents if self.student_fee_payments.size < 2
    self.school_year.pva_membership_due_in_cents * 2
  end
  
  def calculate_ccca_due_in_cents(completed_registration_count_in_family)
    return 0 if completed_registration_count_in_family > 0
    return 0 if self.paid_by.families.detect { |family| family.ccca_lifetime_member? }
    self.school_year.ccca_membership_due_in_cents
  end
end
