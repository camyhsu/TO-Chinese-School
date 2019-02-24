FactoryGirl.define do
  factory :withdraw_request do
    request_by_id 1
    request_by_name "MyString"
    request_by_address "MyString"
    school_year_id 1
    refund_pva_due_in_cents 1
    refund_ccca_due_in_cents 1
    refund_grand_total_in_cents 1
    approved false
    approved_by_id 1
  end
end
