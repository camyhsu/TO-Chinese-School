class CreateWithdrawRequestDetails < ActiveRecord::Migration
  def change
    create_table :withdraw_request_details do |t|
      t.integer :withdraw_request_id
      t.integer :student_id
      t.integer :refund_registration_fee_in_cents
      t.integer :refund_tuition_in_cents
      t.integer :refund_book_charge_in_cents

      t.timestamps
    end
  end
end
