class RegistrationPreference < ActiveRecord::Base
  
  belongs_to :school_year
  belongs_to :student, class_name: 'Person', foreign_key: 'student_id'
  belongs_to :entered_by, class_name: 'Person', foreign_key: 'entered_by_id'
  belongs_to :previous_grade, class_name: 'Grade', foreign_key: 'previous_grade_id'
  belongs_to :grade
  belongs_to :elective_class, class_name: 'SchoolClass', foreign_key: 'elective_class_id'

  validates :school_year, :student, :entered_by, presence: true
  
  def grade_full?
    self.grade.active_grade_classes_full?(self.school_year)
  end
  
  def full_for?(school_class_type)
    active_grade_classes = self.grade.active_grade_classes(self.school_year)
    allowed_max_student_count = 0
    school_class_type_class_ids = []
    active_grade_classes.each do |grade_class|
      if grade_class.school_class_type == school_class_type
        allowed_max_student_count += grade_class.max_size
        school_class_type_class_ids << grade_class.id
      end
    end
    
    class_assigned_student_count = StudentClassAssignment.count_by_sql("SELECT COUNT(1) FROM student_class_assignments WHERE school_year_id = #{self.school_year.id} AND school_class_id IN (#{school_class_type_class_ids.join(',')})")
    unassigned_student_count = StudentClassAssignment.count_by_sql("SELECT COUNT(1) FROM student_class_assignments sca, registration_preferences rp WHERE sca.school_year_id = #{self.school_year.id} AND sca.grade_id = #{self.grade_id} AND sca.school_class_id IS NULL AND sca.student_id = rp.student_id AND rp.school_year_id = #{self.school_year.id} AND rp.school_class_type = '#{school_class_type}'")
    
    (class_assigned_student_count + unassigned_student_count) >= allowed_max_student_count
  end
end
