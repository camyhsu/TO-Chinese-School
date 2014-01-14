module Communication::FormsHelper

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
