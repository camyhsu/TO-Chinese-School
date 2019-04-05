FactoryGirl.define do
  factory :withdraw_request_detail do
    withdraw_request_id 1
    student_id 1
    refund_registration_fee_in_cents 1
    refund_tuition_in_cents 1
    refund_book_charge_in_cents 1
  end
end
