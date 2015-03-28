class TrackEventProgram < ActiveRecord::Base
  
  EVENT_TYPE_TOCS = 'TOCS'
  EVENT_TYPE_SOUTHERN_CA = 'Southern CA' # This is only used in 2011-2012, kept for historical data reference

  # The following program types are used before 2014-2015
  PROGRAM_TYPE_STUDENT = 'Student'
  PROGRAM_TYPE_STUDENT_RELAY = 'Student Relay'
  PROGRAM_TYPE_PARENT = 'Parent'
  PROGRAM_TYPE_PARENT_RELAY = 'Parent Relay'

  # The folling program types are used starting 2014-2015
  PROGRAM_TYPE_INDIVIDUAL = 'individual'
  PROGRAM_TYPE_RELAY = 'relay'
  PROGRAM_TYPE_GROUP = 'group'

  # Starting 2014-2015, track program becomes age-based
  # to make sign-up form creating easier, the code is now written with the assumption of two distinct sets
  # of programs for younger and older students
  # The minimum school age is 4, and the age mapped to 10th grade is 15, but there are students older than 15
  YOUNG_DIVISION = 'young'
  TEEN_DIVISION = 'teen'
  PARENT_DIVISION = 'parent'
  MAX_AGE_YOUNG_DIVISION = 9

  # Starting 2014-2015, the heat run order and scoring are based on age groups
  # the age groups are: [4-5], [6-7], [8-9], [10-11], 12 and above
  # Note that age groups must be ordered from young to old -- heat arrangement code depends on that ordering
  YOUNG_DIVISION_AGE_GROUPS = [ TrackEventAgeGroup.new(4, 5), TrackEventAgeGroup.new(6, 7), TrackEventAgeGroup.new(8, 9) ]
  TEEN_DIVISION_AGE_GROUPS = [ TrackEventAgeGroup.new(10, 11), TrackEventAgeGroup.new(12, nil) ]
  AGE_GROUPS = YOUNG_DIVISION_AGE_GROUPS + TEEN_DIVISION_AGE_GROUPS
  
  belongs_to :school_year
  has_many :track_event_teams
  has_many :track_event_signups
  has_many :track_event_heats, dependent: :destroy
  
  validates :school_year, :name, :event_type, :program_type, presence: true


  def individual_program?
    self.program_type == PROGRAM_TYPE_INDIVIDUAL
  end

  def group_program?
    self.program_type == TrackEventProgram::PROGRAM_TYPE_GROUP
  end

  def relay_program?
    self.program_type == TrackEventProgram::PROGRAM_TYPE_RELAY
  end

  def parent_division?
    self.division == PARENT_DIVISION
  end

  def filler_signups_for_gender(gender)
    if gender.nil?
      self.track_event_signups.select { |signup| signup.filler? }
    else
      self.track_event_signups.select { |signup| signup.filler? && (signup.student.gender == gender) }
    end
  end

  def find_non_filler_signup_for(student, parent=nil)
    self.track_event_signups.detect { |signup| (!signup.filler?) && (signup.student == student) && (signup.parent == parent) }
  end

  def find_filler_team_for_gender(gender)
    if gender.nil?
      self.track_event_teams.detect { |team| team.filler? }
    else
      self.track_event_teams.select { |team| team.gender == gender }.detect { |team| team.filler? }
    end
  end

  def create_heats(next_run_order)
    if group_program?
      # Tug of War is the only group program
      create_heats_for_tug_of_war next_run_order
    elsif individual_program?
      if parent_division?
        create_heats_for_parent_individual next_run_order
      else
        create_heats_for_student_individual next_run_order
      end
    else
      if parent_division?
        create_heats_for_parent_relay next_run_order
      else
        create_heats_for_student_relay next_run_order
      end
    end
  end

  def find_max_heat_run_order
    self.track_event_heats.max { |a, b| a.run_order <=> b.run_order }.run_order
  end

  def sorted_heats
    self.track_event_heats.sort { |a, b| a.run_order <=> b.run_order }
  end

  def map_scores_for_student_individual
    score_map = []
    split_gender(self.track_event_signups).each do |gender_signups|
      age_group_map = Hash.new { |hash, key| hash[key] = [] }
      gender_signups.each do |signup|
        AGE_GROUPS.each do |age_group|
          age_group_map[age_group] << signup if age_group.contains_student?(signup.student)
        end
      end
      age_group_map.each_value do |signups|
        signups.sort! { |a, b| determine_track_time_order(a.track_time, b.track_time) }
      end
      score_map << age_group_map
    end
    score_map
  end

  def map_scores_for_student_relay
    score_map = []
    split_gender(self.track_event_teams).each do |gender_teams|
      age_group_map = Hash.new { |hash, key| hash[key] = [] }
      gender_teams.each do |team|
        AGE_GROUPS.each do |age_group|
          age_group_map[age_group] << team if age_group.contains_team?(team)
        end
      end
      age_group_map.each_value do |teams|
        teams.sort! { |a, b| determine_track_time_order(a.track_time, b.track_time) }
      end
      score_map << age_group_map
    end
    score_map
  end

  def map_scores_for_parent_individual
    score_map = []
    split_gender(self.track_event_signups).each do |gender_signups|
      gender_signups.sort! { |a, b| determine_track_time_order(a.track_time, b.track_time) }
      score_map << gender_signups
    end
    score_map
  end

  def map_scores_for_parent_relay
    score_map = []
    split_gender(self.track_event_teams).each do |gender_teams|
      gender_teams.sort! { |a, b| determine_track_time_order(a.track_time, b.track_time) }
      score_map << gender_teams
    end
    score_map
  end

  def calculate_scores_for_student_individual
    score_map = map_scores_for_student_individual
  end

  def self.young_division_programs
    self.all conditions: { school_year_id: SchoolYear.current_school_year.id, division: YOUNG_DIVISION }
  end

  def self.teen_division_programs
    self.all conditions: { school_year_id: SchoolYear.current_school_year.id, division: TEEN_DIVISION }
  end

  def self.parent_division_programs
    self.all conditions: { school_year_id: SchoolYear.current_school_year.id, division: PARENT_DIVISION }
  end

  def self.relay_programs
    self.all conditions: { school_year_id: SchoolYear.current_school_year.id, program_type: PROGRAM_TYPE_RELAY }
  end

  def self.group_programs
    self.all conditions: { school_year_id: SchoolYear.current_school_year.id, program_type: PROGRAM_TYPE_GROUP }
  end
  
  def self.find_by_grade(grade, school_year=SchoolYear.current_school_year)
    self.all conditions: { grade_id: grade.id, school_year_id: school_year.id }, order: 'id ASC'
  end

  def self.find_by_school_age_for(student)
    age_based_grade = Grade.find_by_school_age(student.school_age_for SchoolYear.current_school_year)
    age_based_grade = age_based_grade.snap_down_to_first_active_grade(SchoolYear.current_school_year)
    programs = TrackEventProgram.find_by_grade(age_based_grade)
    # This method would be called only for age-based movement of programs
    # There is a specific rule of only showing student individual programs as allowed sign-up
    programs.select {|program| (program.program_type == PROGRAM_TYPE_STUDENT) && (!program.name.start_with?('Tug'))}
  end

  def self.find_programs_by_sort_keys
    self.all conditions: { school_year_id: SchoolYear.current_school_year.id }, order: 'sort_key ASC'
  end

  def self.find_tocs_programs_group_by_sort_keys(school_year=SchoolYear.current_school_year)
    tocs_programs = self.all :conditions => ['event_type = ? AND school_year_id = ?', EVENT_TYPE_TOCS, school_year.id], :order => 'sort_key ASC'
    tocs_programs_group_by_sort_keys = Hash.new { |hash, key| hash[key] = [] }
    tocs_programs.each { |tocs_program| tocs_programs_group_by_sort_keys[tocs_program.sort_key] << tocs_program }
    tocs_programs_group_by_sort_keys
  end


  private


  def create_heats_for_tug_of_war(next_run_order)
    gender_heats = split_gender(self.track_event_teams).collect { |gender_teams| create_heats_for_team(gender_teams) }

    # Figure out run order - heat lists should have been in name order already
    arrange_run_order_by_age_group gender_heats[0], gender_heats[1], next_run_order
  end

  def create_heats_for_student_individual(next_run_order)
    gender_heats = split_gender(self.track_event_signups).collect { |gender_signups| create_heats_for_student_individual_by_gender(gender_signups) }

    # Figure out run order - heat lists should have been in school age order already
    arrange_run_order_by_age_group gender_heats[0], gender_heats[1], next_run_order
  end

  def create_heats_for_student_individual_by_gender(signups)
    sorted_signups = signups.sort do |a, b|
      # Sort by school age first
      school_age_order = a.student.school_age_for(SchoolYear.current_school_year) <=> b.student.school_age_for(SchoolYear.current_school_year)
      if school_age_order == 0
        a <=> b
      else
        school_age_order
      end
    end
    create_heats_for_signups(sorted_signups)
  end

  def arrange_run_order_by_age_group(female_heats, male_heats, next_run_order)
    # The rules are a bit complicated.
    # We starts with female heats first from young age, then switch to male heats once the max
    # student school age passes the age group upper bound, then switch back to female heats
    # when male heats passes the same age group upper bound and move on to the next age group
    current_age_group_index = 0
    until (female_heats.empty? && male_heats.empty?) do
      next_female_heat = female_heats.first
      if (!next_female_heat.nil?) && AGE_GROUPS[current_age_group_index].contains_heat_by_upper_bound?(next_female_heat)
        next_female_heat.run_order = next_run_order
        next_female_heat.save
        next_run_order += 1
        female_heats.shift # remove the heat from the queues to be processed
      else
        next_male_heat = male_heats.first
        if (!next_male_heat.nil?) && AGE_GROUPS[current_age_group_index].contains_heat_by_upper_bound?(next_male_heat)
          next_male_heat.run_order = next_run_order
          next_male_heat.save
          next_run_order += 1
          male_heats.shift # remove the heat from the queues to be processed
        else
          # all heats are not in the current age group -- advance to the next one
          current_age_group_index += 1
        end
      end
    end

    # returning the next run order for the next batch of heats
    next_run_order
  end

  def create_heats_for_parent_individual(next_run_order)
    sorted_signups = self.track_event_signups.sort do |a, b|
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

    heats = create_heats_for_signups(sorted_signups)

    # Figure out run order - no age group for parent programs
    heats.each do |heat|
      heat.run_order = next_run_order
      heat.save
      next_run_order += 1
    end

    # returning the next run order for the next batch of heats
    next_run_order
  end

  def create_heats_for_student_relay(next_run_order)
    gender_heats = split_gender(self.track_event_teams).collect { |gender_teams| create_heats_for_team(gender_teams) }

    # Figure out run order - heat lists should have been in school age order already
    arrange_run_order_by_age_group gender_heats[0], gender_heats[1], next_run_order
  end

  def create_heats_for_parent_relay(next_run_order)
    heats = create_heats_for_team(self.track_event_teams)

    # Figure out run order - no age group for parent programs
    heats.each do |heat|
      heat.run_order = next_run_order
      heat.save
      next_run_order += 1
    end

    # returning the next run order for the next batch of heats
    next_run_order
  end

  def split_gender(list)
    female_list = []
    male_list = []
    list.each do |item|
      if item.gender == Person::GENDER_FEMALE
        female_list << item
      else
        male_list << item
      end
    end
    [female_list, male_list]
  end

  def create_heats_for_team(teams)
    heats = []
    return heats if teams.empty?
    last_heat = TrackEventHeat.new
    last_heat.track_event_program = self
    last_heat.gender = teams[0].gender
    teams.sort { |a, b| a.name <=> b.name }.each do |team|
      if last_heat.full?
        last_heat.save
        heats << last_heat
        last_heat = TrackEventHeat.new
        last_heat.track_event_program = self
        last_heat.gender = team.gender
      end
      last_heat.track_event_teams << team
    end
    last_heat.save
    heats << last_heat
    heats
  end

  def create_heats_for_signups(signups)
    heats = []
    return heats if signups.empty?
    last_heat = TrackEventHeat.new
    last_heat.track_event_program = self
    last_heat.gender = signups[0].gender
    signups.each do |signup|
      if last_heat.full?
        last_heat.save
        heats << last_heat
        last_heat = TrackEventHeat.new
        last_heat.track_event_program = self
        last_heat.gender = signup.gender
      end
      last_heat.track_event_signups << signup
    end
    last_heat.save
    heats << last_heat
    heats
  end

  def determine_track_time_order(a, b)
    if a.nil?
      if b.nil?
        0
      else
        1
      end
    else
      if b.nil?
        -1
      else
        a <=> b
      end
    end
  end
end
