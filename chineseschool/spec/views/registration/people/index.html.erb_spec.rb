require 'spec_helper'

describe "/registration/people/index" do
  fixtures :people

  before(:each) do
    @page_title = 'People'
    assigns[:people] = [ people(:person_one), people(:person_two) ]
    render '/registration/people/index.html.erb'
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
    headers << 'Gender'
    headers << 'Birth Year'
    headers << 'Birth Month'
    headers << 'Native Language'
    show_that_table_headers_exist_with headers
  end

  it 'should list all people in an html table' do
    response.should have_tag('tbody') do
      with_tag('tr', 2)
      with_tag('tr') do |tr_elements|
        show_that_tr_contains_tds_for_person tr_elements[0], :person_one
        show_that_tr_contains_tds_for_person tr_elements[1], :person_two
      end
    end
  end

  def show_that_tr_contains_tds_for_person(tr_element, person)
    with_tag(tr_element, 'td') do
      with_tag('td', people(person).chinese_name)
      with_tag('td', people(person).english_first_name + ' ' + people(person).english_last_name)
      with_tag('td', people(person).gender)
      with_tag('td', people(person).birth_year.to_s)
      with_tag('td', people(person).birth_month.to_s)
      with_tag('td', people(person).native_language)
    end
  end
end
