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

  def has_active_grade_classes_in?(school_year)
    SchoolClassActiveFlag.count(
        :conditions => ["active = true AND school_year_id = ? AND school_class_id = school_classes.id AND school_classes.grade_id = ?", school_year.id, self.id],
        :include => :school_class) > 0
  end

  def snap_down_to_first_active_grade(school_year)
    snapped_grade = self
    snapped_grade = snapped_grade.previous_grade until snapped_grade.has_active_grade_classes_in? school_year
    snapped_grade
  end

  def below_first_grade?
    # Assuming only PreK and K are below first grade without checking the whole chain
    return true if GRADE_PRESCHOOL == self or GRADE_PRESCHOOL.next_grade == self
    false
  end

  def find_next_assignable_school_class(school_class_type, school_year, gender)
    assignable_school_classes = self.active_grade_classes(school_year).select { |active_school_class| active_school_class.school_class_type == school_class_type }
    return nil if assignable_school_classes.empty?
    return assignable_school_classes[0] if assignable_school_classes.size == 1
    # If there are more than one school class assignable, but the school has not started yet, don't assign automatically
    return nil unless school_year.school_has_started?
    pick_school_class_with_lowest_head_count_from assignable_school_classes, gender
  end
  
  def find_available_school_class_types(school_year)
    school_class_types = self.active_grade_classes(school_year).collect { |active_school_class| active_school_class.school_class_type }
    school_class_types.uniq.compact.sort
  end
  
  def active_grade_classes_full?(school_year)
    allowed_max_student_count = self.active_grade_classes(school_year).inject(0) { |memo, grade_class| memo + grade_class.max_size }
    StudentClassAssignment.count_by_sql("SELECT COUNT(1) FROM student_class_assignments WHERE grade_id = #{self.id} AND school_year_id = #{school_year.id}") >= allowed_max_student_count
  end
  
  def random_assign_grade_class(school_year)
    puts "#{Time.now} - Random assign grade class for Grade #{self.name}"
    class_type_to_classes = Hash.new { |hash, key| hash[key] = [] }
    self.active_grade_classes.each { |grade_class| class_type_to_classes[grade_class.school_class_type] << grade_class }
    
    class_assignments = self.student_class_assignments.all :conditions => ['school_year_id = ? AND school_class_id IS NULL', school_year.id]
    class_assignments.each do |class_assignment|
      student = class_assignment.student
      desired_class_type = student.registration_preference_for(school_year).school_class_type
      assignable_classes = class_type_to_classes[desired_class_type]
      if assignable_classes.empty?
        puts "ERROR - could not find assignable classes for student id => #{student.id} for class type <<#{desired_class_type}>>"
      else
        class_picked = pick_school_class_with_lowest_head_count_from assignable_classes, student.gender
        puts "Class picked for student id => #{student.id} is #{class_picked.name}"
        class_assignment.school_class = class_picked
        puts "ERROR - could not save school class assignment => #{class_assignment.id}" unless class_assignment.save
      end
    end
  end

  def assign_jersey_number_to_student
    students = self.current_year_student_class_assignments.collect { |student_class_assignment| student_class_assignment.student }
    max_number_assigned = JerseyNumber.find_max_number_assigned_in students
    sorted_student_class_assignments = current_year_student_class_assignments.sort do |x, y|
      class_order = x.school_class.short_name <=> y.school_class.short_name
      if class_order == 0
        last_name_order = x.student.english_last_name <=> y.student.english_last_name
        if last_name_order == 0
          x.student.english_first_name <=> y.student.english_first_name
        else
          last_name_order
        end
      else
        class_order
      end
    end
    sorted_student_class_assignments.each do |student_class_assignment|
      jersey_number = JerseyNumber.create_jersey_number_for student_class_assignment.student, self.jersey_number_prefix, max_number_assigned + 1
      max_number_assigned = jersey_number.number if max_number_assigned < jersey_number.number
    end
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
  
  def pick_school_class_with_lowest_head_count_from(school_classes, gender)
    return school_classes[0] if school_classes.size == 1
    current_school_class_picked = school_classes[0]
    current_lowest_head_count = current_school_class_picked.current_year_gender_based_class_size gender
    school_classes.each do |school_class|
      school_class_size = school_class.current_year_gender_based_class_size(gender)
      if school_class_size < current_lowest_head_count
        current_school_class_picked = school_class
        current_lowest_head_count = school_class_size
      end
    end
    current_school_class_picked
  end
end
