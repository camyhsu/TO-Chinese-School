class Registration::StudentClassAssignmentsController < ApplicationController

  #verify :only => [:destroy, :select_school_class, :select_elective_class] , :method => :post,
  #    :add_flash => {:notice => 'Illegal GET'}, :redirect_to => {:controller => '/signout', :action => 'index'}


  def student_list_by_class
    @current_school_year = SchoolYear.current_school_year
    if params[:elective]
      retrieve_sorted_elective_class_lists
      @filename = 'student_list_by_elective_class.pdf'
    else
      retrieve_sorted_class_lists
      @filename = 'student_list_by_class.pdf'
    end
    respond_to do |format|
      format.pdf {render layout: false}
    end
  end

  def list_active_students_by_name
    @current_school_year = SchoolYear.current_school_year
    @active_student_class_assignments = StudentClassAssignment.all(conditions: ['school_class_id is not null AND school_year_id = ?', SchoolYear.current_school_year.id])
    @active_student_class_assignments.sort! do |a, b|
      last_name_order = a.student.english_last_name.strip.downcase <=> b.student.english_last_name.strip.downcase
      if last_name_order == 0
        a.student.english_first_name.strip.downcase <=> b.student.english_first_name.strip.downcase
      else
        last_name_order
      end
    end
    respond_to do |format|
      format.html
      format.pdf {render layout: false}
    end
  end

  def destroy
    StudentClassAssignment.destroy params[:id].to_i
    render text: 'destroy_successful'
  end
  
  def random_assign_grade_class
    current_school_year = SchoolYear.current_school_year
    Grade.all.each { |grade| grade.random_assign_grade_class current_school_year }
    flash[:notice] = 'Random grade class assignment completed successfully'
    redirect_to controller: '/home'
  end
end
