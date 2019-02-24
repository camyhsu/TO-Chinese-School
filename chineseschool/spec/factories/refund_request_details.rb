FactoryGirl.define do
  factory :refund_request_detail do
    refund_request_id 1
    student_id 1
    registration_fee_in_cents 1
    tuition_in_cents 1
    book_charge_in_cents 1
  end
end
