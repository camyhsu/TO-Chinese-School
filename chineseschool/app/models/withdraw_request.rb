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
end
