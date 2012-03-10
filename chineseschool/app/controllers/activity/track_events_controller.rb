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
    if params[:checked_flag] == 'true'
      track_event_signup = TrackEventSignup.new
      track_event_signup.track_event_program = track_event_program
      track_event_signup.student = @student
      track_event_signup.save!
    else
      track_event_signup = TrackEventSignup.find_by_student_id_and_track_event_program_id @student.id, track_event_program.id
      track_event_signup.destroy
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
    if params[:checked_flag] == 'true'
      track_event_signup = TrackEventSignup.new
      track_event_signup.track_event_program = track_event_program
      track_event_signup.student = @student
      track_event_signup.parent = Person.find_by_id params[:parent_id].to_i
      track_event_signup.save!
    else
      track_event_signup = TrackEventSignup.find_by_student_id_and_parent_id_and_track_event_program_id @student.id, params[:parent_id].to_i, track_event_program.id
      track_event_signup.destroy
    end
    @track_event_programs = TrackEventProgram.find_by_grade @school_class.grade
    render :action => :one_student_sign_up, :layout => 'ajax_layout'
  end
  
  
  private

  def skip_instructor_assignment_verification
    @user.roles.any? do |role|
      role.name == Role::ROLE_NAME_SUPER_USER or 
      role.name == Role::ROLE_NAME_ACTIVITY_OFFICER
    end
  end
end
