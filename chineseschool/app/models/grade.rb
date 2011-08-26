class Grade < ActiveRecord::Base

  GRADE_PRESCHOOL = self.find_by_short_name 'Pre'

  belongs_to :next_grade, :class_name => 'Grade', :foreign_key => 'next_grade'
  has_one :previous_grade, :class_name => 'Grade', :foreign_key => 'next_grade'

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

  def has_active_school_classes_in?(school_year)
    SchoolClassActiveFlag.count(
        :conditions => ["active = true AND school_year_id = ? AND school_class_id = school_classes.id AND school_classes.grade_id = ?", school_year.id, self.id],
        :include => :school_class) > 0
  end

  def snap_down_to_first_active_grade(school_year)
    snapped_grade = self
    snapped_grade = snapped_grade.previous_grade until snapped_grade.has_active_school_classes_in? school_year
    snapped_grade
  end

  def below_first_grade?
    # Assuming only PreK and K are below first grade without checking the whole chain
    return true if GRADE_PRESCHOOL == self or GRADE_PRESCHOOL.next_grade == self
    false
  end

  def find_english_instruction_school_class
    self.school_classes.first :conditions => "short_name like '%C'"
  end

  def find_traditional_school_class
    self.school_classes.first :conditions => "short_name like '%A'"
  end

  def find_default_simplified_school_class
    self.school_classes.first :conditions => "short_name like '%B'"
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
  
  def self.find_by_school_age_without_prek(school_age)
    return nil if school_age < 5
    # Currently defined lowest grade is PreK for age 4
    grade = GRADE_PRESCHOOL
    # Skip PreK grade
    grade = grade.next_grade unless grade.nil?
    (school_age - 5).times do
      grade = grade.next_grade unless grade.nil?
    end
    grade
  end
end
