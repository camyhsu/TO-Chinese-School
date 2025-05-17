class AddElectiveClassFeeInCentsToStudentFeePayments < ActiveRecord::Migration
  def change
    add_column :student_fee_payments, :elective_class_fee_in_cents, :integer, null: false, default: 0
  end
end
