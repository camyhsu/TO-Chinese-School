require 'spec_helper'

describe "/registration/families/show" do
  before(:each) do
    @page_title = 'Family'
    render 'registration/families/show'
  end

  it_should_behave_like 'titled page'

  it 'should have a title in h1' do
    response.should have_tag('h1', 1)
    response.should have_tag('h1', @page_title)
  end

  it 'should show family information in a html table' do
    
  end
  
end
