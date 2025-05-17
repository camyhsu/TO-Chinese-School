class StudentClassAssignment < ActiveRecord::Base

  belongs_to :school_year
  belongs_to :student, class_name: 'Person', foreign_key: 'student_id'
  belongs_to :grade
  belongs_to :school_class
  belongs_to :elective_class, class_name: 'SchoolClass', foreign_key: 'elective_class_id'

  validates :student, :grade, :school_year, presence: true

  def set_school_class_based_on(registration_preference)
    if registration_preference.school_class_type == SchoolClass::SCHOOL_CLASS_TYPE_EVERYDAYCHINESE
      self.school_class = StudentClassAssignment.find_ec_class_base_on_previous_ec_class_count registration_preference.student
    else
      self.school_class = self.grade.find_next_assignable_school_class registration_preference.school_class_type, self.school_year, self.student.gender
    end
  end

  # if EC record >= 4, then set to Advanced, if 2<= count < 4, then set to Middle, else set to Primary
  def self.find_ec_class_base_on_previous_ec_class_count(student)
    previous_ec_class_count = StudentClassAssignment.find_previous_ec_class_count student
    if previous_ec_class_count >= 4
      return SchoolClass.first :conditions => ["id = 125"]
    elsif previous_ec_class_count >=2
      return SchoolClass.first :conditions => ["id = 113"]
    else
      return SchoolClass.first :conditions => ["id = 108"]
    end
  end

  def self.find_previous_ec_class_count(student)
    previous_ec_class_count =
        StudentClassAssignment.count_by_sql("SELECT COUNT(DISTINCT (school_class_id, grade_id)) FROM student_class_assignments WHERE student_id = #{student.id} AND school_class_id IN (108,109,113,120,125)")
    previous_ec_class_count
  end

end
