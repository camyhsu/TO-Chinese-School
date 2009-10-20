require 'spec_helper'

describe '/layouts/application.html.erb' do

  before(:each) do
    assigns[:title] = 'test page title'
    render '/layouts/application.html.erb'
  end

  it 'should set the content type' do
    response.should have_tag('meta[http-equiv="content-type"][content="text/html;charset=UTF-8"]', 1)
  end
  it 'should set the page title' do
    response.should have_tag('title', 'test page title')
  end

  it 'should have stylesheet link to scaffold style' do
    response.should have_tag('link[href^="/stylesheets/scaffold.css"][rel="stylesheet"][type="text/css"]', 1)
  end

  it 'should have stylesheet link to layout style' do
    response.should have_tag('link[href^="/stylesheets/layout.css"][rel="stylesheet"][type="text/css"]', 1)
  end

  it 'should have the top bar image' do
    response.should have_tag('div#top-bar') do
      with_tag('img[src^="/images/tocs_logo.png"]', 1)
    end
  end
end