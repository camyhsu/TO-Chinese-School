class CreateRefundRequests < ActiveRecord::Migration
  def change
    create_table :refund_requests do |t|
      t.integer :request_by_id
      t.string :request_by_name
      t.string :request_by_address
      t.integer :school_year_id
      t.integer :pva_due_in_cents
      t.integer :ccca_due_in_cents
      t.integer :grand_total_in_cents
      t.boolean :approved
      t.integer :approved_by_id

      t.timestamps
    end
  end
end
