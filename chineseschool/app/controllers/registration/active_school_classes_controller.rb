class Registration::ActiveSchoolClassesController < ApplicationController
  
  def index
    @school_year = SchoolYear.find params[:id].to_i
    @active_school_classes = SchoolClass.find_all_active_school_classes(@school_year)
    render layout: 'jquery_datatable'
  end

  def grade_class_student_count
    @school_year = SchoolYear.find params[:id].to_i
    @active_grade_classes = SchoolClass.find_all_active_grade_classes(@school_year)
    @active_grade_classes.sort! do |x, y|
      grade_order = x.grade_id <=> y.grade_id
      if grade_order == 0
        x.short_name <=> y.short_name
      else
        grade_order
      end
    end
  end
  
  def elective_class_student_count
    @school_year = SchoolYear.find params[:id].to_i
    @active_elective_classes = SchoolClass.find_all_active_elective_classes(@school_year)
    @active_elective_classes.sort! { |x, y| x.english_name <=> y.english_name }
  end

  def grade_student_count
    @school_year = SchoolYear.find params[:id].to_i
    @grade_student_counts = StudentClassAssignment.where('school_year_id = ? AND grade_id IS NOT NULL', @school_year.id).group('grade_id').count
    puts @grade_student_counts.inspect
  end
end
