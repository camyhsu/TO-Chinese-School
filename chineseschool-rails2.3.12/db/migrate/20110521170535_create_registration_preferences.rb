class CreateRegistrationPreferences < ActiveRecord::Migration
  def self.up
    create_table :registration_preferences do |t|
      t.integer :school_year_id
      t.integer :student_id
      t.integer :entered_by_id
      t.integer :previous_grade_id
      t.integer :grade_id
      t.string :school_class_type
      t.integer :elective_class_id
      t.boolean :registration_completed, :null => false, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :registration_preferences
  end
end
