class CreateManualTransactions < ActiveRecord::Migration
  def self.up
    create_table :manual_transactions do |t|
      t.integer :student_id
      t.integer :transaction_by_id
      t.integer :amount_in_cents, :null => false, :default => 0
      t.string :transaction_type
      t.date :transaction_date
      t.string :payment_method
      t.string :check_number
      t.text :note

      t.timestamps
    end
  end

  def self.down
    drop_table :manual_transactions
  end
end
