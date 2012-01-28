module Student::RegistrationHelper
  
  def display_available_school_class_type_options(student_id, registration_preference)
    available_school_class_types = registration_preference.grade.find_available_school_class_types(registration_preference.school_year)
    if available_school_class_types.empty?
      ''
    elsif available_school_class_types.size == 1
      # Show the only choice as text instead of a dropdown
      school_class_type = available_school_class_types[0]
      if school_class_type == SchoolClass::SCHOOL_CLASS_TYPE_MIXED
        # Don't show the mixed type if it is the only type available
        output_html = ''
      else
        output_html = display_string_for school_class_type
      end
      output_html += hidden_field_tag "#{student_id}_school_class_type", available_school_class_types[0]
      output_html
    else
      options = []
      available_school_class_types.each do |school_class_type|
        options << [display_string_for(school_class_type), school_class_type]
      end
      select "#{student_id}_school_class_type", :school_class_type, options
    end
  end
  
  def display_string_for(school_class_type)
    return 'S(簡)' if school_class_type == SchoolClass::SCHOOL_CLASS_TYPE_SIMPLIFIED
    return 'T(繁)' if school_class_type == SchoolClass::SCHOOL_CLASS_TYPE_TRADITIONAL
    return 'SE(雙語)' if school_class_type == SchoolClass::SCHOOL_CLASS_TYPE_ENGLISH_INSTRUCTION
    school_class_type
  end
end
