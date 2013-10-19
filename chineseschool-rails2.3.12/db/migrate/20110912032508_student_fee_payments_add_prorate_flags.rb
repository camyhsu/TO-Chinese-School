class StudentFeePaymentsAddProrateFlags < ActiveRecord::Migration
  def self.up
    add_column :student_fee_payments, :prorate_75, :boolean, :null => false, :default => false
    add_column :student_fee_payments, :prorate_50, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :student_fee_payments, :prorate_50
    remove_column :student_fee_payments, :prorate_75
  end
end
