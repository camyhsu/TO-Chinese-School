class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :check_authentication, :check_authorization

  protected

  def check_authentication
    return true if session[:user_id]
    session[:original_uri] = request.fullpath
    redirect_to controller: '/signin', action: 'index'
    false
  end

  def check_authorization
    find_user_in_session
    logger.info "Authorizing: user => #{@user.id} | controller_path => #{controller_path} | action_name => #{action_name}"
    return true if @user.authorized?(controller_path, action_name)
    flash[:notice] = 'You are not authorized to view the page you requested'
    if request.env['HTTP_REFERER']
      redirect_to :back
    else
      redirect_to :controller => '/home', :action => 'index'
    end
    false
  end

  def find_user_in_session
    @user = User.find(session[:user_id])
  end

  private

  def parse_date(input)
    return nil if input.blank?
    Date.parse input
  end

  def find_possible_students
    possible_students = []
    @user.person.families.each do |family|
      possible_students += family.children
    end
    possible_students
  end

  # This method uses a method skip_instructor_assignment_verification implemented
  # by subclasses
  def instructor_assignment_verified?(requested_school_class_id)
    return true if skip_instructor_assignment_verification
    @user.person.instructor_assignments_for(SchoolYear.current_school_year).any? do |instructor_assignment|
      instructor_assignment.school_class.id == requested_school_class_id
    end
  end

  def retrieve_sorted_class_lists
    active_student_class_assignments = StudentClassAssignment.all(:conditions => ['school_class_id IS NOT NULL AND school_year_id = ?', SchoolYear.current_school_year.id])
    @class_lists = Hash.new { |hash, key| hash[key] = [] }
    active_student_class_assignments.each do |student_class_assignment|
      @class_lists[student_class_assignment.school_class] << student_class_assignment.student
    end
    sort_class_name_lists
    @sorted_school_classes = @class_lists.keys.sort { |a, b| a.short_name <=> b.short_name }
  end

  def retrieve_sorted_elective_class_lists
    active_student_class_assignments = StudentClassAssignment.all(:conditions => ['elective_class_id IS NOT NULL AND school_year_id = ?', SchoolYear.current_school_year.id])
    @class_lists = Hash.new { |hash, key| hash[key] = [] }
    active_student_class_assignments.each do |student_class_assignment|
      @class_lists[student_class_assignment.elective_class] << student_class_assignment.student
    end
    sort_class_name_lists
    @sorted_school_classes = @class_lists.keys.sort { |a, b| a.english_name <=> b.english_name }
  end

  def sort_class_name_lists
    @class_lists.each_value do |class_list|
      class_list.sort! do |a, b|
        last_name_order = a.english_last_name.strip.downcase <=> b.english_last_name.strip.downcase
        if last_name_order == 0
          a.english_first_name.strip.downcase <=> b.english_first_name.strip.downcase
        else
          last_name_order
        end
      end
    end
  end
end
