
def show_that_table_headers_exist_with(headers)
  response.should have_tag('thead') do
    with_tag('tr') do
      with_tag('th', headers.size)
      headers.each {|header| with_tag('th', header) }
    end
  end
end
