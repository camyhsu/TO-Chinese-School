class TrackEventHeat < ActiveRecord::Base

  LANE_COUNT = 7

  attr_accessible :track_event_program

  belongs_to :track_event_program
  has_many :track_event_signups, dependent: :nullify
  has_many :track_event_teams, dependent: :nullify

  validates :track_event_program, presence: true

  def full?
    if track_event_program.group_program?
      # Tug of war is the only group program, for which each heat has two teams
      track_event_teams.size >= 2
    else
      (track_event_signups.size >= LANE_COUNT) || (track_event_teams.size >= LANE_COUNT)
    end
  end

  def max_student_school_age
    max_student_school_age = 1
    self.track_event_signups.each do |signup|
      school_age = signup.student.school_age_for(SchoolYear.current_school_year)
      max_student_school_age = school_age if school_age > max_student_school_age
    end
    max_student_school_age
  end

  def max_team_age
    max_team_age = 1
    self.track_event_teams.each do |team|
      team_age = team.team_age
      max_team_age = team_age if team_age > max_team_age
    end
    max_team_age
  end

  def max_team_size
    self.track_event_teams.max { |a, b| a.track_event_signups.size <=> b.track_event_signups.size }.track_event_signups.size
  end

  def sorted_teams
    track_event_teams.sort { |a, b| a.name <=> b.name }
  end

  def sorted_signups
    if track_event_program.parent_division?
      track_event_signups.sort do |a, b|
        parent_a = a.parent
        parent_b = b.parent
        gender_order = parent_a.gender <=> parent_b.gender
        if gender_order == 0
          last_name_order = parent_a.english_last_name <=> parent_b.english_last_name
          if last_name_order == 0
            parent_a.english_first_name <=> parent_b.english_first_name
          else
            last_name_order
          end
        else
          gender_order
        end
      end
    else
      track_event_signups.sort do |a, b|
        # Sort by school age first
        school_age_order = a.student.school_age_for(SchoolYear.current_school_year) <=> b.student.school_age_for(SchoolYear.current_school_year)
        if school_age_order == 0
          a <=> b
        else
          school_age_order
        end
      end
    end
  end

  def create_heat_data_for_pdf
    if self.track_event_program.group_program?
      create_heat_data_for_pdf_for_tug_of_war
    elsif self.track_event_program.individual_program?
      create_heat_data_for_pdf_for_individual
    else
      create_heat_data_for_pdf_for_relay
    end
  end

  private

  def create_heat_data_for_pdf_for_individual
    data = [ table_header_row ]
    data << chinese_name_row_for_individual
    data << english_name_row_for_individual
    data << school_class_name_row
    data << jersey_number_row_for_individual
    data
  end

  def table_header_row
    # Lane markings start from Lane 2 per request from activity officers
    header = []
    LANE_COUNT.times { |i| header << "Lane #{i + 2}" }
    header
  end

  def chinese_name_row_for_individual
    row = []
    sorted_signups.each { |signup| row << signup.participant.chinese_name }
    fill_rest_of_row_with_empty_string(row, sorted_signups.size)
    row
  end

  def english_name_row_for_individual
    row = []
    sorted_signups.each { |signup| row << signup.participant.english_name }
    fill_rest_of_row_with_empty_string(row, sorted_signups.size)
    row
  end

  def school_class_name_row
    row = []
    sorted_signups.each { |signup| row << signup.student.student_class_assignment_for(SchoolYear.current_school_year).school_class.short_name }
    fill_rest_of_row_with_empty_string(row, sorted_signups.size)
    row
  end

  def jersey_number_row_for_individual
    row = []
    sorted_signups.each { |signup| row << signup.participant.jersey_number_for(SchoolYear.current_school_year).jersey_number }
    fill_rest_of_row_with_empty_string(row, sorted_signups.size)
    row
  end

  def create_heat_data_for_pdf_for_relay
    data = [ table_header_row ]
    data << relay_team_identifier_row
    max_team_size.times { |i| data << relay_runner_row(i) }
    data
  end

  def relay_team_identifier_row
    row = []
    sorted_teams.each { |team| row << team.name }
    fill_rest_of_row_with_empty_string(row, sorted_teams.size)
    row
  end

  def relay_runner_row(i)
    row = []
    sorted_teams.each { |team| row << team.find_runner_identifier(i) }
    fill_rest_of_row_with_empty_string(row, sorted_teams.size)
    row
  end

  def create_heat_data_for_pdf_for_tug_of_war
    data = [ ['Left Side', 'Right Side'] ]
    row = []
    sorted_teams.each { |team| row << team.name }
    data << row
    max_team_size.times do |i|
      row = []
      sorted_teams.each { |team| row << team.find_runner_identifier(i) }
      data << row
    end
    data
  end

  def fill_rest_of_row_with_empty_string(row, occupied_count)
    (LANE_COUNT - occupied_count).times { |i| row << '' }
  end
end
