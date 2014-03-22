class LaneAssignmentBlock
  
  LANE_COUNT = 7
  
  attr_reader :sample_track_event_program, :gender, :lane_assignments
  
  def initialize(sample_track_event_program, gender)
    @sample_track_event_program = sample_track_event_program
    @gender = gender
    @lane_assignments = []
  end
  
  def add_lane(track_event_signup)
    if @sample_track_event_program.program_type == TrackEventProgram::PROGRAM_TYPE_STUDENT
      add_lane_for_student_program track_event_signup
    elsif @sample_track_event_program.program_type == TrackEventProgram::PROGRAM_TYPE_PARENT
      add_lane_for_parent_program track_event_signup
    end
  end
  
  def add_relay_team(relay_team)
    @lane_assignments << RelayTeamLaneAssignment.new(relay_team)
  end
  
  def add_tug_of_war_team(school_class, students)
    @lane_assignments << TugOfWarLaneAssignment.new(school_class, students)
  end
  
  def full?
    @lane_assignments.size >= LANE_COUNT
  end
  
  def create_lane_block_data_for_pdf
    if @sample_track_event_program.name.start_with? 'Tug'
      create_lane_block_data_for_pdf_for_tug_of_war
    elsif @sample_track_event_program.program_type == TrackEventProgram::PROGRAM_TYPE_STUDENT_RELAY
      create_lane_block_data_for_pdf_for_student_relay_program
    elsif @sample_track_event_program.program_type == TrackEventProgram::PROGRAM_TYPE_PARENT_RELAY
      create_lane_block_data_for_pdf_for_parent_relay_program
    else
      create_lane_block_data_for_pdf_for_individual_program
    end
  end
  
  def create_lane_block_data_for_pdf_for_individual_program
    data = [ table_header_row ]
    data << chinese_name_row
    data << english_name_row
    data << school_class_name_row
    data << jersey_number_row
    data
  end
  
  def table_header_row
    # Lane markings start from Lane 2 per request from activity officers
    header = []
    LANE_COUNT.times { |i| header << "Lane #{i + 2}" }
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
    @lane_assignments.each do |lane_assignment|
      if lane_assignment.moved_to_grade.nil?
        row << lane_assignment.school_class.short_name
      else
        row << "#{lane_assignment.school_class.short_name} => #{lane_assignment.moved_to_grade.short_name}"
      end
    end
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
  
  def create_lane_block_data_for_pdf_for_student_relay_program
    data = [ table_header_row ]
    data << relay_team_identifier_row
    @sample_track_event_program.relay_team_size.times { |i| data << relay_runner_row(i) }
    data
  end
  
  def relay_team_identifier_row
    row = []
    @lane_assignments.each do |lane_assignment|
      team_identifier = lane_assignment.relay_team.identifier
      team_identifier = team_identifier + ' **' if lane_assignment.relay_team.overbooked?
      row << team_identifier
    end
    fill_rest_of_row_with_empty_string(row)
    row
  end
  
  def relay_runner_row(i)
    row = []
    @lane_assignments.each { |lane_assignment| row << lane_assignment.relay_team.runners[i].try(:english_name) }
    fill_rest_of_row_with_empty_string(row)
    row
  end
  
  def create_lane_block_data_for_pdf_for_tug_of_war
    data = [ school_class_identifier_row ]
    largest_tug_of_war_team_size.times { |i| data << tug_of_war_student_row(i) }
    data
  end
  
  def school_class_identifier_row
    row = []
    @lane_assignments.each { |lane_assignment| row << "#{lane_assignment.school_class.grade.chinese_name} #{lane_assignment.school_class.short_name}" }
    fill_rest_of_row_with_empty_string(row)
    row
  end
  
  def largest_tug_of_war_team_size
    largest_tug_of_war_team = @lane_assignments.max { |a, b| a.students.size <=> b.students.size }
    largest_tug_of_war_team.students.size
  end
  
  def tug_of_war_student_row(i)
    row = []
    @lane_assignments.each { |lane_assignment| row << lane_assignment.students[i].try(:english_name) }
    fill_rest_of_row_with_empty_string(row)
    row
  end
  
  def create_lane_block_data_for_pdf_for_parent_relay_program
    data = [ table_header_row ]
    @sample_track_event_program.relay_team_size.times { |i| data << parent_relay_runner_row(i) }
    data
  end
  
  def parent_relay_runner_row(i)
    row = []
    @lane_assignments.each { |lane_assignment| row << lane_assignment.relay_team[i].try(:english_name) }
    fill_rest_of_row_with_empty_string(row)
    row
  end
  
  private
  
  def add_lane_for_student_program(track_event_signup)
    student = track_event_signup.student
    lane_assignment = IndividualLaneAssignment.new
    lane_assignment.chinese_name = student.chinese_name
    lane_assignment.english_name = student.english_name
    lane_assignment.school_class = student.student_class_assignment_for(SchoolYear.current_school_year).school_class
    lane_assignment.jersey_number = JerseyNumber.find_jersey_number_for student
    # Check if this is a prompted student
    if lane_assignment.school_class.grade != track_event_signup.track_event_program.grade
      lane_assignment.moved_to_grade = track_event_signup.track_event_program.grade
    end
    @lane_assignments << lane_assignment
  end
  
  def add_lane_for_parent_program(track_event_signup)
    student = track_event_signup.student
    parent = track_event_signup.parent
    lane_assignment = IndividualLaneAssignment.new
    lane_assignment.chinese_name = parent.chinese_name
    lane_assignment.english_name = parent.english_name
    lane_assignment.school_class = student.student_class_assignment_for(SchoolYear.current_school_year).school_class
    lane_assignment.jersey_number = JerseyNumber.find_jersey_number_for parent
    @lane_assignments << lane_assignment
  end
  
  def fill_rest_of_row_with_empty_string(row)
    (LANE_COUNT - @lane_assignments.size).times { |i| row << '' }
  end


  class ProgramHeats

    def initialize(sample_program, gender)
      @sample_program = sample_program
      @gender = gender
      @heats = []
    end

    def add_lane(lane_participant)
      last_heat = @heats[-1]
      if last_heat.nil? || (last_heat.size >= LANE_COUNT)
        @heats << []
        last_heat = @heats[-1]
      end
      last_heat << lane_participant
    end

    def create_lane_assignment_blocks
      even_out_head_counts
      lane_assignment_blocks = []
      @heats.each do |heat|
        lane_assignment_block = LaneAssignmentBlock.new(@sample_program, @gender)
        heat.each do |lane_participant|
          if @sample_program.program_type == TrackEventProgram::PROGRAM_TYPE_STUDENT_RELAY
            # Relay program
            lane_assignment_block.add_relay_team lane_participant
          else
            # Individual program
            lane_assignment_block.add_lane lane_participant
          end
        end
        lane_assignment_blocks << lane_assignment_block
      end
      lane_assignment_blocks
    end

    private

    def even_out_head_counts
      if @heats.size > 2
        even_out_last_three_heats
      elsif @heats.size == 2
        even_out_two_heats
      end
    end

    def even_out_two_heats
      combined_size = @heats[0].size + @heats[1].size
      new_heat_size = combined_size / 2
      extra = combined_size - (new_heat_size * 2)
      new_heat_size += 1 if extra > 0
      moving_signups = @heats.flatten
      @heats.clear
      @heats << moving_signups[0, new_heat_size]
      @heats << moving_signups[new_heat_size, LANE_COUNT]
    end

    def even_out_last_three_heats
      combined_size = @heats[-1].size + @heats[-2].size + @heats[-3].size
      new_heat_size = combined_size / 3
      extra = combined_size - (new_heat_size * 3)
      adjusted_heat_size_1 = new_heat_size
      adjusted_heat_size_2 = new_heat_size
      if extra == 2
        adjusted_heat_size_1 += 1
        adjusted_heat_size_2 += 1
      elsif extra == 1
        adjusted_heat_size_1 += 1
      end
      moving_signups = @heats[-3] + @heats[-2] + @heats[-1]
      @heats[-3] = moving_signups[0, adjusted_heat_size_1]
      @heats[-2] = moving_signups[adjusted_heat_size_1, adjusted_heat_size_2]
      @heats[-1] = moving_signups[adjusted_heat_size_1 + adjusted_heat_size_2, LANE_COUNT]
    end
  end

  class IndividualLaneAssignment
    attr_accessor :chinese_name, :english_name, :school_class, :jersey_number, :moved_to_grade
  end

  class RelayTeamLaneAssignment
    attr_reader :relay_team

    def initialize(relay_team)
      @relay_team = relay_team
    end
  end

  class RelayTeam
    attr_accessor :school_class, :team_name, :runners

    def initialize(school_class, team_name, relay_team_size)
      @school_class = school_class
      @team_name = team_name
      @relay_team_size = relay_team_size
      @runners = []
    end

    def identifier
      "#{@school_class.short_name} #{@team_name}"
    end

    def add_runner(runner)
      @runners << runner
    end

    def overbooked?
      @runners.size > @relay_team_size
    end
  end

  class TugOfWarLaneAssignment
    attr_reader :school_class, :students

    def initialize(school_class, students)
      @school_class = school_class
      @students = students
    end
  end
end

