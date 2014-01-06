class InstructorAssignment < ActiveRecord::Base
  
  ROLE_PRIMARY_INSTRUCTOR = 'Primary Instructor'
  ROLE_ROOM_PARENT = 'Room Parent'
  ROLE_SECONDARY_INSTRUCTOR = 'Secondary Instructor'
  ROLE_TEACHING_ASSISTANT = 'Teaching Assistant'
  ROLES = [ROLE_PRIMARY_INSTRUCTOR, ROLE_ROOM_PARENT, ROLE_SECONDARY_INSTRUCTOR, ROLE_TEACHING_ASSISTANT]
  
  belongs_to :school_year
  belongs_to :school_class
  
  belongs_to :instructor, class_name: 'Person', foreign_key: 'instructor_id'

  validates :school_year, :school_class, :instructor, :start_date, :end_date, :role, presence: true

  validate :start_date_no_later_than_end_date, :no_overlapping


  def start_date_string
    self.start_date.to_s
  end

  def end_date_string
    self.end_date.to_s
  end
  
  def role_is_an_instructor?
    self.role == ROLE_PRIMARY_INSTRUCTOR or self.role == ROLE_SECONDARY_INSTRUCTOR
  end

  def self.change_room_parent(school_class, new_room_parent_id)
    old_room_parent_assignment = school_class.current_room_parent_assignment
    unless old_room_parent_assignment.nil?
      if old_room_parent_assignment.start_date > PacificDate.yesterday
        old_room_parent_assignment.destroy
      else
        old_room_parent_assignment.end_date = PacificDate.yesterday
        old_room_parent_assignment.end_date = old_room_parent_assignment.start_date if old_room_parent_assignment.start_date > old_room_parent_assignment.end_date
        old_room_parent_assignment.save!
      end
      old_room_parent_assignment.instructor.user.try(:adjust_instructor_roles)
    end
    new_room_parent_assignment = InstructorAssignment.new
    new_room_parent_assignment.school_year = SchoolYear.current_school_year
    new_room_parent_assignment.school_class = school_class
    new_room_parent_assignment.instructor_id = new_room_parent_id
    new_room_parent_assignment.role = ROLE_ROOM_PARENT
    new_room_parent_assignment.start_date = PacificDate.today
    new_room_parent_assignment.end_date = SchoolYear.current_school_year.end_date
    new_room_parent_assignment.save!
    new_room_parent_assignment.instructor.user.try(:adjust_instructor_roles)
  end

  def self.find_instructors(school_year=SchoolYear.current_school_year)
    instructor_assignments = InstructorAssignment.all :conditions => ["role IN ('#{ROLE_PRIMARY_INSTRUCTOR}', '#{ROLE_SECONDARY_INSTRUCTOR}') AND school_year_id = ?", school_year.id]
    instructor_assignments.collect { |instructor_assignment| instructor_assignment.instructor }
  end
  
  private

  def start_date_no_later_than_end_date
    return if self.start_date.nil? or self.end_date.nil?
    if self.start_date > self.end_date
      errors.add(:start_date, 'can not be later than end date')
    end
  end

  def no_overlapping
    return if self.school_year.nil? or self.school_class.nil? or self.start_date.nil?
    existing_assignments = InstructorAssignment.find_all_by_school_year_id_and_school_class_id_and_role(self.school_year.id, self.school_class.id, self.role)
    existing_assignments.each do |existing_assignment|
      if duration_overlap? existing_assignment
        if existing_assignment.id != self.id  # skip self to allow self date adjustment
          errors.add(:instructor_assignment, "can not overlap with existing assignment for #{existing_assignment.instructor.name}")
        end
      end
    end
  end
  
  def duration_overlap?(other)
    date_in_duration?(self.start_date, other) or date_in_duration?(other.start_date, self)
  end

  def date_in_duration?(date_to_check, duration)
    date_to_check >= duration.start_date and date_to_check <= duration.end_date
  end
end
