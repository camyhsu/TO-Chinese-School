class TrackEventSignup < ActiveRecord::Base
  
  RELAY_GROUP_CHOICES = ['Team 1', 'Team 2', 'Team 3', 'Team 4']
  
  belongs_to :track_event_program
  belongs_to :track_event_team
  belongs_to :student, class_name: 'Person', foreign_key: 'student_id'
  belongs_to :parent, class_name: 'Person', foreign_key: 'parent_id'
  
  validates :track_event_program, :student, presence: true


  def <=>(other)
    return 1 if other.class != self.class
    student_a = self.student
    student_b = other.student
    # This sorting relies on grades having ids from low to high in order
    school_class_a = student_a.student_class_assignment_for(SchoolYear.current_school_year).try(:school_class)
    school_class_b = student_b.student_class_assignment_for(SchoolYear.current_school_year).try(:school_class)
    return -1 if school_class_a.nil?
    return 1 if school_class_b.nil?
    grade_order = school_class_a.grade_id <=> school_class_b.grade_id
    if grade_order == 0
      class_order = school_class_a.short_name <=> school_class_b.short_name
      if class_order == 0
        last_name_order = student_a.english_last_name <=> student_b.english_last_name
        if last_name_order == 0
          student_a.english_first_name <=> student_b.english_first_name
        else
          last_name_order
        end
      else
        class_order
      end
    else
      grade_order
    end
  end

  def self.find_current_year_parent_program_signups
    parent_programs = TrackEventProgram.find_current_year_parent_programs
    self.all :conditions => { :track_event_program_id => parent_programs }
  end

  def self.find_tocs_track_event_signups(school_year=SchoolYear.current_school_year)
    self.all :conditions => ['event_type = ? AND school_year_id = ?', TrackEventProgram::EVENT_TYPE_TOCS, school_year.id], :joins => :track_event_program
  end
end
