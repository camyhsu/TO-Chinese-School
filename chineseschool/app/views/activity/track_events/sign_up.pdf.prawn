# encoding: utf-8

prawn_document(filename: 'track_and_field_sign_up.pdf', page_layout: :landscape) do |pdf|
  pdf.font "#{Rails.root}/lib/data/fonts/ArialUnicode.ttf"

  data = [ pdf_create_draft_header_for(@track_event_programs) ]
  @regular_students.each {|student| data << pdf_create_draft_row_for(student, @track_event_programs)}
  @older_students.each {|student| data << pdf_create_draft_row_for(student, @track_event_programs)}

  column_widths = pdf_calculate_column_widths_for(@track_event_programs)
  regular_student_count = @regular_students.size
  student_program_count = @track_event_programs.count {|program| (program.program_type == TrackEventProgram::PROGRAM_TYPE_STUDENT) || (program.program_type == TrackEventProgram::PROGRAM_TYPE_STUDENT_RELAY)}
  pdf.font_size 9 do
    pdf.table(data, header: true, column_widths: column_widths, cell_style: {align: :center}) do
      row(0).style(background_color: 'cccccc')

      # Black out cell for individual student programs for older students
      cells.style do |cell|
        if (cell.row > regular_student_count) && (cell.column > 2) && (cell.column < 3 + student_program_count)
          cell.background_color = '000000'
        end
      end
    end
  end

  unless @older_students.empty?
    pdf.move_down 30
    pdf.font_size 14 do
      pdf.text 'Student older than regular school age'
    end

    @older_students.each do |student|
      pdf.move_down 14
      track_event_programs = TrackEventProgram.find_by_school_age_for student

      data = [ pdf_create_draft_header_for(track_event_programs) ]
      data << pdf_create_draft_row_for(student, track_event_programs)

      column_widths = pdf_calculate_column_widths_for(track_event_programs)
      pdf.font_size 9 do
        pdf.table(data, header:true, column_widths: column_widths, cell_style: {align: :center}) do
          row(0).style(background_color: 'cccccc')
        end
      end
    end
  end

  pdf.font_size 9 do
    pdf.number_pages "#{SchoolYear.current_school_year.name} School Year", at: [pdf.bounds.left, 0], align: :left, page_filter: :all
    pdf.number_pages "#{@school_class.name} Track and Field Sign Up Draft Form", at: [pdf.bounds.left, 0], align: :right, page_filter: :all
  end
end
