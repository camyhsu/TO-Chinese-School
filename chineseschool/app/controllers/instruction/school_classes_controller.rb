# encoding: utf-8
class Instruction::SchoolClassesController < ApplicationController

  def show
    requested_school_class_id = params[:id].to_i
    unless instructor_assignment_verified? requested_school_class_id
      flash[:notice] = 'Access to requested school class list not authorized'
      redirect_to controller: '/home'
      return
    end
    @school_class = SchoolClass.find requested_school_class_id
    if params[:school_year_id].nil?
      @school_year = SchoolYear.current_school_year
    else
      @school_year = SchoolYear.find params[:school_year_id].to_i
    end
  end

  def enter_student_final_mark
    requested_school_class_id = params[:id].to_i
    unless instructor_assignment_verified? requested_school_class_id
      flash[:notice] = 'Access to requested track event sign up not authorized'
      redirect_to controller: '/home'
      return
    end
    @school_class = SchoolClass.find requested_school_class_id
    @school_year = SchoolYear.current_school_year
    retrieve_student_final_marks_for_class

    if request.post? || request.put?
      @school_class.students(@school_year).each do |student|
        mark = @student_to_mark_map[student]
        mark.top_three = params["top_three_#{student.id}"]
        mark.progress_award = (params["progress_award_#{student.id}"] == 'true')
        mark.spirit_award = (params["spirit_award_#{student.id}"] == 'true')
        mark.attendance_award = (params["attendance_award_#{student.id}"] == 'true')
        mark.total_score = params["total_score_#{student.id}"]
        mark.save
        if mark.errors.any?
          prettify_validation_messages_for mark
        end
      end
    end
  end

  def show_student_final_mark
    requested_school_class_id = params[:id].to_i
    unless instructor_assignment_verified? requested_school_class_id
      flash[:notice] = 'Access to requested track event sign up not authorized'
      redirect_to controller: '/home'
      return
    end
    @school_class = SchoolClass.find requested_school_class_id
    @school_year = SchoolYear.current_school_year
    retrieve_student_final_marks_for_class
  end

  
  def display_room_parent_selection
    requested_school_class_id = params[:id].to_i
    return if not_authorized_instructor_for? requested_school_class_id
    @school_class = SchoolClass.find requested_school_class_id
    render layout: 'ajax_layout'
  end

  def save_room_parent_selection
    requested_school_class_id = params[:id].to_i
    return if not_authorized_instructor_for? requested_school_class_id
    @school_class = SchoolClass.find requested_school_class_id
    InstructorAssignment.change_room_parent @school_class, params[:room_parent_id].to_i
    render action: 'current_room_parent_display', layout: 'ajax_layout'
  end

  def cancel_room_parent_selection
    requested_school_class_id = params[:id].to_i
    return if not_authorized_instructor_for? requested_school_class_id
    @school_class = SchoolClass.find requested_school_class_id
    render action: 'current_room_parent_display', layout: 'ajax_layout'
  end


  private

  def retrieve_student_final_marks_for_class
    @student_to_mark_map = {}
    StudentFinalMark.find_all_by_school_year_id_and_school_class_id(@school_year.id, @school_class.id).each do |mark|
      @student_to_mark_map[mark.student] = mark
    end
    # make sure all students have mark before ui rendering
    @school_class.students(@school_year).each do |student|
      mark = @student_to_mark_map[student]
      if mark.nil?
        mark = StudentFinalMark.create(school_class: @school_class, school_year: @school_year, student: student)
        @student_to_mark_map[student] = mark
      end
    end
  end

  def prettify_validation_messages_for(mark)
    if mark.errors[:top_three].any?
      mark.errors[:base] = '前三名 must be 1, 2, or 3'
      mark.top_three = nil
    end
    if mark.errors[:total_score].any?
      mark.errors[:base] = '總成績 must be a number greater than 0'
      mark.total_score = nil
    end
  end

  def skip_instructor_assignment_verification
    @user.roles.any? do |role|
      role.name == Role::ROLE_NAME_SUPER_USER or
      role.name == Role::ROLE_NAME_PRINCIPAL or
      role.name == Role::ROLE_NAME_ACADEMIC_VICE_PRINCIPAL or
      role.name == Role::ROLE_NAME_REGISTRATION_OFFICER or 
      role.name == Role::ROLE_NAME_INSTRUCTION_OFFICER or 
      role.name == Role::ROLE_NAME_ACTIVITY_OFFICER
    end
  end

  def not_authorized_instructor_for?(school_class_id)
    unless instructor_assignment_verified? school_class_id
      unless user_is_an_instructor? school_class_id
        flash[:notice] = 'Access to requested room parent selection not authorized'
        redirect_to :controller => '/home'
        return true
      end
    end
    false
  end
  
  def user_is_an_instructor?(school_class_id)
    @user.person.instructor_assignments_for(SchoolYear.current_school_year).any? do |instructor_assignment|
      if instructor_assignment.school_class.id == school_class_id
        instructor_assignment.role_is_an_instructor?
      else
        false
      end
    end
  end
end
