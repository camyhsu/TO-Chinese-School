require 'spec_helper'

describe '/admin/roles/new' do
#  fixtures :roles

  before(:each) do
    render '/admin/roles/new.html.erb'
  end

  it 'should set the page title variable for layout' do
    assigns[:title].should == 'Create Role'
  end

  it 'should have a form legend' do
    response.should have_tag('legend', 1)
    response.should have_tag('legend', 'Create Role')
  end
  
  it 'should have correct form action' do
    response.should have_tag('form[action="/chineseschool/admin/roles/create"]', 1)
  end

  it 'should have 2 div sections insdie the form' do
    response.should have_tag('form div', 2)
  end

  it 'should have the name field' do
    response.should have_tag('form div') do |divs|
      with_tag(divs[0], 'label', 'Name')
      with_tag(divs[0], 'input#role_name[name^="role[name"][type="text"]', 1)
    end
  end

  it 'should have the submit button' do
    response.should have_tag('form div') do |divs|
      with_tag(divs[1], 'input[value="Save New Role"][type="submit"]', 1)
    end
  end
end
