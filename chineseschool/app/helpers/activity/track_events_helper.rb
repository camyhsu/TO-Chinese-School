module Activity::TrackEventsHelper
  
  def display_selector_based_on_program_type(track_event_program, student_id, school_class_id, existing_signups)
    if track_event_program.program_type == TrackEventProgram::PROGRAM_TYPE_STUDENT_RELAY
      # change to drop down
      check_box_program_selector track_event_program.id, student_id, school_class_id, existing_signups
    else
      check_box_program_selector track_event_program.id, student_id, school_class_id, existing_signups
    end
  end
  
  def check_box_program_selector(track_event_program_id, student_id, school_class_id, existing_signups)
    current_check_box_value = determine_current_check_box_value track_event_program_id, existing_signups
    select_program_handler = "selectProgram(this, #{student_id}, '#{url_for :action => :select_program, :id => school_class_id}')"
    output = '<td>'
    output << check_box_tag('select', "#{track_event_program_id}", current_check_box_value, {:onchange => select_program_handler})
    output << '</td>'
    output
  end
  
  
  private
  
  def determine_current_check_box_value(track_event_program_id, existing_signups)
    existing_signups.any? { |existing_signup| existing_signup.track_event_program.id == track_event_program_id }
  end
end
