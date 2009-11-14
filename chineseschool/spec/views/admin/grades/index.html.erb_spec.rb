require 'spec_helper'

describe '/admin/grades/index' do
  fixtures :grades
  
  before(:each) do
    @page_title = 'Grades'
    assigns[:grades] = [ grades(:first_grade), grades(:second_grade) ]
    render '/admin/grades/index.html.erb'
  end

  it_should_behave_like 'titled page'

  it 'should have a title in h1' do
    response.should have_tag('h1', 1)
    response.should have_tag('h1', @page_title)
  end

  it 'should have column headers in html table' do
    headers = []
    headers << 'Chinese Name'
    headers << 'English Name'
    headers << 'Short Name'
    show_that_table_headers_exist_with headers
  end

  it 'should list all grades in an html table' do
    response.should have_tag('tbody') do
      with_tag('tr', 2)
      with_tag('tr') do |tr_elements|
        show_that_tr_contains_tds_for_grade tr_elements[0], :first_grade
        show_that_tr_contains_tds_for_grade tr_elements[1], :second_grade
      end
    end
  end
  
  def show_that_tr_contains_tds_for_grade(tr_element, grade)
    with_tag(tr_element, 'td') do
      with_tag('td', grades(grade).chinese_name)
      with_tag('td', grades(grade).english_name)
      with_tag('td', grades(grade).short_name)
    end
  end
end
