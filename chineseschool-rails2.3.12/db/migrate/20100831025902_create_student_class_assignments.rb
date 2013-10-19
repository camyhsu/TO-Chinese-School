class CreateStudentClassAssignments < ActiveRecord::Migration
  def self.up
    create_table :student_class_assignments do |t|
      t.integer :student_id
      t.integer :grade_id
      t.integer :school_class_id
      t.integer :elective_class_id

      t.timestamps
    end
  end

  def self.down
    drop_table :student_class_assignments
  end
end
