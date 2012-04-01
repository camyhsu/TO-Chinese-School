class Activity::TrackEventsController < ApplicationController
  
  def index
    @active_grade_classes = SchoolClass.find_all_active_grade_classes
    @active_grade_classes.sort! { |x, y| x.grade_id <=> y.grade_id }
  end
  
  def sign_up
    requested_school_class_id = params[:id].to_i
    unless instructor_assignment_verified? requested_school_class_id
      flash[:notice] = "Access to requested track event sign up not authorized"
      redirect_to :controller => '/home', :action => :index
      return
    end
    @school_class = SchoolClass.find_by_id requested_school_class_id
    @track_event_programs = TrackEventProgram.find_by_grade @school_class.grade
  end
  
  def sign_up_result
    requested_school_class_id = params[:id].to_i
    unless instructor_assignment_verified? requested_school_class_id
      flash[:notice] = "Access to requested track event sign up result not authorized"
      redirect_to :controller => '/home', :action => :index
      return
    end
    @school_class = SchoolClass.find_by_id requested_school_class_id
    @track_event_programs = TrackEventProgram.find_by_grade @school_class.grade
  end
  
  def printable_sign_up_form
    requested_school_class_id = params[:id].to_i
    unless instructor_assignment_verified? requested_school_class_id
      flash[:notice] = "Access to requested track event sign up form not authorized"
      redirect_to :controller => '/home', :action => :index
      return
    end
    @school_class = SchoolClass.find_by_id requested_school_class_id
    @track_event_programs = TrackEventProgram.find_by_grade @school_class.grade
    render :layout => 'ajax_layout'
  end
  
  def select_program
    requested_school_class_id = params[:id].to_i
    unless instructor_assignment_verified? requested_school_class_id
      flash[:notice] = "Attempt to sign up track event not authorized"
      redirect_to :controller => '/home', :action => :index
      return
    end
    @school_class = SchoolClass.find_by_id requested_school_class_id
    @student = Person.find_by_id params[:student_id].to_i
    track_event_program = TrackEventProgram.find_by_id params[:program_id].to_i
    track_event_signup = TrackEventSignup.find_by_student_id_and_track_event_program_id @student.id, track_event_program.id
    if params[:checked_flag] == 'true'
      if track_event_signup.nil?
        track_event_signup = TrackEventSignup.new
        track_event_signup.track_event_program = track_event_program
        track_event_signup.student = @student
        track_event_signup.save!
      end
    else
      track_event_signup.destroy unless track_event_signup.nil?
    end
    @track_event_programs = TrackEventProgram.find_by_grade @school_class.grade
    render :action => :one_student_sign_up, :layout => 'ajax_layout'
  end
  
  def select_relay_group
    requested_school_class_id = params[:id].to_i
    unless instructor_assignment_verified? requested_school_class_id
      flash[:notice] = "Attempt to sign up track event not authorized"
      redirect_to :controller => '/home', :action => :index
      return
    end
    @school_class = SchoolClass.find_by_id requested_school_class_id
    @student = Person.find_by_id params[:student_id].to_i
    track_event_program = TrackEventProgram.find_by_id params[:program_id].to_i
    selected_relay_group = params[:selected_relay_group]
    track_event_signup = TrackEventSignup.find_by_student_id_and_track_event_program_id @student.id, track_event_program.id
    if selected_relay_group == ''
      track_event_signup.destroy unless track_event_signup.nil?
    else
      if track_event_signup.nil?
        track_event_signup = TrackEventSignup.new
        track_event_signup.track_event_program = track_event_program
        track_event_signup.student = @student
      end
      track_event_signup.group_name = selected_relay_group
      track_event_signup.save!
    end
    @track_event_programs = TrackEventProgram.find_by_grade @school_class.grade
    render :action => :one_student_sign_up, :layout => 'ajax_layout'
  end
  
  def select_parent
    requested_school_class_id = params[:id].to_i
    unless instructor_assignment_verified? requested_school_class_id
      flash[:notice] = "Attempt to sign up track event not authorized"
      redirect_to :controller => '/home', :action => :index
      return
    end
    @school_class = SchoolClass.find_by_id requested_school_class_id
    @student = Person.find_by_id params[:student_id].to_i
    track_event_program = TrackEventProgram.find_by_id params[:program_id].to_i
    track_event_signup = TrackEventSignup.find_by_student_id_and_parent_id_and_track_event_program_id @student.id, params[:parent_id].to_i, track_event_program.id
    if params[:checked_flag] == 'true'
      if track_event_signup.nil?
        track_event_signup = TrackEventSignup.new
        track_event_signup.track_event_program = track_event_program
        track_event_signup.student = @student
        track_event_signup.parent = Person.find_by_id params[:parent_id].to_i
        track_event_signup.save!
      end
    else
      track_event_signup.destroy unless track_event_signup.nil?
    end
    @track_event_programs = TrackEventProgram.find_by_grade @school_class.grade
    render :action => :one_student_sign_up, :layout => 'ajax_layout'
  end
  
  def tocs_lane_assignment_form
    @lane_assignment_blocks = []
    tocs_program_groups = TrackEventProgram.find_tocs_programs_group_by_sort_keys
    tocs_program_groups.keys.sort.each do |sort_key|
      @lane_assignment_blocks << create_lane_assignment_blocks(tocs_program_groups[sort_key])
    end
    @lane_assignment_blocks = @lane_assignment_blocks.flatten.uniq.compact
    prawnto :filename => 'lane_assignment_forms.pdf'
    render :layout => false
  end
  
  
  private

  def skip_instructor_assignment_verification
    @user.roles.any? do |role|
      role.name == Role::ROLE_NAME_SUPER_USER or 
      role.name == Role::ROLE_NAME_ACTIVITY_OFFICER
    end
  end
  
  def create_lane_assignment_blocks(tocs_programs)
    return [] if tocs_programs.empty?
    
    tocs_program_ids = tocs_programs.collect { |tocs_program| tocs_program.id }
    track_event_signups = TrackEventSignup.all :conditions => ["track_event_program_id IN (#{tocs_program_ids.join(',')})"], :order => 'track_event_program_id ASC'
    
    # All programs in the same groupd should have the same type and name
    sample_program = tocs_programs[0]
    puts sample_program.name
    puts track_event_signups.inspect
    if sample_program.name.start_with? 'Tug'
      create_lane_assignment_blocks_for_tug_of_war track_event_signups, sample_program
    elsif (sample_program.program_type == TrackEventProgram::PROGRAM_TYPE_STUDENT) or (sample_program.program_type == TrackEventProgram::PROGRAM_TYPE_PARENT)
      create_lane_assignment_blocks_for_individual_program track_event_signups, sample_program
    elsif sample_program.program_type == TrackEventProgram::PROGRAM_TYPE_STUDENT_RELAY
      create_lane_assignment_blocks_for_student_relay_program track_event_signups, sample_program
    end
  end
  
  def create_lane_assignment_blocks_for_tug_of_war(track_event_signups, sample_program)
    # temporary place holder
    create_lane_assignment_blocks_for_individual_program track_event_signups, sample_program
  end
  
  def create_lane_assignment_blocks_for_individual_program(track_event_signups, sample_program)
    current_female_lane_assignment_block = nil
    female_lane_assignment_blocks = []
    current_male_lane_assignment_block = nil
    male_lane_assignment_blocks = []
    track_event_signups.each do |signup|
      if sample_program.program_type == TrackEventProgram::PROGRAM_TYPE_PARENT
        participant = signup.parent
      else
        participant = signup.student
      end
      if participant.gender == Person::GENDER_FEMALE
        if current_female_lane_assignment_block.nil?
          current_female_lane_assignment_block = LaneAssignmentBlock.new(sample_program.name, Person::GENDER_FEMALE, sample_program.program_type)
          female_lane_assignment_blocks << current_female_lane_assignment_block
        end
        current_female_lane_assignment_block.add_lane signup
        if current_female_lane_assignment_block.full?
          current_female_lane_assignment_block = nil
        end
      else
        if current_male_lane_assignment_block.nil?
          current_male_lane_assignment_block = LaneAssignmentBlock.new(sample_program.name, Person::GENDER_MALE, sample_program.program_type)
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
  
  def create_lane_assignment_blocks_for_student_relay_program(track_event_signups, sample_program)
    
  end
  
  
end
