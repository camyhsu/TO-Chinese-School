class CreateRefundRequestDetails < ActiveRecord::Migration
  def change
    create_table :refund_request_details do |t|
      t.integer :refund_request_id
      t.integer :student_id
      t.integer :registration_fee_in_cents
      t.integer :tuition_in_cents
      t.integer :book_charge_in_cents

      t.timestamps
    end
  end
end
