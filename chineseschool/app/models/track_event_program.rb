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
  AGE_GROUPS = [ TrackEventAgeGroup.new(4, 5), TrackEventAgeGroup.new(6, 7), TrackEventAgeGroup.new(8, 9), TrackEventAgeGroup.new(10, 11), TrackEventAgeGroup.new(12, nil) ]
  
  belongs_to :school_year
  has_many :track_event_teams
  has_many :track_event_signups
  has_many :track_event_heats, dependent: :destroy
  
  validates :school_year, :name, :event_type, :program_type, presence: true


  # def max_sign_up_reached?(school_class)
  #   if (self.program_type == PROGRAM_TYPE_STUDENT_RELAY) and (self.relay_team_size > 7)
  #     current_signup_count = TrackEventSignup.count :conditions => ['track_event_program_id = ? AND student_class_assignments.school_class_id = ? AND school_year_id = ?', self.id, school_class.id, self.school_year.id],
  #                                                   :joins => 'JOIN student_class_assignments ON student_class_assignments.student_id = track_event_signups.student_id'
  #     puts "Current Signup Count => #{current_signup_count}"
  #     return true if current_signup_count >= self.relay_team_size
  #   end
  #   false
  # end

  def individual_program?
    self.program_type == PROGRAM_TYPE_INDIVIDUAL
  end

  def group_program?
    self.program_type == TrackEventProgram::PROGRAM_TYPE_GROUP
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
    if self.group_program?
      #create_lane_assignment_blocks_for_tug_of_war track_event_signups, sample_program
    elsif self.individual_program?
      if self.parent_division?
        #create_heats_for_parent_individual_program program
      else
        next_run_order = create_heats_for_student_individual next_run_order
      end

      #create_lane_assignment_blocks_for_individual_program track_event_signups, sample_program
    else
      # Relay program


      # elsif sample_program.program_type == TrackEventProgram::PROGRAM_TYPE_STUDENT_RELAY
      #   if sample_program.mixed_gender?
      #     create_lane_assignment_blocks_for_unisex_student_relay_program track_event_signups, sample_program
      #   else
      #     create_lane_assignment_blocks_for_student_relay_program track_event_signups, sample_program
      #   end
      # elsif sample_program.program_type == TrackEventProgram::PROGRAM_TYPE_PARENT_RELAY
      #   create_lane_assignment_blocks_for_parent_relay_program track_event_signups, sample_program
    end

    # returning the next run order for the next batch of heats
    next_run_order
  end

  def create_heats_for_student_individual(next_run_order)
    female_signups = []
    male_signups = []
    self.track_event_signups.each do |signup|
      if signup.student.gender == Person::GENDER_FEMALE
        female_signups << signup
      else
        male_signups << signup
      end
    end
    female_heats = create_heats_for_student_individual_by_gender female_signups, Person::GENDER_FEMALE
    male_heats = create_heats_for_student_individual_by_gender male_signups, Person::GENDER_MALE

    # Figure out run order - heat lists should have been in school age order already
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

  def create_heats_for_student_individual_by_gender(signups, gender=nil)
    sorted_signups = signups.sort do |a, b|
      # Sort by school age first
      school_age_order = a.student.school_age_for(SchoolYear.current_school_year) <=> b.student.school_age_for(SchoolYear.current_school_year)
      if school_age_order == 0
        a <=> b
      else
        school_age_order
      end
    end

    heats = []
    last_heat = TrackEventHeat.new
    last_heat.track_event_program = self
    last_heat.gender = gender
    sorted_signups.each do |signup|
      if last_heat.full?
        last_heat.save
        heats << last_heat
        last_heat = TrackEventHeat.new
        last_heat.track_event_program = self
        last_heat.gender = gender
      end
      last_heat.track_event_signups << signup
    end
    last_heat.save
    heats << last_heat
    heats
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
    self.all :conditions => { :school_year_id => SchoolYear.current_school_year.id }, :order => 'sort_key ASC'
  end

  def self.find_tocs_programs_group_by_sort_keys(school_year=SchoolYear.current_school_year)
    tocs_programs = self.all :conditions => ['event_type = ? AND school_year_id = ?', EVENT_TYPE_TOCS, school_year.id], :order => 'sort_key ASC'
    tocs_programs_group_by_sort_keys = Hash.new { |hash, key| hash[key] = [] }
    tocs_programs.each { |tocs_program| tocs_programs_group_by_sort_keys[tocs_program.sort_key] << tocs_program }
    tocs_programs_group_by_sort_keys
  end
end
