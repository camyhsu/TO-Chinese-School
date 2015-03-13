class Activity::TrackEventsController < ApplicationController

  def index
  end

  def sign_up_index
    @active_grade_classes = SchoolClass.find_all_active_grade_classes
    @active_grade_classes.sort! do |a, b|
      grade_order = a.grade_id <=> b.grade_id
      if grade_order == 0
        a.short_name <=> b.short_name
      else
        grade_order
      end
    end
  end
  
  def sign_up
    requested_school_class_id = params[:id].to_i
    unless instructor_assignment_verified? requested_school_class_id
      flash[:notice] = 'Access to requested track event sign up not authorized'
      redirect_to controller: '/home'
      return
    end
    @school_class = SchoolClass.find requested_school_class_id

    # Split students into different divisions based on age
    @young_students = []
    @teen_students = []
    @school_class.students.each do |student|
      if student.school_age_for(SchoolYear.current_school_year) > TrackEventProgram::MAX_AGE_YOUNG_DIVISION
        @teen_students << student
      else
        @young_students << student
      end
    end

    @young_student_programs = TrackEventProgram.young_division_programs + TrackEventProgram.parent_division_programs unless @young_students.empty?
    @teen_student_programs = TrackEventProgram.teen_division_programs + TrackEventProgram.parent_division_programs unless @teen_students.empty?

    respond_to do |format|
      format.html
      format.pdf {render layout: false}
    end
  end
  
  def sign_up_result
    requested_school_class_id = params[:id].to_i
    unless instructor_assignment_verified? requested_school_class_id
      flash[:notice] = 'Access to requested track event sign up result not authorized'
      redirect_to controller: '/home'
      return
    end
    @school_class = SchoolClass.find requested_school_class_id

    # Split students into different divisions based on age
    @young_students = []
    @teen_students = []
    @school_class.students.each do |student|
      if student.school_age_for(SchoolYear.current_school_year) > TrackEventProgram::MAX_AGE_YOUNG_DIVISION
        @teen_students << student
      else
        @young_students << student
      end
    end

    @young_student_programs = TrackEventProgram.young_division_programs + TrackEventProgram.parent_division_programs unless @young_students.empty?
    @teen_student_programs = TrackEventProgram.teen_division_programs + TrackEventProgram.parent_division_programs unless @teen_students.empty?
  end
  
  def select_program
    requested_school_class_id = params[:id].to_i
    unless instructor_assignment_verified? requested_school_class_id
      flash[:notice] = 'Attempt to sign up track event not authorized'
      redirect_to controller: '/home', action: :index
      return
    end
    @school_class = SchoolClass.find requested_school_class_id
    @student = Person.find params[:student_id].to_i
    @track_event_program = TrackEventProgram.find params[:program_id].to_i
    track_event_signup = @track_event_program.find_non_filler_signup_for @student
    if params[:checked_flag] == 'true'
      if track_event_signup.nil?
        track_event_signup = TrackEventSignup.new
        track_event_signup.track_event_program = @track_event_program
        track_event_signup.student = @student
        track_event_signup.save!
        @existing_signup = track_event_signup
        @student.create_jersey_number
      end
    else
      track_event_signup.destroy unless track_event_signup.nil?
    end
    render action: :one_student_track_event_signup, layout: 'ajax_layout'
  end
  
  def select_parent
    requested_school_class_id = params[:id].to_i
    unless instructor_assignment_verified? requested_school_class_id
      flash[:notice] = 'Attempt to sign up track event not authorized'
      redirect_to controller: '/home', action: :index
      return
    end
    @school_class = SchoolClass.find requested_school_class_id
    @student = Person.find params[:student_id].to_i
    @parent = Person.find params[:parent_id].to_i
    @track_event_program = TrackEventProgram.find params[:program_id].to_i
    track_event_signup = @track_event_program.find_non_filler_signup_for @student, @parent
    if params[:checked_flag] == 'true'
      if track_event_signup.nil?
        track_event_signup = TrackEventSignup.new
        track_event_signup.track_event_program = @track_event_program
        track_event_signup.student = @student
        track_event_signup.parent = @parent
        track_event_signup.save!
        @existing_signup = track_event_signup
        @parent.create_parent_jersey_number
      end
    else
      track_event_signup.destroy unless track_event_signup.nil?
    end
    render action: :one_parent_track_event_signup, layout: 'ajax_layout'
  end

  def assign_student_team_index
    @track_event_program = TrackEventProgram.find params[:id].to_i
    @gender = params[:gender]
    @track_event_signups = @track_event_program.track_event_signups.select { |signup| (signup.student.gender == @gender) && (!signup.filler?) }.sort
    @track_event_teams = @track_event_program.track_event_teams.select { |team| team.gender == @gender }.sort { |a, b| a.name <=> b.name }
    @filler_team = @track_event_teams.detect { |team| team.filler? }
  end

  def assign_parent_team_index
    @track_event_program = TrackEventProgram.find params[:id].to_i
    @track_event_signups = @track_event_program.track_event_signups.select { |signup| (!signup.filler?) }.sort
    @track_event_teams = @track_event_program.track_event_teams.sort { |a, b| a.name <=> b.name }
    @filler_team = @track_event_teams.detect { |team| team.filler? }
  end

  def create_team
    track_event_program = TrackEventProgram.find params[:id].to_i
    new_team = TrackEventTeam.new
    new_team.track_event_program = track_event_program
    new_team.name = params[:name]
    new_team.gender = params[:gender] unless track_event_program.parent_division?

    flash[:notice] = 'Error creating new team' unless new_team.save
    redirect_to_assign_team_index track_event_program, params[:gender]
  end

  def delete_team
    track_event_team = TrackEventTeam.find params[:id].to_i
    track_event_program = track_event_team.track_event_program
    track_event_team.destroy
    redirect_to_assign_team_index track_event_program, params[:gender]
  end

  def select_team
    @signup = TrackEventSignup.find params[:id].to_i
    if params[:selected_track_team_id].empty?
      @signup.track_event_team = nil
    else
      selected_track_team = TrackEventTeam.find params[:selected_track_team_id].to_i
      @signup.track_event_team = selected_track_team
    end
    @signup.save!
    @gender = params[:gender]
    if @gender.empty?
      @track_event_teams = @signup.track_event_program.track_event_teams
    else
      @track_event_teams = @signup.track_event_program.track_event_teams.select { |team| team.gender == @gender }
    end
    render action: :one_track_team_assignment, layout: 'ajax_layout'
  end

  def change_filler_team
    track_event_program = TrackEventProgram.find params[:id].to_i
    gender = params[:gender]
    existing_filler_team = track_event_program.find_filler_team_for_gender params[:gender]
    if params[:team][:filler].empty?
      unless existing_filler_team.nil?
        change_filler_team_with_signup_updates(existing_filler_team, nil, track_event_program, gender)
      end
    else
      filler_team = TrackEventTeam.find params[:team][:filler].to_i
      if filler_team.nil?
        flash[:notice] = 'Problem finding filler team to change to -- has it been deleted?'
      else
        change_filler_team_with_signup_updates(existing_filler_team, filler_team, track_event_program, gender)
      end
    end
    redirect_to_assign_team_index track_event_program, gender
  end

  def create_filler_signup
    track_event_program = TrackEventProgram.find params[:id].to_i
    gender = params[:gender]
    reference_signup = TrackEventSignup.find params[:filler][:signup_ref]
    new_filler_signup = TrackEventSignup.new
    new_filler_signup.track_event_program = track_event_program
    new_filler_signup.student = reference_signup.student
    new_filler_signup.parent = reference_signup.parent
    new_filler_signup.track_event_team = track_event_program.find_filler_team_for_gender gender
    new_filler_signup.filler = true

    flash[:notice] = 'Error creating new filler sign-up' unless new_filler_signup.save
    redirect_to_assign_team_index track_event_program, gender
  end

  def delete_filler_signup
    filler_signup = TrackEventSignup.find params[:id].to_i
    filler_signup.destroy
    redirect_to_assign_team_index filler_signup.track_event_program, params[:gender]
  end

  def calculate_lane_assignments
    next_run_order = 1
    TrackEventProgram.find_programs_by_sort_keys.each do |program|
      program.track_event_heats.clear
      next_run_order = program.create_heats(next_run_order)
    end
    flash[:notice] = 'Lane Assignment Calculation Completed'
    redirect_to action: :index
  end

  def lane_assignment_index
    @track_event_programs = TrackEventProgram.find_programs_by_sort_keys
  end

  def heat_view
    @heat = TrackEventHeat.find params[:id].to_i
    if @heat.track_event_program.individual_program?
      render action: :heat_view_individual
    else
      render action: :heat_view_relay
    end
  end

  def tocs_lane_assignment_form
    @lane_assignment_blocks = []
    tocs_program_groups = TrackEventProgram.find_tocs_programs_group_by_sort_keys
    tocs_program_groups.keys.sort.each do |sort_key|
      @lane_assignment_blocks << create_lane_assignment_blocks(tocs_program_groups[sort_key])
    end
    @lane_assignment_blocks = @lane_assignment_blocks.flatten.uniq.compact
    respond_to do |format|
      format.pdf {render layout: false}
    end
  end

  def tocs_track_event_data
    @track_event_signups = TrackEventSignup.find_tocs_track_event_signups
    respond_to do |format|
      format.csv {send_data tocs_track_event_data_csv, type: 'text/csv'}
    end
  end
  
  
  private

  def skip_instructor_assignment_verification
    @user.roles.any? do |role|
      role.name == Role::ROLE_NAME_SUPER_USER or 
      role.name == Role::ROLE_NAME_ACTIVITY_OFFICER
    end
  end

  def redirect_to_assign_team_index(track_event_program, gender)
    if track_event_program.parent_division?
      redirect_to action: :assign_parent_team_index, id: track_event_program
    else
      redirect_to action: :assign_student_team_index, id: track_event_program, gender: gender
    end
  end

  def move_filler_signup_to(new_team, track_event_program, gender)
    track_event_program.filler_signups_for_gender(gender).each do |signup|
      signup.track_event_team = new_team
      signup.save!
    end
  end

  def change_filler_team_with_signup_updates(old_team, new_team, track_event_program, gender)
    begin
      TrackEventTeam.transaction do
        move_filler_signup_to(new_team, track_event_program, gender)
        unless old_team.nil?
          old_team.filler = false
          old_team.save!
        end
        unless new_team.nil?
          new_team.filler = true
          new_team.save!
        end
      end
    rescue => e
      logger.error "Error changing filler team from #{old_team.nil? ? 'none' : old_team.id} to #{new_team.nil? ? 'none' : new_team.id} => #{e.inspect}"
      flash[:notice] = 'Error changing filler team'
    end
  end

  def tocs_track_event_data_csv
    CSV.generate do |csv|
      csv << ['Student Chinese Name','Student English First Name','Student English Last Name','Gender','Birth Month','School Class Name','Location','Jersey Number','Program ID','Program Name','Program Sort Key','Parent Name','Relay Team Group']
      @track_event_signups.each do |track_event_signup|
        row = []
        student = track_event_signup.student
        row << student.chinese_name
        row << student.english_first_name
        row << student.english_last_name
        row << student.gender
        row << student.birth_info
        school_class = student.student_class_assignment_for(SchoolYear.current_school_year).school_class
        row << school_class.name
        row << school_class.location
        row << JerseyNumber.find_jersey_number_for(student)
        row << track_event_signup.track_event_program.id
        row << track_event_signup.track_event_program.name
        row << track_event_signup.track_event_program.sort_key
        row << track_event_signup.parent.try(:name)
        row << track_event_signup.group_name
        csv << row
      end
    end
  end
  
  # def create_lane_assignment_blocks(tocs_programs)
  #   return [] if tocs_programs.empty?
  #
  #   tocs_program_ids = tocs_programs.collect { |tocs_program| tocs_program.id }
  #   track_event_signups = TrackEventSignup.all :conditions => ["track_event_program_id IN (#{tocs_program_ids.join(',')})"], :order => 'track_event_program_id ASC'
  #
  #   # All programs in the same group should have the same type and name
  #   sample_program = tocs_programs[0]
  #   if sample_program.name.start_with? 'Tug'
  #     create_lane_assignment_blocks_for_tug_of_war track_event_signups, sample_program
  #   elsif (sample_program.program_type == TrackEventProgram::PROGRAM_TYPE_STUDENT) or (sample_program.program_type == TrackEventProgram::PROGRAM_TYPE_PARENT)
  #     create_lane_assignment_blocks_for_individual_program track_event_signups, sample_program
  #   elsif sample_program.program_type == TrackEventProgram::PROGRAM_TYPE_STUDENT_RELAY
  #     if sample_program.mixed_gender?
  #       create_lane_assignment_blocks_for_unisex_student_relay_program track_event_signups, sample_program
  #     else
  #       create_lane_assignment_blocks_for_student_relay_program track_event_signups, sample_program
  #     end
  #   elsif sample_program.program_type == TrackEventProgram::PROGRAM_TYPE_PARENT_RELAY
  #     create_lane_assignment_blocks_for_parent_relay_program track_event_signups, sample_program
  #   end
  # end
  
  def create_lane_assignment_blocks_for_tug_of_war(track_event_signups, sample_program)
    tug_of_war_teams = Hash.new { |hash, key| hash[key] = [] }
    track_event_signups.each do |signup|
      student = signup.student
      school_class = student.student_class_assignment_for(SchoolYear.current_school_year).school_class
      tug_of_war_teams[school_class] << student
    end
    
    sorted_school_class_key = tug_of_war_teams.keys.sort do |a, b|
      grade_order = a.grade_id <=> b.grade_id
      if grade_order == 0
        a.short_name <=> b.short_name
      else
        grade_order
      end
    end
    
    current_lane_assignment_block = nil
    lane_assignment_blocks = []
    sorted_school_class_key.each do |school_class|
      if current_lane_assignment_block.nil?
        current_lane_assignment_block = LaneAssignmentBlock.new(sample_program, nil)
        lane_assignment_blocks << current_lane_assignment_block
      end
      current_lane_assignment_block.add_tug_of_war_team school_class, tug_of_war_teams[school_class]
      current_lane_assignment_block = nil if current_lane_assignment_block.full?
    end
    lane_assignment_blocks
  end

  def create_lane_assignment_blocks_for_individual_program(track_event_signups, sample_program)

    # Get all sign-ups sorted into correct order
    sorted_track_event_signups = track_event_signups.sort do |a, b|
      school_class_a = a.student.student_class_assignment_for(SchoolYear.current_school_year).school_class
      school_class_b = b.student.student_class_assignment_for(SchoolYear.current_school_year).school_class
      # This sorting relies on track event program ids go from low to high following grades from low to high
      program_order = a.track_event_program_id <=> b.track_event_program_id
      if program_order == 0
        # This sorting relies on grades having ids from low to high in order
        grade_order = school_class_a.grade_id <=> school_class_b.grade_id
        if grade_order == 0
          class_order = school_class_a.short_name <=> school_class_b.short_name
          if class_order == 0
            last_name_order = a.student.english_last_name <=> b.student.english_last_name
            if last_name_order == 0
              a.student.english_first_name <=> b.student.english_first_name
            else
              last_name_order
            end
          else
            class_order
          end
        else
          grade_order
        end
      else
        program_order
      end
    end

    female_program_heats = LaneAssignmentBlock::ProgramHeats.new sample_program, Person::GENDER_FEMALE
    male_program_heats = LaneAssignmentBlock::ProgramHeats.new sample_program, Person::GENDER_MALE
    sorted_track_event_signups.each do |signup|
      if sample_program.program_type == TrackEventProgram::PROGRAM_TYPE_PARENT
        participant = signup.parent
      else
        participant = signup.student
      end
      if participant.gender == Person::GENDER_FEMALE
        female_program_heats.add_lane signup
      else
        male_program_heats.add_lane signup
      end
    end

    [female_program_heats.create_lane_assignment_blocks, male_program_heats.create_lane_assignment_blocks]
  end
  
  def create_lane_assignment_blocks_for_unisex_student_relay_program(track_event_signups, sample_program)
    relay_teams = {}
    track_event_signups.each do |signup|
      student = signup.student
      school_class = student.student_class_assignment_for(SchoolYear.current_school_year).school_class
      team_identifier = "#{school_class.short_name} #{signup.group_name}"
      team = relay_teams[team_identifier]
      if team.nil?
        team = LaneAssignmentBlock::RelayTeam.new school_class, signup.group_name, sample_program.relay_team_size
        relay_teams[team.identifier] = team
      end
      team.add_runner student
    end
    create_lane_assignment_blocks_for_student_relay(relay_teams, sample_program, nil)
  end
  
  def create_lane_assignment_blocks_for_student_relay_program(track_event_signups, sample_program)
    female_relay_teams = {}
    male_relay_teams = {}
    track_event_signups.each do |signup|
      student = signup.student
      school_class = student.student_class_assignment_for(SchoolYear.current_school_year).school_class
      team_identifier = "#{school_class.short_name} #{signup.group_name}"
      if student.gender == Person::GENDER_FEMALE
        team = female_relay_teams[team_identifier]
        if team.nil?
          team = LaneAssignmentBlock::RelayTeam.new school_class, signup.group_name, sample_program.relay_team_size
          female_relay_teams[team.identifier] = team
        end
      else
        team = male_relay_teams[team_identifier]
        if team.nil?
          team = LaneAssignmentBlock::RelayTeam.new school_class, signup.group_name, sample_program.relay_team_size
          male_relay_teams[team.identifier] = team
        end
      end
      team.add_runner student
    end
    
    [ create_lane_assignment_blocks_for_student_relay(female_relay_teams, sample_program, Person::GENDER_FEMALE),
      create_lane_assignment_blocks_for_student_relay(male_relay_teams, sample_program, Person::GENDER_MALE) ]
  end
  
  def create_lane_assignment_blocks_for_student_relay(relay_teams, sample_program, gender)
    sorted_team_identifiers = relay_teams.keys.sort do |a, b|
      grade_order = relay_teams[a].school_class.grade_id <=> relay_teams[b].school_class.grade_id
      if grade_order == 0
        relay_teams[a].identifier <=> relay_teams[b].identifier
      else
        grade_order
      end
    end

    program_heats = LaneAssignmentBlock::ProgramHeats.new sample_program, gender
    sorted_team_identifiers.each do |team_identifier|
      program_heats.add_lane relay_teams[team_identifier]
    end

    program_heats.create_lane_assignment_blocks
  end
  
  def create_lane_assignment_blocks_for_parent_relay_program(track_event_signups, sample_program)
    current_female_relay_team = nil
    female_relay_teams = []
    current_male_relay_team = nil
    male_relay_teams = []
    track_event_signups.each do |signup|
      parent = signup.parent
      if parent.gender == Person::GENDER_FEMALE
        if current_female_relay_team.nil?
          current_female_relay_team = []
          female_relay_teams << current_female_relay_team
        end
        current_female_relay_team << parent
        current_female_relay_team = nil if current_female_relay_team.size >= sample_program.relay_team_size
      else
        if current_male_relay_team.nil?
          current_male_relay_team = []
          male_relay_teams << current_male_relay_team
        end
        current_male_relay_team << parent
        current_male_relay_team = nil if current_male_relay_team.size >= sample_program.relay_team_size
      end
    end
    
    [ create_lane_assignment_blocks_for_parent_relay(female_relay_teams, Person::GENDER_FEMALE, sample_program), 
      create_lane_assignment_blocks_for_parent_relay(male_relay_teams, Person::GENDER_MALE, sample_program) ]
  end
  
  def create_lane_assignment_blocks_for_parent_relay(relay_teams, gender, sample_program)
    current_lane_assignment_block = nil
    lane_assignment_blocks = []
    relay_teams.each do |relay_team|
      if current_lane_assignment_block.nil?
        current_lane_assignment_block = LaneAssignmentBlock.new(sample_program, gender)
        lane_assignment_blocks << current_lane_assignment_block
      end
      current_lane_assignment_block.add_relay_team relay_team
      current_lane_assignment_block = nil if current_lane_assignment_block.full?
    end
    lane_assignment_blocks
  end
end
