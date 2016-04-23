class AddInstructorTuitionDiscount < ActiveRecord::Migration
  def change
    add_column :school_years, :tuition_discount_for_instructor_in_cents, :integer, null: false, default: 0
    change_table :student_fee_payments do |t|
      t.boolean :instructor_discount, null: false, default: false
      t.boolean :staff_discount, null: false, default: false
    end
  end
end
