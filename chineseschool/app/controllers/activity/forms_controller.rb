class Activity::FormsController < ApplicationController
  
  def fire_drill_form
    @current_school_year = SchoolYear.current_school_year
    active_student_class_assignments = StudentClassAssignment.all(:conditions => ['school_class_id is not null AND school_year_id = ?', @current_school_year.id])
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
    prawnto :filename => 'fire_drill_roster_forms.pdf'
    render :layout => false
  end
  
end
