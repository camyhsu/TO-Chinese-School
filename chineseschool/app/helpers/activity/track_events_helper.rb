module Activity::TrackEventsHelper

  def find_gender_color(track_event_program, participant)
    return '' if track_event_program.mixed_gender?
    return 'background-color:#ADE7FF;' if participant.gender == 'M'
    return 'background-color:#FDC5FF;' if participant.gender == 'F'
    ''
  end

  def find_relay_team_name(signup)
    if signup.nil?
      'Not Participate'
    else
      signup.group_name
    end
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
end
