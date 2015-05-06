class SchoolYearAddEarlyRegistrationDate < ActiveRecord::Migration
  def change
    change_table :school_years do |t|
      t.date :early_registration_start_date
      t.rename :pre_registration_end_date, :early_registration_end_date
      t.rename :pre_registration_tuition_in_cents, :early_registration_tuition_in_cents
    end
    change_table :student_fee_payments do |t|
      t.rename :pre_registration, :early_registration
    end
  end
end
