class InstructorAssignment < ActiveRecord::Base
  
  ROLE_PRIMARY_INSTRUCTOR = 'Primary Instructor'
  ROLE_ROOM_PARENT = 'Room Parent'
  ROLE_SECONDARY_INSTRUCTOR = 'Secondary Instructor'
  ROLE_TEACHING_ASSISTANT = 'Teaching Assistant'
  ROLES = [ROLE_PRIMARY_INSTRUCTOR, ROLE_ROOM_PARENT, ROLE_SECONDARY_INSTRUCTOR, ROLE_TEACHING_ASSISTANT]
  
  belongs_to :school_year
  belongs_to :school_class
  
  belongs_to :instructor, :class_name => 'Person', :foreign_key => 'instructor_id'

  validates_presence_of :school_year, :school_class, :instructor, :start_date, :end_date, :role

  validate :start_date_no_later_than_end_date, :no_overlapping


  def start_date_string
    self.start_date.to_s
  end

  def end_date_string
    self.end_date.to_s
  end

  
  private

  def start_date_no_later_than_end_date
    return if self.start_date.nil? or self.end_date.nil?
    if self.start_date > self.end_date
      errors.add_to_base('Start Date can not be later than End Date')
    end
  end

  def no_overlapping
    return if self.school_year.nil? or self.school_class.nil? or self.start_date.nil?
    existing_assignments = InstructorAssignment.find_all_by_school_year_id_and_school_class_id_and_role(self.school_year.id, self.school_class.id, self.role)
    existing_assignments.each do |existing_assignment|
      if duration_overlap? existing_assignment
        if existing_assignment.id != self.id  # skip self to allow self date adjustment
          errors.add_to_base("Assginment can not overlap with existing assignment for #{existing_assignment.instructor.name}")
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
