class Librarian::SearchStudentsController < ApplicationController

  def index
    @school_year = SchoolYear.current_school_year
    @default_end_date = PacificDate.today
    @default_start_date = @default_end_date - 6
  end

  def search_result
    @school_year = SchoolYear.find params[:id]
    @start_date = Date.parse params[:start_date]
    @end_date = Date.parse params[:end_date]
    @output_records = []
    StudentStatusFlag.find_registration_in_date_range(@start_date, @end_date).each do |status_flag|
      output_record = {}
      output_record[:registration_date] = status_flag.last_status_change_date
      output_record[:student] = status_flag.student
      class_assignment = status_flag.student.student_class_assignment_for(SchoolYear.current_school_year)
      unless class_assignment.nil?
        output_record[:grade] = class_assignment.grade
        output_record[:school_class] = class_assignment.school_class
      end
      @output_records << output_record
    end

    @output_records.sort! do |a, b|
      grade_order = a[:grade].id <=> b[:grade].id
      if grade_order == 0
        school_class_order = 0
        if a[:school_class].nil?
          if b[:school_class].nil?
            # both nil, order is 0
          else
            # a nil but b not, b in front
            school_class_order = 1
          end
        else
          if b[:school_class].nil?
            # a not nil but b is, a in front
            school_class_order = -1
          else
            # both not nil, use short_name order
            school_class_order = a[:school_class].short_name <=> b[:school_class].short_name
          end
        end
        if school_class_order == 0
          registration_date_order = a[:registration_date] <=> b[:registration_date]
          if registration_date_order == 0
            a[:student].english_last_name <=> b[:student].english_last_name
          else
            registration_date_order
          end
        else
          school_class_order
        end
      else
        grade_order
      end
    end

    respond_to do |format|
      format.html {}
      format.pdf {render layout: false}
    end
  end
end
