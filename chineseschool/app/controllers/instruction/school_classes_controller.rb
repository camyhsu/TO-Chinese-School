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
        mark.talent_award = (params["talent_award_#{student.id}"] == 'true')
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

  def download_student_final_marks
    retrieve_sorted_class_lists
    @student_to_mark_map = {}
    StudentFinalMark.find_all_by_school_year_id(SchoolYear.current_school_year.id).each do |mark|
      @student_to_mark_map[mark.student] = mark
    end
    respond_to do |format|
      format.csv {send_data students_final_marks_csv, type: 'text/csv'}
    end
  end

  def previous_student_final_marks
    # we only have student final marks data starting school year 2016-2017
    # list 4 previous school years excluding the current one
    @included_school_years = SchoolYear.where('id > 8 AND id < ?', SchoolYear.current_school_year.id).order('id DESC').limit(4)
    included_school_year_ids = @included_school_years.collect { |school_year| school_year.id }
    student_final_marks = StudentFinalMark.where(:school_year_id => included_school_year_ids)
    @student_to_total_scores_map = {}
    student_final_marks.each do |student_final_mark|
      total_scores = @student_to_total_scores_map[student_final_mark.student]
      if total_scores.nil?
        total_scores = {}
        @student_to_total_scores_map[student_final_mark.student] = total_scores
      end
      total_scores[student_final_mark.school_year] = student_final_mark.total_score
    end
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
      mark.errors[:base] = '總成績 must be a number, 0 or greater'
      mark.total_score = nil
    end
  end

  def students_final_marks_csv
    CSV.generate do |csv|
      csv << ['Class Short Name', 'English First Name', 'English Last Name', 'Chinese Name', '前三名', '進步獎', '精神獎', '全勤獎', '博雄學藝獎']
      @sorted_school_classes.each do |school_class|
        @class_lists[school_class].each do |student|
          row = []
          row << school_class.short_name
          row << student.english_first_name
          row << student.english_last_name
          row << student.chinese_name
          append_student_final_mark_fields row, student
          csv << row
        end
      end
    end
  end

  def append_student_final_mark_fields(row, student)
    mark = @student_to_mark_map[student]
    if mark.nil?
      row << ''
      row << ''
      row << ''
      row << ''
    else
      row << (mark.top_three.nil? ? '' : mark.top_three)
      row << mark.progress_award
      row << mark.spirit_award
      row << mark.attendance_award
      row << mark.talent_award
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
