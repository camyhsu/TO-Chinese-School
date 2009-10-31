require 'spec_helper'

shared_examples_for 'input form' do
  it 'should have a form legend' do
    response.should have_tag('legend', 1)
    response.should have_tag('legend', @form_legend)
  end

  it 'should have correct form action' do
    response.should have_tag("form[action='#{@form_action_url}']", 1)
  end

  it 'should have the submit button' do
    response.should have_tag('form div') do |divs|
      with_tag(divs[-1], "input[value='#{@submit_button_label}'][type='submit']", 1)
    end
  end
end
