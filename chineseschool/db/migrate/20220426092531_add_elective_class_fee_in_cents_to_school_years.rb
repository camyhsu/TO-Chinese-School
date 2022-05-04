class AddElectiveClassFeeInCentsToSchoolYears < ActiveRecord::Migration
  def change
    add_column :school_years, :elective_class_fee_in_cents, :integer, null: false, default: 5000
  end
end
