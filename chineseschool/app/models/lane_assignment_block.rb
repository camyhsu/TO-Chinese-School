class LaneAssignmentBlock
  
  LANE_COUNT = 7
  
  attr_reader :program_name, :grade, :gender, :lane_assignments
  
  def initialize(program_name, grade, gender, program_type)
    @program_name = program_name
    @grade = grade
    @gender = gender
    @program_type = program_type
    @lane_assignments = []
  end
  
  def add_lane(track_event_signup)
    if @program_type == TrackEventProgram::PROGRAM_TYPE_STUDENT
      add_lane_for_student_program track_event_signup
    elsif @program_type == TrackEventProgram::PROGRAM_TYPE_PARENT
      add_lane_for_parent_program track_event_signup
    end
  end
  
  def full?
    @lane_assignments.size >= LANE_COUNT
  end
  
  def create_lane_block_data_for_pdf
    create_lane_block_data_for_pdf_for_individual_program
  end
  
  def create_lane_block_data_for_pdf_for_individual_program
    data = [ table_header_row ]
    data << chinese_name_row
    data << english_name_row
    data << school_class_name_row
    data << jersey_number_row
    data << empty_row
  end
  
  def table_header_row
    header = []
    LANE_COUNT.times { |i| header << "Lane #{i + 1}" }
    header
  end
  
  def chinese_name_row
    row = []
    @lane_assignments.each { |lane_assignment| row << lane_assignment.chinese_name }
    fill_rest_of_row_with_empty_string(row)
    row
  end
  
  def english_name_row
    row = []
    @lane_assignments.each { |lane_assignment| row << lane_assignment.english_name }
    fill_rest_of_row_with_empty_string(row)
    row
  end
  
  def school_class_name_row
    row = []
    @lane_assignments.each { |lane_assignment| row << lane_assignment.school_class.short_name }
    fill_rest_of_row_with_empty_string(row)
    row
  end
  
  def jersey_number_row
    row = []
    @lane_assignments.each { |lane_assignment| row << lane_assignment.jersey_number }
    fill_rest_of_row_with_empty_string(row)
    row
  end
  
  def empty_row
    row = []
    LANE_COUNT.times { |i| row << '' }
    row
  end
  
  private
  
  def add_lane_for_student_program(track_event_signup)
    student = track_event_signup.student
    lane_assignment = IndividualLaneAssignment.new
    lane_assignment.chinese_name = student.chinese_name
    lane_assignment.english_name = student.english_name
    lane_assignment.school_class = student.student_class_assignment_for(SchoolYear.current_school_year).school_class
    lane_assignment.jersey_number = 1
    @lane_assignments << lane_assignment
  end
  
  def add_lane_for_parent_program(track_event_signup)
    student = track_event_signup.student
    parent = track_event_signup.parent
    lane_assignment = IndividualLaneAssignment.new
    lane_assignment.chinese_name = parent.chinese_name
    lane_assignment.english_name = parent.english_name
    lane_assignment.school_class = student.student_class_assignment_for(SchoolYear.current_school_year).school_class
    lane_assignment.jersey_number = 1
    @lane_assignments << lane_assignment
  end
  
  def fill_rest_of_row_with_empty_string(row)
    (LANE_COUNT - @lane_assignments.size).times { |i| row << '' }
  end
end

class IndividualLaneAssignment
  attr_accessor :chinese_name, :english_name, :school_class, :jersey_number
end
