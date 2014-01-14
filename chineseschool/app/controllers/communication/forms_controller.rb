class Communication::FormsController < ApplicationController

  def picture_taking_form
    @current_school_year = SchoolYear.current_school_year
    retrieve_sorted_class_lists
    respond_to do |format|
      format.pdf {render layout: false}
    end
  end

  def student_list_for_yearbook
    retrieve_sorted_class_lists
    respond_to do |format|
      format.csv {send_data student_list_for_yearbook_csv}
    end
  end

  private

  def student_list_for_yearbook_csv
    CSV.generate do |csv|
      csv << ['Class', 'First Name', 'Last Name', 'Chinese Name', 'Gender']
      @sorted_school_classes.each do |school_class|
        @class_lists[school_class].each_with_index do |student, i|
          row = []
          row << school_class.short_name
          row << student.english_first_name
          row << student.english_last_name
          row << student.chinese_name
          row << student.gender
          csv << row
        end
      end
    end
  end
end
