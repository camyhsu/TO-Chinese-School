# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  
  before_filter :ssl_required
  before_filter :check_authentication, :check_authorization
  

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password, :credit_card


  protected

  def ssl_required
    if RAILS_ENV == 'production'
      if request.ssl?
        return true
      else
        redirect_to("https://www.to-cs.org" + request.request_uri) and return false
      end
    end
  end

  def check_authentication
    if session[:user_id]
      return true
    else
      session[:original_uri] = request.request_uri
      redirect_to :controller => '/signin', :action => 'index' and return false
    end
  end

  def check_authorization
    find_user_in_session
    logger.info "Authorizing: user => #{@user.id} | controller_path => #{controller_path} | action_name => #{action_name}"
    if @user.authorized?(controller_path, action_name)
      return true
    else
      flash[:notice] = 'You are not authorized to view the page you requested'
      if request.env['HTTP_REFERER']
        redirect_to :back and return false
      else
        redirect_to :controller => '/home', :action => 'index' and return false
      end
    end
  end

  def find_user_in_session
    @user = User.find(session[:user_id])
  end

  private

  def parse_date(input)
    return nil if input.blank?
    return Date.parse input
  end
  
  def extract_pacific_date_from(utc_time)
    utc_time.in_time_zone('Pacific Time (US & Canada)').to_date
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
    active_student_class_assignments = StudentClassAssignment.all(:conditions => ['school_class_id is not null AND school_year_id = ?', SchoolYear.current_school_year.id])
    @class_lists = Hash.new { |hash, key| hash[key] = [] }
    active_student_class_assignments.each do |student_class_assignment|
      @class_lists[student_class_assignment.school_class] << student_class_assignment.student
    end
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
    @sorted_school_classes = @class_lists.keys.sort { |a, b| a.short_name <=> b.short_name }
  end
end
