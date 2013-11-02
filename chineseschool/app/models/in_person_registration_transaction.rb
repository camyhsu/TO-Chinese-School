class InPersonRegistrationTransaction < ActiveRecord::Base

  PAYMENT_METHOD_CHECK = 'Check'
  PAYMENT_METHOD_CASH = 'Cash'
  PAYMENT_METHODS = [PAYMENT_METHOD_CHECK, PAYMENT_METHOD_CASH]

  belongs_to :registration_payment
  belongs_to :recorded_by, class_name: 'Person', foreign_key: 'recorded_by_id'

  validates :registration_payment, :recorded_by, :payment_method, presence: true
  validates :check_number, presence: true, if: Proc.new { |transaction| transaction.payment_method == PAYMENT_METHOD_CHECK }

end
