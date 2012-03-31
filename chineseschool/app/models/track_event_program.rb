class TrackEventProgram < ActiveRecord::Base
  
  EVENT_TYPE_TOCS = 'TOCS'
  EVENT_TYPE_SOUTHERN_CA = 'Southern CA'
  
  PROGRAM_TYPE_STUDENT = 'Student'
  PROGRAM_TYPE_STUDENT_RELAY = 'Student Relay'
  PROGRAM_TYPE_PARENT = 'Parent'
  PROGRAM_TYPE_PARENT_RELAY = 'Parent Relay'
  
  belongs_to :school_year
  belongs_to :grade
  
  validates_presence_of :school_year, :grade, :name, :event_type, :program_type
  
  
  def self.find_by_grade(grade, school_year=SchoolYear.current_school_year)
    self.all :conditions => ['grade_id = ? AND school_year_id = ?', grade.id, school_year.id], :order => 'id ASC'
  end
  
  def self.find_tocs_programs(school_year=SchoolYear.current_school_year)
    self.all :conditions => ['event_type = ? AND school_year_id = ?', EVENT_TYPE_TOCS, school_year.id], :order => 'id ASC'
  end
  
  def create_lane_assignment_blocks
    track_event_signups = TrackEventSignup.find_all_by_track_event_program_id self.id
    track_event_signups.sort! do |a, b|
      birth_year_order = a.student.birth_year <=> b.student.birth_year
      if birth_year_order == 0
        a.student.birth_month <=> b.student.birth_month
      else
        birth_year_order
      end
    end
    
    
    current_female_lane_assignment_block = nil
    female_lane_assignment_blocks = []
    current_male_lane_assignment_block = nil
    male_lane_assignment_blocks = []
    track_event_signups.each do |signup|
      if (self.program_type == PROGRAM_TYPE_PARENT) or (self.program_type == PROGRAM_TYPE_PARENT_RELAY)
        participant = signup.parent
      else
        participant = signup.student
      end
      if participant.gender == Person::GENDER_FEMALE
        if current_female_lane_assignment_block.nil?
          current_female_lane_assignment_block = LaneAssignmentBlock.new(self.name, self.grade, Person::GENDER_FEMALE, self.program_type)
          female_lane_assignment_blocks << current_female_lane_assignment_block
        end
        current_female_lane_assignment_block.add_lane signup
        if current_female_lane_assignment_block.full?
          current_female_lane_assignment_block = nil
        end
      else
        if current_male_lane_assignment_block.nil?
          current_male_lane_assignment_block = LaneAssignmentBlock.new(self.name, self.grade, Person::GENDER_MALE, self.program_type)
          male_lane_assignment_blocks << current_male_lane_assignment_block
        end
        current_male_lane_assignment_block.add_lane signup
        if current_male_lane_assignment_block.full?
          current_male_lane_assignment_block = nil
        end
      end
    end
    [ female_lane_assignment_blocks, male_lane_assignment_blocks ]
  end
end
