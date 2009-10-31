require 'spec_helper'

shared_examples_for 'titled page' do
  it 'should set the page title variable for layout' do
    assigns[:title].should == @page_title
  end
end