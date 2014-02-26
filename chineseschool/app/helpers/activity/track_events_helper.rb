module Activity::TrackEventsHelper

  def determine_current_parent_check_box_value(parent_id, existing_signups)
    existing_signups.any? { |existing_signup| existing_signup.parent_id == parent_id }
  end

  def determine_current_relay_drop_down_value(track_event_program_id, existing_signups)
    signup_found = existing_signups.detect { |existing_signup| existing_signup.track_event_program.id == track_event_program_id }
    signup_found.group_name unless signup_found.nil?
  end

  def find_gender_color(track_event_program, participant)
    return '' if track_event_program.mixed_gender?
    return 'background-color:#ADE7FF;' if participant.gender == 'M'
    return 'background-color:#FDC5FF;' if participant.gender == 'F'
    ''
  end

  def pdf_create_draft_header_for(track_event_programs)
    header = ['Student Name', 'Gender', 'Birth Month']
    track_event_programs.each do |track_event_program|
      header << track_event_program.name
    end
    header
  end

  def pdf_create_draft_row_for(student, track_event_programs)
    row = []
    row << student.name
    row << student.gender
    row << student.birth_info
    track_event_programs.size.times { row << '' }
    row
  end

  def pdf_calculate_column_widths_for(track_event_programs)
    column_widths = [100, 50, 50]
    program_width = (720 - 100 - 50 - 50) / track_event_programs.size
    track_event_programs.size.times { column_widths << program_width }
    column_widths
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
