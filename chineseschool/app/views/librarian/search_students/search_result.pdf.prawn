# encoding: utf-8

prawn_document(filename: 'students_by_registration_date.pdf') do |pdf|
  pdf.font "#{Rails.root}/lib/data/fonts/ArialUnicode.ttf"

  header = [ 'Grade', 'Class', 'Registration Date', 'Student Name' ]

  data = [ header ]
  @output_records.each do |output_record|
    row = []
    row << output_record[:grade].name
    row << output_record[:school_class].try(:name)
    row << output_record[:registration_date]
    row << output_record[:student].name
    data << row
  end

  pdf.table(data, header: true) do
    row(0).style(background_color: 'cccccc')
  end

  pdf.number_pages "Student By Registration Date Search Result: From #{@start_date} To #{@end_date}",
                   at: [pdf.bounds.left, 0], align: :left, page_filter: :all
  pdf.number_pages 'Page <page>/<total>',
                   at: [pdf.bounds.left, 0], align: :right, page_filter: :all
end
