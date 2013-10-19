class CreateRegistrationPayments < ActiveRecord::Migration
  def self.up
    create_table :registration_payments do |t|
      t.integer :school_year_id
      t.integer :paid_by_id
      t.integer :pva_due_in_cents
      t.integer :ccca_due_in_cents
      t.integer :grand_total_in_cents
      t.boolean :paid, :null => false, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :registration_payments
  end
end
