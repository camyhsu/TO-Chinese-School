class WithdrawRequest < ActiveRecord::Base
  attr_accessible :cancelled, :approved, :approved_by_id, :refund_ccca_due_in_cents, :refund_grand_total_in_cents, :refund_pva_due_in_cents, :request_by_address, :request_by_id, :request_by_name, :school_year_id

  has_many :withdraw_request_details, dependent: :destroy

  belongs_to :request_by, class_name: 'Person', foreign_key: 'request_by_id'
  belongs_to :school_year, class_name: 'SchoolYear', foreign_key: 'school_year_id'

  validates :request_by_address, :request_by_name, presence: true

  def caculate_refund_grand_total_in_cents
    self.refund_grand_total_in_cents = self.refund_pva_due_in_cents + self.refund_ccca_due_in_cents
    self.withdraw_request_details.each do |withdraw_request_detail|
      self.refund_grand_total_in_cents = self.refund_grand_total_in_cents + withdraw_request_detail.refund_total_in_cents
    end
  end

  def refund_grand_total
    self.refund_grand_total_in_cents / 100.0
  end

  def refund_ccca_due
    self.refund_ccca_due_in_cents / 100.0
  end

  def refund_pva_due
    self.refund_pva_due_in_cents / 100.0
  end

  def self.find_withdraw_request_as_parent_in(school_year, person_id)
    WithdrawRequest.all :conditions => ["school_year_id = ? and request_by_id = ? ", school_year.id, person_id], :order => 'updated_at DESC'
  end

  def self.has_withdraw_request_as_parent_in?(school_year, person_id)
    WithdrawRequest.count(
        :conditions => ["school_year_id = ? and request_by_id = ? ", school_year.id, person_id]) > 0
  end

  def status
    return 'Cancelled' if self.cancelled?
    return 'Approved' if self.approved?
    return 'Pending for Approval'
  end

end
