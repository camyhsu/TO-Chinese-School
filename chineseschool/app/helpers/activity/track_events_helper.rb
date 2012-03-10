module Activity::TrackEventsHelper
  
  def display_selector_based_on_program_type(track_event_program, student_id, school_class_id, existing_signups)
    if track_event_program.program_type == TrackEventProgram::PROGRAM_TYPE_STUDENT_RELAY
      student_relay_program_selector track_event_program.id, student_id, school_class_id, existing_signups
    elsif track_event_program.program_type == TrackEventProgram::PROGRAM_TYPE_STUDENT
      check_box_program_selector track_event_program.id, student_id, school_class_id, existing_signups
    else
      parent_check_box_program_selector track_event_program.id, student_id, school_class_id, existing_signups
    end
  end
  
  def find_color_style(track_event_program)
    return 'style="background-color:red;"' if track_event_program.event_type == TrackEventProgram::EVENT_TYPE_TOCS
    return 'style="background-color:green;"' if track_event_program.event_type == TrackEventProgram::EVENT_TYPE_SOUTHERN_CA
    ''
  end
  
    
  private
  
  def check_box_program_selector(track_event_program_id, student_id, school_class_id, existing_signups)
    current_check_box_value = determine_current_check_box_value track_event_program_id, existing_signups
    select_program_handler = "selectProgram(this, #{student_id}, '#{url_for :action => :select_program, :id => school_class_id}')"
    output = '<td>'
    output << check_box_tag('select', "#{track_event_program_id}", current_check_box_value, {:onchange => select_program_handler})
    output << '</td>'
    output
  end
  
  def student_relay_program_selector(track_event_program_id, student_id, school_class_id, existing_signups)
    current_relay_drop_down_value = determine_current_relay_drop_down_value track_event_program_id, existing_signups
    select_relay_group_handler = "selectRelayGroup(this, #{student_id}, #{track_event_program_id}, '#{url_for :action => :select_relay_group, :id => school_class_id}')"
    output = '<td>'
    output << select('program', 'relay', TrackEventSignup::RELAY_GROUP_CHOICES, {:include_blank => 'Not Participate', :selected => current_relay_drop_down_value }, {:onchange => select_relay_group_handler})
    output << '</td>'
    output
  end
  
  def parent_check_box_program_selector(track_event_program_id, student_id, school_class_id, existing_signups)
    student = Person.find_by_id student_id
    output = '<td class="select-parent">'
    student.find_parents.each do |parent|
      current_parent_check_box_value = determine_current_parent_check_box_value track_event_program_id, parent.id, existing_signups
      select_parent_handler = "selectParent(this, #{student_id}, #{parent.id}, '#{url_for :action => :select_parent, :id => school_class_id}')"
      output << check_box_tag('select', "#{track_event_program_id}", current_parent_check_box_value, {:onchange => select_parent_handler})
      output << "&nbsp;#{parent.name}<br/>"
    end
    output << '</td>'
    output
  end
  
  def determine_current_check_box_value(track_event_program_id, existing_signups)
    existing_signups.any? { |existing_signup| existing_signup.track_event_program.id == track_event_program_id }
  end
  
  def determine_current_relay_drop_down_value(track_event_program_id, existing_signups)
    signup_found = existing_signups.detect { |existing_signup| existing_signup.track_event_program.id == track_event_program_id }
    signup_found.group_name unless signup_found.nil?
  end
  
  def determine_current_parent_check_box_value(track_event_program_id, parent_id, existing_signups)
    existing_signups.any? { |existing_signup| (existing_signup.track_event_program.id == track_event_program_id) and (existing_signup.parent_id == parent_id) }
  end
end
