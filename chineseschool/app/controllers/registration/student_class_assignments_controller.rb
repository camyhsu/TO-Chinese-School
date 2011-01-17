class Registration::StudentClassAssignmentsController < ApplicationController

  verify :only => [:remove_from_grade, :select_school_class, :select_elective_class] , :method => :post,
      :add_flash => {:notice => 'Illegal GET'}, :redirect_to => {:controller => '/signout', :action => 'index'}


  def list_by_grade
    @grade = Grade.find_by_id params[:grade][:id]
    render :layout => 'jquery_datatable'
  end

  def list_active_students_by_name
    @active_student_class_assignments = StudentClassAssignment.all(:conditions => 'school_class_id is not null')
    @active_student_class_assignments.sort! do |a, b|
      last_name_order = a.student.english_last_name <=> b.student.english_last_name
      if last_name_order == 0
        a.student.english_first_name <=> b.student.english_first_name
      else
        last_name_order
      end
    end
  end

  def destroy
    StudentClassAssignment.destroy params[:id].to_i
    render :text => 'destroy_successful'
  end

  def select_school_class
    @student_class_assignment = StudentClassAssignment.find_by_id params[:id].to_i
    selected_school_class = SchoolClass.find_by_id params[:selected_class_id]
    @student_class_assignment.school_class = selected_school_class
    @student_class_assignment.save!
    render :action => :one_student_class_assignment, :layout => 'ajax_layout'
  end

  def select_elective_class
    @student_class_assignment = StudentClassAssignment.find_by_id params[:id].to_i
    selected_elective_class = SchoolClass.find_by_id params[:selected_class_id]
    @student_class_assignment.elective_class = selected_elective_class
    @student_class_assignment.save!
    render :action => :one_student_class_assignment, :layout => 'ajax_layout'
  end
end
