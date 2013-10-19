class CreateInstructorAssignments < ActiveRecord::Migration
  def self.up
    create_table :instructor_assignments do |t|
      t.integer :school_year_id
      t.integer :school_class_id
      t.integer :instructor_id
      t.date :start_date
      t.date :end_date
      t.boolean :primary, :default => true
      t.boolean :assistant, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :instructor_assignments
  end
end
