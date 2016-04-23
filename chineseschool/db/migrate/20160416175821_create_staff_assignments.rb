class CreateStaffAssignments < ActiveRecord::Migration
  def change
    create_table :staff_assignments do |t|
      t.integer :school_year_id, null: false
      t.integer :person_id, null: false
      t.string :role
      t.date :start_date
      t.date :end_date

      t.timestamps
    end
  end
end
