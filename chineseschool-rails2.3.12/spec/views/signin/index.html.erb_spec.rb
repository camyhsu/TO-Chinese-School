require 'spec_helper'

describe '/signin/index' do

  before(:each) do
    @page_title = 'Sign In'
    @form_legend = 'Please Sign In'
    @form_action_url = '/chineseschool/signin'
    @submit_button_label = 'Sign In'
    render '/signin/index.html.erb'
  end

  it_should_behave_like 'titled page'
  it_should_behave_like 'input form'
  
  it 'should have 3 div sections insdie the form' do
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
end
