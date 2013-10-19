class StudentClassAssignmentsAddSchoolYearIdColumn < ActiveRecord::Migration
  def self.up
    add_column :student_class_assignments, :school_year_id, :integer
    add_index :student_class_assignments, :school_year_id

    StudentClassAssignment.update_all "school_year_id = #{SchoolYear.current_school_year.id}"
  end

  def self.down
    remove_index :student_class_assignments, :school_year_id
    remove_column :student_class_assignments, :school_year_id
  end
end
