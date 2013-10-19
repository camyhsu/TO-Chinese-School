class CreateStudentFeePayments < ActiveRecord::Migration
  def self.up
    create_table :student_fee_payments do |t|
      t.integer :registration_payment_id
      t.integer :student_id
      t.integer :registration_fee_in_cents
      t.integer :tuition_in_cents
      t.integer :book_charge_in_cents
      t.boolean :pre_registration, :null => false, :default => false
      t.boolean :multiple_child_discount, :null => false, :default => false
      t.boolean :pre_k_discount, :null => false, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :student_fee_payments
  end
end
