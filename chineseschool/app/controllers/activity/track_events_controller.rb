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
    @filler_signups = TrackEventSignup.find_filler_signups_for @school_class.students
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
    elsif @heat.track_event_program.group_program?
      # Tug of War is the only group program
      @winner = @heat.track_event_teams.detect { |team| team.pair_winner? }
      render action: :heat_view_tug_of_war
    else
      render action: :heat_view_relay
    end
  end

  def save_track_time
    # track time is in unit of 10ms
    heat = TrackEventHeat.find params[:id].to_i
    if heat.track_event_program.individual_program?
      heat.track_event_signups.each { |signup| save_track_time_for signup }
    else
      heat.track_event_teams.each { |team| save_track_time_for team }
    end
    flash[:notice] = 'Track Time Saved'
    redirect_to action: :heat_view, id: heat
  end

  def save_winner_tug_of_war
    heat = TrackEventHeat.find params[:id].to_i
    existing_winner = heat.track_event_teams.detect { |team| team.pair_winner? }
    if params[:tug_of_war][:winner].empty?
      change_pair_winner(existing_winner, nil)
    else
      new_winner = TrackEventTeam.find params[:tug_of_war][:winner].to_i
      if new_winner.nil?
        flash[:notice] = 'Problem finding winner to change to -- has it been deleted?'
      else
        change_pair_winner(existing_winner, new_winner)
      end
    end
    flash[:notice] = 'Tug of War Winner Saved'
    redirect_to action: :heat_view, id: heat
  end

  def view_scores
    @track_event_program = TrackEventProgram.find params[:id].to_i
    # View scores is not implemented for group program due to the complication of final matches
    # We currently guard against this by not showing the button for the UI
    # If this controller action is called with a group program, it would be garbage output using student relay code
    if @track_event_program.individual_program?
      if @track_event_program.parent_division?
        @score_map = @track_event_program.map_scores_for_parent_individual
        render action: :view_scores_parent_individual
      else
        @score_map = @track_event_program.map_scores_for_student_individual
        render action: :view_scores_student_individual
      end
    else
      if @track_event_program.parent_division?
        @score_map = @track_event_program.map_scores_for_parent_relay
        render action: :view_scores_parent_relay
      else
        @score_map = @track_event_program.map_scores_for_student_relay
        render action: :view_scores_student_relay
      end
    end

  end

  def calculate_scores
    track_event_program = TrackEventProgram.find params[:id].to_i
    # Calculate scores is not implemented for group program due to the complication of fina matches
    # We currently guard against this by not showing the button for the UI
    # If this controller action is called with a group program, it would be garbage output using student relay code
    if track_event_program.individual_program?
      if track_event_program.parent_division?
        track_event_program.calculate_scores_for_parent_individual
      else
        track_event_program.calculate_scores_for_student_individual
      end
    else
      if track_event_program.parent_division?
        track_event_program.calculate_scores_for_parent_relay
      else
        track_event_program.calculate_scores_for_student_relay
      end
    end
    flash[:notice] = 'Score Calculation Completed'
    redirect_to action: :view_scores, id: track_event_program
  end

  def view_class_scores
    @active_grade_classes = SchoolClass.find_all_active_grade_classes
    @active_grade_classes.sort! do |x, y|
      grade_order = x.grade_id <=> y.grade_id
      if grade_order == 0
        x.short_name <=> y.short_name
      else
        grade_order
      end
    end
  end

  def tocs_lane_assignment_form
    @track_event_programs = TrackEventProgram.find_programs_by_sort_keys
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

  def save_track_time_for(lane_unit)
    track_time_input = params["track_time_#{lane_unit.id}"]
    if track_time_input.empty?
      lane_unit.track_time = nil
    else
      lane_unit.track_time = (track_time_input.to_d * 100).to_i
    end
    lane_unit.save
  end

  def change_pair_winner(old_winner, new_winner)
    return if old_winner == new_winner
    begin
      TrackEventTeam.transaction do
        unless old_winner.nil?
          old_winner.pair_winner = false
          old_winner.save!
        end
        unless new_winner.nil?
          new_winner.pair_winner = true
          new_winner.save!
        end
      end
    rescue => e
      logger.error "Error changing winner from #{old_winner.nil? ? 'none' : old_winner.id} to #{new_winner.nil? ? 'none' : new_winner.id} => #{e.inspect}"
      flash[:notice] = 'Error changing tug of war winner'
    end
  end

  def tocs_track_event_data_csv
    CSV.generate do |csv|
      csv << ['Student Chinese Name','Student English First Name','Student English Last Name','Gender','Birth Month','School Class Name','Location','Jersey Number','Program ID','Program Name','Program Sort Key','Parent Name','Relay Team', 'Filler Sign-up']
      @track_event_signups.each do |signup|
        row = []
        student = signup.student
        row << student.chinese_name
        row << student.english_first_name
        row << student.english_last_name
        row << student.gender
        row << student.birth_info
        school_class = student.student_class_assignment_for(SchoolYear.current_school_year).school_class
        row << school_class.name
        row << school_class.location
        row << JerseyNumber.find_jersey_number_for(student)
        row << signup.track_event_program.id
        row << signup.track_event_program.name
        row << signup.track_event_program.sort_key
        row << signup.parent.try(:name)
        row << signup.try(:track_event_team).try(:name)
        row << (signup.filler? ? 'YES' : 'NO')
        csv << row
      end
    end
  end
end
