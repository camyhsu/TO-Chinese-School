class SchoolClass < ActiveRecord::Base
  
  belongs_to :grade

  validates_presence_of :english_name, :chinese_name
  validates_uniqueness_of :english_name, :chinese_name

  validates_numericality_of :max_size, :only_integer => true, :greater_than_or_equal_to => 0, :allow_nil => true
  validates_numericality_of :min_age, :only_integer => true, :greater_than_or_equal_to => 0, :allow_nil => true
  validates_numericality_of :max_age, :only_integer => true, :greater_than_or_equal_to => 0, :allow_nil => true
  
  
  def name
    "#{chinese_name}(#{english_name})"
  end

  def elective?
    self.grade.nil?
  end
  
  def student_class_assignments
    return StudentClassAssignment.find_by_elective_class_id(self.id) if elective?
    StudentClassAssignment.find_by_school_class_id(self.id)
  end

  def students
    association_key = 'school_class_id'
    association_key = 'elective_class_id' if elective?
    people = Person.all :select => 'people.*', 
        :from => 'people, student_class_assignments',
        :conditions => ["people.id = student_class_assignments.student_id and student_class_assignments.#{association_key} = ?", self.id]
    puts people.inspect
    people
  end
  
  def instructor_assignment_history
    @instructor_assignment_history ||= InstructorAssignmentHistory.new(self.id)
  end

  def current_instructor_assignments
    instructor_assignments = InstructorAssignment.all :conditions => ["school_year_id = ? AND school_class_id = ?",
        SchoolYear.current_school_year.id, self.id ]
    assignment_hash = create_empty_assignment_hash
    instructor_assignments.each do |instructor_assignment|
      assignment_hash[instructor_assignment.role] << instructor_assignment.instructor
    end
    assignment_hash
  end
  
  def create_empty_assignment_hash
    assignment_hash = {}
    assignment_hash[InstructorAssignment::ROLE_PRIMARY_INSTRUCTOR] = []
    assignment_hash[InstructorAssignment::ROLE_ROOM_PARENT] = []
    assignment_hash[InstructorAssignment::ROLE_SECONDARY_INSTRUCTOR] = []
    assignment_hash[InstructorAssignment::ROLE_TEACHING_ASSISTANT] = []
    assignment_hash
  end
end
