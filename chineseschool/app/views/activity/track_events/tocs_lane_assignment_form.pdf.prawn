# encoding: utf-8

prawn_document(filename: 'lane_assignment_forms.pdf') do |pdf|
  pdf.font "#{Rails.root}/lib/data/fonts/ArialUnicode.ttf"

  first_page = true
  top_of_page = false
  total_heat_count = @lane_assignment_blocks.size
  heat_counter = 0

  @lane_assignment_blocks.each do |lane_assignment_block|

    if (lane_assignment_block.sample_track_event_program.name.start_with?('Tug') ||
        lane_assignment_block.sample_track_event_program.name.start_with?('8x50'))
      pdf.start_new_page
      top_of_page = false
    elsif top_of_page
      pdf.move_down 120
      top_of_page = false
    else
      pdf.start_new_page unless first_page
      first_page = false
      top_of_page = true
    end

    heat_counter += 1
    heat_marker = "#{heat_counter} of #{total_heat_count}"

    pdf.move_down 20

    pdf.font_size 14 do
      pdf.text "#{lane_assignment_block.sample_track_event_program.sort_key}. #{lane_assignment_block.sample_track_event_program.name}", :align => :left
      pdf.move_up 14
      if lane_assignment_block.gender == Person::GENDER_FEMALE
        if (lane_assignment_block.sample_track_event_program.program_type == TrackEventProgram::PROGRAM_TYPE_PARENT) or
            (lane_assignment_block.sample_track_event_program.program_type == TrackEventProgram::PROGRAM_TYPE_PARENT_RELAY)
          pdf.text "#{heat_marker}   Women", :align => :right
        else
          pdf.text "#{heat_marker}   Girls", :align => :right
        end
      elsif lane_assignment_block.gender == Person::GENDER_MALE
        if (lane_assignment_block.sample_track_event_program.program_type == TrackEventProgram::PROGRAM_TYPE_PARENT) or
            (lane_assignment_block.sample_track_event_program.program_type == TrackEventProgram::PROGRAM_TYPE_PARENT_RELAY)
          pdf.text "#{heat_marker}   Men", :align => :right
        else
          pdf.text "#{heat_marker}   Boys", :align => :right
        end
      else
        pdf.text "#{heat_marker}", :align => :right
      end
    end

    pdf.move_down 20

    data = lane_assignment_block.create_lane_block_data_for_pdf
    pdf.font_size 8 do
      pdf.table(data, :header => true, :width => 553) do |t|
        t.cells.style :width => 79, :height => 24, :align => :center
        t.row(0).style(:background_color => 'cccccc')
      end
    end
  end

  pdf.font_size 7 do
    pdf.number_pages "Page <page> of <total>", :at => [pdf.bounds.left, 0], :align => :right, :page_filter => :all
  end
end








