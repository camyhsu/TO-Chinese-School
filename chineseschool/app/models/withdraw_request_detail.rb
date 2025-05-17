class WithdrawRequestDetail < ActiveRecord::Base
  attr_accessible :refund_book_charge_in_cents, :refund_registration_fee_in_cents, :refund_tuition_in_cents, :student_id,
                  :withdraw_request_id, :elective_class_fee_in_cents, :elective_class_only

  belongs_to :withdraw_request
  belongs_to :student, class_name: 'Person', foreign_key: 'student_id'

  validates :student_id, presence: true

  def refund_total_in_cents
    self.refund_registration_fee_in_cents + self.refund_book_charge_in_cents + self.refund_tuition_in_cents + self.elective_class_fee_in_cents
  end

  def refund_total
    self.refund_total_in_cents / 100.0
  end

  def refund_book_charge
    self.refund_book_charge_in_cents / 100.0
  end

  def refund_registration_fee
    self.refund_registration_fee_in_cents / 100.0
  end

  def refund_tuition
    self.refund_tuition_in_cents / 100.0
  end

  def elective_class_fee
    self.elective_class_fee_in_cents / 100.0
  end
end
