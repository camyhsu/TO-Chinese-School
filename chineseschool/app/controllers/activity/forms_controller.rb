class Activity::FormsController < ApplicationController
  
  def fire_drill_form
    @current_school_year = SchoolYear.current_school_year
    retrieve_sorted_class_lists
    prawnto :filename => 'fire_drill_roster_forms.pdf'
    render :layout => false
  end
  
  def students_by_class
    retrieve_sorted_class_lists
    headers["Content-Type"] = 'text/csv'
    headers["Content-Disposition"] = 'attachment; filename="students_by_class.csv"'
    render :layout => false
  end
  
  private
  
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
