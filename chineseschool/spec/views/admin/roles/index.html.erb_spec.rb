require 'spec_helper'

describe '/admin/roles/index' do
  fixtures :roles

  before(:each) do
    @page_title = 'Roles'
    assigns[:roles] = [ roles(:super_user), roles(:instructor) ]
    render '/admin/roles/index.html.erb'
  end

  it_should_behave_like 'titled page'

  it 'should have a title in h1' do
    response.should have_tag('h1', 1)
    response.should have_tag('h1', @page_title)
  end

  it 'should have column headers in html table' do
    response.should have_tag('thead') do
      with_tag('tr') do
        with_tag('th', 1)
        with_tag('th', 'Role Name')
      end
    end
  end

  it 'should list all roles in an html table' do
    response.should have_tag('tbody') do
      with_tag('tr', 2)
      with_tag('tr') do |tr_elements|
        show_that_tr_contains_tds_for_grade tr_elements[0], :super_user
        show_that_tr_contains_tds_for_grade tr_elements[1], :instructor
      end
    end
  end

  it 'should have a create role link' do
    response.should have_tag('a[href="/chineseschool/admin/roles/new"]', 'Create Role')
  end

  def show_that_tr_contains_tds_for_grade(tr_element, role)
    with_tag(tr_element, 'td') do
      with_tag('td', roles(role).name)
    end
  end
end
