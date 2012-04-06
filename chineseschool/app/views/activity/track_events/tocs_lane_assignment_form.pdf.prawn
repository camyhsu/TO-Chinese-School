# encoding: utf-8

pdf.font "#{RAILS_ROOT}/lib/data/fonts/ArialUnicode.ttf"

top_of_page = true

@lane_assignment_blocks.each do |lane_assignment_block|
  
  pdf.font_size 12 do
    pdf.text lane_assignment_block.sample_track_event_program.name, :align => :left
    if lane_assignment_block.gender == Person::GENDER_FEMALE
      pdf.move_up 12
      if (lane_assignment_block.sample_track_event_program.program_type == TrackEventProgram::PROGRAM_TYPE_PARENT) or 
          (lane_assignment_block.sample_track_event_program.program_type == TrackEventProgram::PROGRAM_TYPE_PARENT_RELAY)
        pdf.text 'Women', :align => :center
      else
        pdf.text 'Girls', :align => :center
      end
    elsif lane_assignment_block.gender == Person::GENDER_MALE
      pdf.move_up 12
      if (lane_assignment_block.sample_track_event_program.program_type == TrackEventProgram::PROGRAM_TYPE_PARENT) or 
          (lane_assignment_block.sample_track_event_program.program_type == TrackEventProgram::PROGRAM_TYPE_PARENT_RELAY)
        pdf.text 'Men', :align => :center
      else
        pdf.text 'Boys', :align => :center
      end
    end
  end
  
  pdf.move_down 20
  
  data = lane_assignment_block.create_lane_block_data_for_pdf
  pdf.font_size 9 do
    pdf.table(data, :header => true, :width => 553) do |t|
      t.cells.style :width => 79, :height => 24, :align => :center
      t.row(0).style(:background_color => 'cccccc')
    end
  end
  
  if lane_assignment_block.sample_track_event_program.name.start_with? 'Tug'
    pdf.start_new_page
    top_of_page = true
  elsif top_of_page
    pdf.move_down 50
    top_of_page = false
  else
    pdf.start_new_page
    top_of_page = true
  end
end
