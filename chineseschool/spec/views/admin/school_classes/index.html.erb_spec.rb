require 'spec_helper'

describe "/admin/school_classes/index" do
  fixtures :school_classes

  include ApplicationHelper
  
  before(:each) do
    @page_title = 'All School Classes'
    assigns[:school_classes] = [ school_classes(:first_grade), school_classes(:chinese_history_one) ]
    render '/admin/school_classes/index.html.erb'
  end

  it_should_behave_like 'titled page'

  it 'should have column headers in html table' do
    headers = []
    headers << ''
    headers << 'English Name'
    headers << 'Chinese Name'
    headers << 'Short Name'
    headers << 'Description'
    headers << 'Location'
    headers << 'Maximum Size'
    headers << 'Minimum Age'
    headers << 'Maximum Age'
    headers << 'Grade'
    headers << 'Active?'
    headers << ''
    show_that_table_headers_exist_with headers
  end

  it 'should list all school classes in an html table' do
    response.should have_tag('tbody') do
      with_tag('tr', 2)
      with_tag('tr') do |tr_elements|
        show_that_tr_contains_tds_for_school_class tr_elements[0], :first_grade
        show_that_tr_contains_tds_for_school_class tr_elements[1], :chinese_history_one
      end
    end
  end

  def show_that_tr_contains_tds_for_school_class(tr_element, school_class)
    with_tag(tr_element, 'td') do
      with_tag('td', school_classes(school_class).english_name)
      with_tag('td', school_classes(school_class).chinese_name)
      with_tag('td', school_classes(school_class).short_name)
      with_tag('td', school_classes(school_class).description)
      with_tag('td', school_classes(school_class).location)
      with_tag('td', school_classes(school_class).max_size.to_s)
      with_tag('td', school_classes(school_class).min_age.to_s)
      with_tag('td', school_classes(school_class).max_age.to_s)
      with_tag('td', grade_display_name(school_classes(school_class).grade))
      with_tag('td', convert_to_yes_no(school_classes(school_class).active))
    end
  end

  def grade_display_name(grade)
    return grade.english_name if grade
    ''
  end
end
