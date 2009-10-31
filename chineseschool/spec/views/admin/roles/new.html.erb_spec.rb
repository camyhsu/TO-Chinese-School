require 'spec_helper'

describe '/admin/roles/new' do
#  fixtures :roles

  before(:each) do
    @page_title = 'Create Role'
    @form_legend = 'Create Role'
    @form_action_url = '/chineseschool/admin/roles/create'
    @submit_button_label = 'Save New Role'
    render '/admin/roles/new.html.erb'
  end

  it_should_behave_like 'titled page'
  it_should_behave_like 'input form'
  
  it 'should have 2 div sections insdie the form' do
    response.should have_tag('form div', 2)
  end

  it 'should have the name field' do
    response.should have_tag('form div') do |divs|
      with_tag(divs[0], 'label', 'Name')
      with_tag(divs[0], 'input#role_name[name^="role[name"][type="text"]', 1)
    end
  end
end
