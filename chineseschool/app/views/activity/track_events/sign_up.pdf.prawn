# encoding: utf-8

prawn_document(filename: 'track_and_field_sign_up.pdf', page_layout: :landscape) do |pdf|
  pdf.font "#{Rails.root}/lib/data/fonts/ArialUnicode.ttf"

  unless @young_students.empty?
    data = [ pdf_create_draft_header_for(@young_student_programs) ]
    @young_students.each {|student| data << pdf_create_draft_row_for(student, @young_student_programs)}
    column_widths = pdf_calculate_column_widths_for(@young_student_programs)

    pdf.font_size 9 do
      pdf.table(data, header: true, column_widths: column_widths, cell_style: {align: :center}) do
        row(0).style(background_color: 'cccccc')
      end
    end

    pdf.move_down 30
  end

  unless @teen_students.empty?
      data = [ pdf_create_draft_header_for(@teen_student_programs) ]
      @teen_students.each {|student| data << pdf_create_draft_row_for(student, @teen_student_programs)}
      column_widths = pdf_calculate_column_widths_for(@teen_student_programs)

      pdf.font_size 9 do
          pdf.table(data, header: true, column_widths: column_widths, cell_style: {align: :center}) do
              row(0).style(background_color: 'cccccc')
          end
      end
  end

  pdf.font_size 9 do
    pdf.number_pages "#{SchoolYear.current_school_year.name} School Year", at: [pdf.bounds.left, 0], align: :left, page_filter: :all
    pdf.number_pages "#{@school_class.name} Track and Field Sign Up Draft Form", at: [pdf.bounds.left, 0], align: :right, page_filter: :all
  end
end
