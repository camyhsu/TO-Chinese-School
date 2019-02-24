class RefundRequest < ActiveRecord::Base
  attr_accessible :approved, :approved_by_id, :ccca_due_in_cents, :grand_total_in_cents, :pva_due_in_cents, :request_by_address, :request_by_id, :request_by_name, :school_year_id

  has_many :refund_request_details, dependent: :destroy
  belongs_to :request_by, class_name: 'Person', foreign_key: 'request_by_id'
  belongs_to :school_year, class_name: 'SchoolYear', foreign_key: 'school_year_id'

  validates :request_by_address, :request_by_name, presence: true

  def caculate_grand_total_in_cents
    self.grand_total_in_cents = self.pva_due_in_cents + self.ccca_due_in_cents
    self.refund_request_details.each do |refund_request_detail|
      self.grand_total_in_cents = self.grand_total_in_cents + refund_request_detail.total_in_cents
    end
  end

  def grand_total
    self.grand_total_in_cents / 100.0
  end

  def ccca_due
    self.ccca_due_in_cents / 100.0
  end

  def pva_due
    self.pva_due_in_cents / 100.0
  end

end
