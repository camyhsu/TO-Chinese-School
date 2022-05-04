class SchoolClass < ActiveRecord::Base
  
  SCHOOL_CLASS_TYPE_ELECTIVE = 'ELECTIVE'
  SCHOOL_CLASS_TYPE_ENGLISH_INSTRUCTION = 'SE'
  SCHOOL_CLASS_TYPE_MIXED = 'M'
  SCHOOL_CLASS_TYPE_SIMPLIFIED = 'S'
  SCHOOL_CLASS_TYPE_TRADITIONAL = 'T'
  SCHOOL_CLASS_TYPE_EVERYDAYCHINESE = 'EC'
  SCHOOL_CLASS_CHINESE_AP = 'Chinese AP'
  
  SCHOOL_CLASS_TYPES = [SCHOOL_CLASS_TYPE_SIMPLIFIED, SCHOOL_CLASS_TYPE_TRADITIONAL, 
    SCHOOL_CLASS_TYPE_MIXED, SCHOOL_CLASS_TYPE_ENGLISH_INSTRUCTION, SCHOOL_CLASS_TYPE_ELECTIVE, SCHOOL_CLASS_TYPE_EVERYDAYCHINESE]

  attr_accessible :english_name, :chinese_name, :short_name, :description, :location,
                  :school_class_type, :max_size, :min_age, :max_age

  belongs_to :grade

  has_many :school_class_active_flags

  validates :english_name, :chinese_name, :school_class_type, presence: true
  validates :english_name, :chinese_name, uniqueness: true

  validates :max_size, numericality: {only_integer: true, greater_than: 0, allow_nil: false}
  validates :min_age, numericality: {only_integer: true, greater_than_or_equal_to: 0, allow_nil: true}
  validates :max_age, numericality: {only_integer: true, greater_than_or_equal_to: 0, allow_nil: true}
  
  
  def name
    "#{chinese_name}(#{english_name})"
  end

  def elective?
    self.school_class_type == SCHOOL_CLASS_TYPE_ELECTIVE
  end

  def active_in?(school_year)
    school_class_active_flag = self.school_class_active_flags.first :conditions => ['school_year_id = ?', school_year.id]
    return false if school_class_active_flag.nil?
    school_class_active_flag.active
  end

  def flip_active_to(active_flag, school_year_id)
    school_class_active_flag = self.school_class_active_flags.first :conditions => ['school_year_id = ?', school_year_id]
    if school_class_active_flag.nil?
      school_class_active_flag = SchoolClassActiveFlag.new
      school_class_active_flag.school_class = self
      school_class_active_flag.school_year_id = school_year_id
    end
    school_class_active_flag.active = active_flag
    school_class_active_flag.save!
  end

  def class_size(school_year = SchoolYear.current_school_year)
    class_clause = 'school_class_id = ?'
    class_clause = 'elective_class_id = ?' if elective?
    StudentClassAssignment.count(:conditions => ["#{class_clause} AND school_year_id = ?", self.id, school_year.id])
  end

  def current_year_gender_based_class_size(gender)
    class_clause = 'school_class_id = ?'
    class_clause = 'elective_class_id = ?' if elective?
    StudentClassAssignment.count(conditions: ["#{class_clause} AND school_year_id = ? AND gender = ?", self.id, SchoolYear.current_school_year.id, gender],
                                 joins: 'LEFT JOIN people ON people.id = student_class_assignments.student_id')
  end

  def students(school_year = SchoolYear.current_school_year)
    association_key = 'school_class_id'
    association_key = 'elective_class_id' if elective?
    Person.all :select => 'people.*', 
        :from => 'people, student_class_assignments',
        :conditions => ["people.id = student_class_assignments.student_id AND student_class_assignments.#{association_key} = ? AND student_class_assignments.school_year_id = ?", self.id, school_year.id],
        :order => 'people.english_last_name ASC, people.english_first_name ASC'
  end
  
  def instructor_assignment_history
    @instructor_assignment_history ||= InstructorAssignmentHistory.new(self.id)
  end

  def instructor_assignments(school_year=SchoolYear.current_school_year)
    instructor_assignments = InstructorAssignment.all :conditions => ["school_year_id = ? AND school_class_id = ?", school_year.id, self.id ]
    assignment_hash = create_empty_instructor_assignment_hash
    instructor_assignments.each do |instructor_assignment|
      assignment_hash[instructor_assignment.role] << instructor_assignment.instructor
    end
    assignment_hash
  end

  def current_primary_instructor(school_year=SchoolYear.current_school_year)
    current_primary_instructor_assignment = InstructorAssignment.first :conditions => ["school_year_id = ? AND school_class_id = ? AND role = ? AND end_date >= ?",
                                                                                       school_year.id, self.id, InstructorAssignment::ROLE_PRIMARY_INSTRUCTOR, PacificDate.today ]
    current_primary_instructor_assignment.try(:instructor)
  end

  def room_parent_assignment(school_year=SchoolYear.current_school_year)
    InstructorAssignment.first :conditions => ["school_year_id = ? AND school_class_id = ? AND role = ? AND start_date <= ? AND end_date >= ?",
      school_year.id, self.id, InstructorAssignment::ROLE_ROOM_PARENT, PacificDate.today, PacificDate.today ]
  end

  def room_parent_name(school_year=SchoolYear.current_school_year)
    room_parent_assignment(school_year).try(:instructor).try(:name)
  end
  
  def find_room_parent_candidates
    room_parent_candidates = []
    students.each do |student|
      student.find_families_as_child.each do |family|
        room_parent_candidates << family.parent_one
        room_parent_candidates << family.parent_two
      end
    end
    room_parent_candidates.uniq.compact
  end

  def allow_school_age?(school_age)
    return false if (!self.min_age.nil?) and (self.min_age > 0) and (school_age < self.min_age)
    return false if (!self.max_age.nil?) and (self.max_age > 0) and (school_age > self.max_age)
    true
  end
  
  def grade_class_is_full_for?(school_year)
    StudentClassAssignment.count(:conditions => ["school_class_id = ? AND school_year_id = ?", self.id, school_year.id]) >= self.max_size
  end

  def elective_is_full_for?(school_year)
    StudentClassAssignment.count(:conditions => ["elective_class_id = ? AND school_year_id = ?", self.id, school_year.id]) >= self.max_size
  end

  def track_event_signup_student_count(school_year=SchoolYear.current_school_year)
    counter = 0
    students.each do |student|
      signup_count = TrackEventSignup.count :conditions => ['track_event_signups.student_id = ? AND student_class_assignments.school_class_id = ? AND track_event_programs.school_year_id = ?', student.id, self.id, school_year.id],
                                            :joins => 'JOIN student_class_assignments ON student_class_assignments.student_id = track_event_signups.student_id' +
                                                      ' JOIN track_event_programs ON track_event_programs.id = track_event_signups.track_event_program_id'
      counter += 1 if signup_count > 0
      puts "#{student.name} #{student.id} => #{signup_count}" if self.id == 25
    end
    counter
  end

  def track_event_scores
    students.collect(&:track_event_scores).inject(0, &:+)
  end

  def track_event_participant_count
    participant_count = 0
    students.each { |student| participant_count += 1 if student.track_event_scores > 0.0 }
    participant_count
  end

  def self.find_all_active_school_classes(school_year=SchoolYear.current_school_year)
    self.all.reject { |school_class| !school_class.active_in?(school_year) }
  end

  def self.find_all_active_school_classes_in_current_and_future_school_years
    school_years = SchoolYear.find_current_and_future_school_years
    self.all.reject do |school_class|
      active_in_any_school_year = false
      school_years.each do |school_year|
        active_in_any_school_year ||= school_class.active_in?(school_year)
      end
      !active_in_any_school_year
    end.sort! { |a, b| a.english_name <=> b.english_name }
  end
  
  def self.find_all_active_grade_classes(school_year=SchoolYear.current_school_year)
    self.all(:conditions => ['school_class_type <> ?', SCHOOL_CLASS_TYPE_ELECTIVE]).reject { |grade_class| !grade_class.active_in?(school_year) }
  end

  def self.find_all_active_elective_classes(school_year=SchoolYear.current_school_year)
    self.all(:conditions => ['school_class_type = ?', SCHOOL_CLASS_TYPE_ELECTIVE]).reject { |elective_class| !elective_class.active_in?(school_year) }
  end

  def self.find_available_elective_classes_for_registration(school_age, school_year, grade)
    # 9th and above grade can only select ChineseAP, other grades cannot select ChineseAP.
    if Grade.grades_with_ap_class.include? grade
      self.all(:conditions => ['school_class_type = ? and english_name = ?', SCHOOL_CLASS_TYPE_ELECTIVE, SCHOOL_CLASS_CHINESE_AP]).reject do |elective_class|
        !elective_class.active_in?(school_year) or
            !elective_class.allow_school_age?(school_age) or
            elective_class.elective_is_full_for?(school_year)
      end
    else
      self.all(:conditions => ['school_class_type = ?', SCHOOL_CLASS_TYPE_ELECTIVE]).reject do |elective_class|
        !elective_class.active_in?(school_year) or
            !elective_class.allow_school_age?(school_age) or
            elective_class.elective_is_full_for?(school_year) or
            elective_class.english_name == SCHOOL_CLASS_CHINESE_AP
      end
    end
  end

  private

  def create_empty_instructor_assignment_hash
    assignment_hash = {}
    assignment_hash[InstructorAssignment::ROLE_PRIMARY_INSTRUCTOR] = []
    assignment_hash[InstructorAssignment::ROLE_ROOM_PARENT] = []
    assignment_hash[InstructorAssignment::ROLE_SECONDARY_INSTRUCTOR] = []
    assignment_hash[InstructorAssignment::ROLE_TEACHING_ASSISTANT] = []
    assignment_hash
  end
end
