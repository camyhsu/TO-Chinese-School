class Grade < ActiveRecord::Base

  GRADE_PRESCHOOL = self.find_by_short_name 'Pre'

  belongs_to :next_grade, :class_name => 'Grade', :foreign_key => 'next_grade'

  has_many :school_classes
  
  has_many :student_class_assignments
  has_many :students, :through => :student_class_assignments

  def name
    "#{self.chinese_name}(#{self.english_name})"
  end

  def current_year_student_class_assignments
    self.student_class_assignments.all :conditions => ['school_year_id = ?', SchoolYear.current_school_year.id]
  end

  def active_school_classes
    self.school_classes.reject { |school_class| !school_class.active_in?(SchoolYear.current_school_year) }
  end
  
  def self.find_by_school_age(school_age)
    return nil if school_age < 4
    # Currently defined lowest grade is PreK for age 4
    grade = GRADE_PRESCHOOL
    (school_age - 4).times do
      grade = grade.next_grade unless grade.nil?
    end
    grade
  end
end
