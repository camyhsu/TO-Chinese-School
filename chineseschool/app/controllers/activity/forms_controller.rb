class Activity::FormsController < ApplicationController
  
  def fire_drill_form
    @current_school_year = SchoolYear.current_school_year
    retrieve_sorted_class_lists
    respond_to do |format|
      format.pdf {render layout: false}
    end
  end
  
  def students_by_class
    retrieve_sorted_class_lists
    respond_to do |format|
      format.csv {send_data students_by_class_csv, type: 'text/csv'}
    end
  end
  
  def grade_class_information
    @active_classes = SchoolClass.find_all_active_grade_classes
    @active_classes.sort! { |x, y| x.grade_id <=> y.grade_id }
    respond_to do |format|
      format.csv {send_data class_info_csv, type: 'text/csv'}
    end
  end
  
  def elective_class_information
    @active_classes = SchoolClass.find_all_active_elective_classes
    @active_classes.sort! { |x, y| x.english_name <=> y.english_name }
    respond_to do |format|
      format.csv {send_data class_info_csv, type: 'text/csv'}
    end
  end

  private

  def students_by_class_csv
    CSV.generate do |csv|
      csv << ['Class Short Name', 'English First Name', 'English Last Name', 'Chinese Name', 'Parent One', 'Parent Two', 'Family Email', 'Family Home Phone']
      @sorted_school_classes.each do |school_class|
        @class_lists[school_class].each_with_index do |student, i|
          row = []
          row << school_class.short_name
          row << student.english_first_name
          row << student.english_last_name
          row << student.chinese_name
          append_family_fields row, student
          csv << row
        end
      end
    end
  end

  def append_family_fields(row, student)
    families_as_child = student.find_families_as_child
    return append_family_fields_without_parent(row, student) if families_as_child.empty?

    append_parent_fields row, families_as_child[0]
    append_email_phone_fields row, families_as_child[0]
  end

  def append_family_fields_without_parent(row, student)
    # this could happen if the student is a parent - we still want to show email
    # and home phone even though parents are empty fields
    row << ''
    row << ''
    families_as_parent = student.find_families_as_parent
    if families_as_parent.empty?
      # no address information at all
      row << ''
      row << ''
    else
      append_email_phone_fields row, families_as_parent[0]
    end
  end

  def append_email_phone_fields(row, family)
    append_field row, family.address.email
    append_field row, family.address.home_phone
  end

  def append_parent_fields(row, family)
    append_field row, family.parent_one.try(:name)
    append_field row, family.parent_two.try(:name)
  end

  def append_field(row, field)
    if field.nil?
      row << ''
    else
      row << field
    end
  end

  def class_info_csv
    CSV.generate do |csv|
      csv << ['Chinese Name', 'English Name', 'Location', 'Student Count', 'Primary Instructor', 'Room Parent', 'Secondary Instructor', 'Teaching Assistant']
      @active_classes.each do |school_class|
        row = []
        row << school_class.chinese_name
        row << school_class.english_name
        row << school_class.location
        row << school_class.class_size
        assignment_hash = school_class.instructor_assignments
        row << assignment_hash[InstructorAssignment::ROLE_PRIMARY_INSTRUCTOR].collect { |instructor| instructor.name }.join(';')
        row << school_class.room_parent_name
        row << assignment_hash[InstructorAssignment::ROLE_SECONDARY_INSTRUCTOR].collect { |instructor| instructor.name }.join(';')
        row << assignment_hash[InstructorAssignment::ROLE_TEACHING_ASSISTANT].collect { |instructor| instructor.name }.join(';')
        csv << row
      end
    end
  end
end
