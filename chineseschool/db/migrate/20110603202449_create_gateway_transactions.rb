class CreateGatewayTransactions < ActiveRecord::Migration
  def self.up
    create_table :gateway_transactions do |t|
      t.integer :registration_payment_id
      t.integer :amount_in_cents
      t.string :credit_card_type
      t.string :credit_card_last_digits
      t.string :approval_status
      t.string :error_message
      t.string :approval_code
      t.string :reference_number
      t.boolean :credit, :null => false, :default => false
      t.text :response_dump

      t.timestamps
    end
  end

  def self.down
    drop_table :gateway_transactions
  end
end
