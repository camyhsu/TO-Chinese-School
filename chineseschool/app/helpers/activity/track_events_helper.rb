module Activity::TrackEventsHelper

  def determine_current_parent_check_box_value(parent_id, existing_signups)
    existing_signups.any? { |existing_signup| existing_signup.parent_id == parent_id }
  end

  def determine_current_relay_drop_down_value(track_event_program_id, existing_signups)
    signup_found = existing_signups.detect { |existing_signup| existing_signup.track_event_program.id == track_event_program_id }
    signup_found.group_name unless signup_found.nil?
  end

  
  def find_color_style(track_event_program)
    return 'background-color:#7FFFD4;' if track_event_program.event_type == TrackEventProgram::EVENT_TYPE_TOCS
    return 'background-color:#B0E0E6;' if track_event_program.event_type == TrackEventProgram::EVENT_TYPE_SOUTHERN_CA
    ''
  end
  
  def display_sign_up_result_based_on_program_type(track_event_program, student_id, school_class_id, existing_signups)
    output = ''
    if track_event_program.program_type == TrackEventProgram::PROGRAM_TYPE_STUDENT_RELAY
      output << '<td>'
      current_relay_drop_down_value = determine_current_relay_drop_down_value track_event_program.id, existing_signups
      unless current_relay_drop_down_value.nil?
        output << current_relay_drop_down_value
      end
    elsif track_event_program.program_type == TrackEventProgram::PROGRAM_TYPE_STUDENT
      if determine_current_check_box_value(track_event_program.id, existing_signups)
        output << '<td style="background-color:#0033FF;">'
        output << '<input type="checkbox" checked="true" disabled="true">'
      else
        output << '<td>'
      end
    else
      output << '<td>'
      student = Person.find_by_id student_id
      student.find_parents.each do |parent|
        if determine_current_parent_check_box_value(track_event_program.id, parent.id, existing_signups)
          output << "#{parent.name}<br/>"
        end
      end
    end
    output << '</td>'
    output
  end

  def determine_current_check_box_value(track_event_program_id, existing_signups)
    existing_signups.any? { |existing_signup| existing_signup.track_event_program.id == track_event_program_id }
  end
end
