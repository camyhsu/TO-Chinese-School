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

  def active_grade_classes(school_year = SchoolYear.current_school_year)
    self.school_classes.reject { |school_class| !school_class.active_in?(school_year) }
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

  def find_next_assignable_school_class(school_class_type, school_year)
    assignable_school_classes = self.active_grade_classes(school_year).select { |active_school_class| active_school_class.school_class_type == school_class_type }
    return nil if assignable_school_classes.empty?
    return assignable_school_classes[0] if assignable_school_classes.size == 1
    # If there are more than one school class assignable, but the school has not started yet, don't assign automatically
    return nil unless school_year.school_has_started?
    pick_school_class_with_lowest_head_count_from assignable_school_classes, school_year
  end
  
  def find_available_school_class_types(school_year)
    school_class_types = self.active_grade_classes(school_year).collect { |active_school_class| active_school_class.school_class_type }
    school_class_types.uniq.compact.sort
  end
  
  def active_grade_classes_full?(school_year)
    
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
  
  
  private
  
  def pick_school_class_with_lowest_head_count_from(school_classes, school_year)
    current_school_class_picked = school_classes.shift
    current_lowest_head_count = current_school_class_picked.class_size school_year
    school_classes.each do |school_class|
      if school_class.class_size < current_lowest_head_count
        current_school_class_picked = school_class
        current_lowest_head_count = current_school_class_picked.class_size school_year
      end
    end
  end
end
