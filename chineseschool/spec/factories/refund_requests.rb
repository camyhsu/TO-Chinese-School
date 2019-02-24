FactoryGirl.define do
  factory :refund_request do
    request_by_id 1
    request_by_name "MyString"
    request_by_address "MyString"
    school_year_id 1
    pva_due_in_cents 1
    ccca_due_in_cents 1
    grand_total_in_cents 1
    approved false
    approved_by_id 1
  end
end
