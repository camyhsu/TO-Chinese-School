class CreateWithdrawRequests < ActiveRecord::Migration
  def change
    create_table :withdraw_requests do |t|
      t.integer :request_by_id
      t.string :request_by_name
      t.string :request_by_address
      t.integer :school_year_id
      t.integer :refund_pva_due_in_cents
      t.integer :refund_ccca_due_in_cents
      t.integer :refund_grand_total_in_cents
      t.string :status_code
      t.integer :status_by_id

      t.timestamps
    end
  end
end
