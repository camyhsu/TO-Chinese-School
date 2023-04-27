class Grade < ActiveRecord::Base

  belongs_to :next_grade, class_name: 'Grade', foreign_key: 'next_grade'
  has_one :previous_grade, class_name: 'Grade', foreign_key: 'next_grade'

  has_many :school_classes
  
  has_many :student_class_assignments
  has_many :students, through: :student_class_assignments

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
    return true if Grade.grade_preschool == self or Grade.grade_preschool.next_grade == self
    false
  end

  def find_next_assignable_school_class(school_class_type, school_year, gender)
    assignable_school_classes = self.active_grade_classes(school_year).select { |active_school_class| active_school_class.school_class_type == school_class_type }
    return nil if assignable_school_classes.empty?
    return assignable_school_classes[0] if assignable_school_classes.size == 1
    # If there are more than one school class assignable, don't assign automatically if the flag is not set in school year
    return nil unless school_year.auto_class_assignment?
    pick_school_class_with_lowest_head_count_from assignable_school_classes, gender
  end
  
  def find_available_school_class_types(school_year)
    school_class_types = self.active_grade_classes(school_year).collect { |active_school_class| active_school_class.school_class_type }
    school_class_types_1 = school_class_types.uniq.compact.sort
    # MOVE EC TO LAST POSITION
    school_class_types_1.include?('EC') ? school_class_types_1 - ['EC'] + ['EC'] : school_class_types_1
  end

  def allowed_max_student_count(school_year)
    self.active_grade_classes(school_year).inject(0) { |memo, grade_class| memo + grade_class.max_size }
  end

  def active_grade_classes_full?(school_year)
    StudentClassAssignment.count_by_sql("SELECT COUNT(1) FROM student_class_assignments WHERE grade_id = #{self.id} AND school_year_id = #{school_year.id}") >= allowed_max_student_count(school_year)
  end
  
  def random_assign_grade_class(school_year)
    puts "#{Time.now} - Random assign grade class for Grade #{self.name}"
    class_type_to_classes = Hash.new { |hash, key| hash[key] = [] }
    self.active_grade_classes.each { |grade_class| class_type_to_classes[grade_class.school_class_type] << grade_class }

    # assign twins to same grade class first
    family_sibings = family_sibling_in_same_grade(self.id, school_year.id)
    family_sibings.each_value do |students|
      student = students[0]
      class_assignment = student.student_class_assignment_for(school_year)
      assign_class_for_single_student(class_assignment, class_type_to_classes, school_year)

      # assign sibings to same class
      students[1,students.size].each do |student2|
        class_assignment2 = student2.student_class_assignment_for(school_year)
        class_assignment2.school_class = class_assignment.school_class
        puts "ERROR - could not save school class assignment => #{class_assignment2.id}" unless class_assignment2.save
      end
    end

    # assign other students
    class_assignments = self.student_class_assignments.all :conditions => ['school_year_id = ? AND school_class_id IS NULL', school_year.id]
    class_assignments.each do |class_assignment|
      assign_class_for_single_student(class_assignment, class_type_to_classes, school_year)
    end
  end

  def school_age
    cursor = Grade.grade_preschool
    school_age = 4
    until cursor == self do
      school_age += 1
      cursor = cursor.next_grade
    end
    school_age
  end


  def self.grade_preschool
    Grade.first conditions: ['short_name = ?', 'Pre']
  end

  def self.grades_with_ap_class
    Grade.all conditions: ['short_name IN (?)', %w(9 10 11)]
  end

  def self.find_by_school_age(school_age)
    return nil if school_age < 4
    # Currently defined lowest grade is PreK for age 4
    grade = Grade.grade_preschool
    (school_age - 4).times do
      grade = grade.next_grade unless grade.nil?
    end
    grade
  end


  private
  def assign_class_for_single_student(class_assignment, class_type_to_classes, school_year)
    student = class_assignment.student
    desired_class_type = student.registration_preference_for(school_year).try(:school_class_type)
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

  def pick_school_class_with_lowest_head_count_from(school_classes, gender)
    return school_classes[0] if school_classes.size == 1
    current_school_class_picked = school_classes[0]
    school_has_started = SchoolYear.current_school_year.school_has_started?
    # If school year started, then assign class base on total student count.
    current_lowest_head_count = current_school_class_picked.current_year_gender_based_class_size gender
    if school_has_started
      current_lowest_head_count = current_school_class_picked.class_size
    end
    school_classes.each do |school_class|
      school_class_size = school_class.current_year_gender_based_class_size(gender)
      if school_has_started
        school_class_size = school_class.class_size
      end
      if school_class_size < current_lowest_head_count
        current_school_class_picked = school_class
        current_lowest_head_count = school_class_size
      end
    end
    current_school_class_picked
  end


  def family_sibling_in_same_grade(grade_id, school_year_id)
    query_result = StudentClassAssignment.connection.select_all 'SELECT fc.family_id, sca.grade_id, sca.student_id FROM student_class_assignments AS sca ' +
                                                                    'INNER JOIN families_children AS fc ON sca.student_id = fc.child_id and sca.school_class_id IS NULL ' +
                                                                    'WHERE sca.school_year_id = ' + school_year_id.to_s +
                                                                    'AND sca.grade_id = ' + grade_id.to_s +
                                                                    ' ORDER BY fc.family_id, sca.grade_id'
    family_sibings = Hash.new { |hash, key| hash[key] = [] }
    previous_result = {}
    query_result.each do |result|
      if (result['family_id'] == previous_result['family_id']) && (result['grade_id'] == previous_result['grade_id'])
        family_sibings[result['family_id']] << Person.find(result['student_id'].to_i)
        previous_student = Person.find(previous_result['student_id'].to_i)
        family_sibings[result['family_id']] << previous_student unless family_sibings[result['family_id']].include?(previous_student)
      else
        previous_result = result
      end
    end
    family_sibings
  end
end
