class RefundRequestDetail < ActiveRecord::Base
  attr_accessible :book_charge_in_cents, :refund_request_id, :registration_fee_in_cents, :student_id, :tuition_in_cents

  belongs_to :refund_request
  belongs_to :student, class_name: 'Person', foreign_key: 'student_id'

  def total_in_cents
    self.registration_fee_in_cents + self.book_charge_in_cents + self.tuition_in_cents
  end

  def total
    self.total_in_cents / 100.0
  end

  def book_charge
    self.book_charge_in_cents / 100.0
  end

  def registration_fee
    self.registration_fee_in_cents / 100.0
  end

  def tuition
    self.tuition_in_cents / 100.0
  end
end
