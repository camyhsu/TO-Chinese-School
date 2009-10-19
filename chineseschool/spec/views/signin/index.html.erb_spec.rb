require 'spec_helper'

describe '/signin/index.html.erb' do

  before(:each) do
    render '/signin/index.html.erb'
  end

  it 'should have a form legend' do
    response.should have_tag('legend', 1)
    response.should have_tag('legend', 'Please Sign In')
  end
  
  it 'should have 3 div sections' do
    response.should have_tag('form div', 3)
  end

  it 'should have the username field' do
    response.should have_tag('form div') do |divs|
      with_tag(divs[0], 'label', 'Username:')
      with_tag(divs[0], 'input#username[name="username"][type="text"]', 1)
    end
  end

  it 'should have the password field' do
    response.should have_tag('form div') do |divs|
      with_tag(divs[1], 'label', 'Password:')
      with_tag(divs[1], 'input#password[name="password"][type="password"]', 1)
    end
  end

  it 'should have the submit button' do
    response.should have_tag('form div') do |divs|
      with_tag(divs[2], 'input[value="Sign In"][type="submit"]', 1)
    end
  end
end
