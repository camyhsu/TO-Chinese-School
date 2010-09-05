require 'spec_helper'

describe "/admin/rights/index" do
  fixtures :rights

  before(:each) do
    @page_title = 'Rights'
    assigns[:rights] = [ rights(:list_grades), rights(:create_role) ]
    render '/admin/rights/index.html.erb'
  end

  it_should_behave_like 'titled page'

  it 'should have column headers in html table' do
    headers = []
    headers << 'Right Name'
    headers << 'Controller Path'
    headers << 'Action Name'
    show_that_table_headers_exist_with headers
  end

  it 'should list all roles in an html table' do
    response.should have_tag('tbody') do
      with_tag('tr', 2)
      with_tag('tr') do |tr_elements|
        show_that_tr_contains_tds_for_right tr_elements[0], :list_grades
        show_that_tr_contains_tds_for_right tr_elements[1], :create_role
      end
    end
  end
  
  def show_that_tr_contains_tds_for_right(tr_element, right)
    with_tag(tr_element, 'td') do
      with_tag('td', rights(right).name)
      with_tag('td', rights(right).controller)
      with_tag('td', rights(right).action)
    end
  end
end
