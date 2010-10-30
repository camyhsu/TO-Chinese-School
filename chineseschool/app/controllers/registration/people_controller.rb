class Registration::PeopleController < ApplicationController

  verify :only => [:select_grade, :select_school_class, :select_elective_class] , :method => :post,
      :add_flash => {:notice => 'Illegal GET'}, :redirect_to => {:controller => '/signout', :action => 'index'}


  def index
    @people = Person.find(:all)
    render :layout => 'jquery_datatable'
  end

  def show
    @person = Person.find_by_id params[:id].to_i
  end

  def edit
    @person = Person.find_by_id params[:id].to_i
    if request.post?
      if @person.update_attributes params[:person]
        flash[:notice] = 'Person updated successfully'
        redirect_to :action => :show, :id => @person.id
      end
    end
  end

  def new_address
    @person = Person.find_by_id params[:id].to_i
    if request.post?
      @address = Address.new params[:address]
      return unless @address.valid?
      @address.save!
      @person.address = @address
      @person.save!
      flash[:notice] = 'Personal address created successfully'
      redirect_to :action => :show, :id => @person.id
    else
      @address = @person.families.first.address
    end
  end

  def edit_address
    @person = Person.find_by_id params[:id].to_i
    @address = @person.address
    if request.post?
      if @address.update_attributes params[:address]
        flash[:notice] = 'Personal address updated successfully'
        redirect_to :action => :show, :id => @person.id
      end
    end
  end

  def select_grade
    if params[:selected_grade_id].blank?
      unless params[:id].blank?
        # selected blank grade but has a previous student class assignment
        StudentClassAssignment.destroy params[:id].to_i
        @student_id = params[:student_id]
      end
    else
      if params[:id].blank?
        # selected a new grade without a previous student class assignment
        @student_class_assignment = StudentClassAssignment.new
        @student_class_assignment.student = Person.find_by_id params[:student_id].to_i
      else
        @student_class_assignment = StudentClassAssignment.find_by_id params[:id].to_i
      end
      @student_class_assignment.grade = Grade.find_by_id params[:selected_grade_id]
      @student_class_assignment.school_class = nil
      @student_class_assignment.elective_class = nil
      @student_class_assignment.save!
      @student_id = @student_class_assignment.student.id
    end
    render :action => :one_student_class_assignment, :layout => 'ajax_layout'
  end

  def select_school_class
    @student_id = params[:student_id]
    @student_class_assignment = StudentClassAssignment.find_by_id params[:id].to_i
    selected_school_class = SchoolClass.find_by_id params[:selected_class_id]
    @student_class_assignment.school_class = selected_school_class
    @student_class_assignment.save!
    @student_id = @student_class_assignment.student.id
    render :action => :one_student_class_assignment, :layout => 'ajax_layout'
  end

  def select_elective_class
    @student_id = params[:student_id]
    @student_class_assignment = StudentClassAssignment.find_by_id params[:id].to_i
    selected_elective_class = SchoolClass.find_by_id params[:selected_class_id]
    @student_class_assignment.elective_class = selected_elective_class
    @student_class_assignment.save!
    @student_id = @student_class_assignment.student.id
    render :action => :one_student_class_assignment, :layout => 'ajax_layout'
  end

  def add_instructor_assignment
    @instructor_assignment = InstructorAssignment.new
    if request.post?
      person = Person.find_by_id params[:id].to_i
      @instructor_assignment.school_year = SchoolYear.find_by_id params[:instructor_assignment][:school_year].to_i
      @instructor_assignment.school_class = SchoolClass.find_by_id params[:instructor_assignment][:school_class].to_i
      @instructor_assignment.instructor = person
      @instructor_assignment.start_date = find_start_date params[:instructor_assignment][:start_date_string], @instructor_assignment.school_year
      @instructor_assignment.end_date = find_end_date params[:instructor_assignment][:end_date_string], @instructor_assignment.school_year
      @instructor_assignment.role = params[:instructor_assignment][:role]
      if @instructor_assignment.save
        person.user.adjust_instructor_roles if person.user
        flash[:notice] = 'Instructor Assignment added successfully'
        redirect_to :action => :show, :id => @instructor_assignment.instructor
      end
    else
      @instructor_assignment.instructor_id = params[:id]
    end
  end


  private

  def find_start_date(input_string, school_year)
    if input_string.blank?
      school_year.start_date
    else
      parse_date input_string
    end
  end

  def find_end_date(input_string, school_year)
    if input_string.blank?
      school_year.end_date
    else
      parse_date input_string
    end
  end
end
