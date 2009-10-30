require 'spec_helper'

describe '/admin/roles/new' do
#  fixtures :roles

  before(:each) do
    render '/admin/roles/new.html.erb'
  end

  it 'should set the page title variable for layout' do
    assigns[:title].should == 'Create Role'
  end

  it 'should have a title in h1' do
    response.should have_tag('h1', 1)
    response.should have_tag('h1', 'Create Role')
  end

  it 'should have correct form action' do
    response.should have_tag('form[action="/chineseschool/admin/roles/create"]', 1)
  end

  it 'should have the name field' do
    response.should have_tag('form p') do |ps|
      with_tag(ps[0], 'label', 'Name')
      with_tag(ps[0], 'input#role_name[name^="role[name"][type="text"]', 1)
    end
  end

  it 'should have the submit button' do
    response.should have_tag('form div') do |divs|
      with_tag(divs[0], 'input[value="Create Role"][type="submit"]', 1)
    end
  end
end
