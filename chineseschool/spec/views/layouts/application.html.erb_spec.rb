require 'spec_helper'

describe '/layouts/application' do
  before(:each) do
    stub_find_user_in_session_for_view
  end
  
  it 'should set the content type' do
    render '/layouts/application.html.erb'
    response.should have_tag('meta[http-equiv="content-type"][content="text/html;charset=UTF-8"]', 1)
  end
  
  it 'should set the page title' do
    fake_page_title = random_string 10
    assigns[:title] = fake_page_title
    render '/layouts/application.html.erb'
    response.should have_tag('title', fake_page_title)
  end

  it 'should have stylesheet link to layout style' do
    render '/layouts/application.html.erb'
    response.should have_tag('link[href^="/stylesheets/layout.css"][rel="stylesheet"][type="text/css"]', 1)
  end

  it 'should have stylesheet link to jquery-ui style' do
    render '/layouts/application.html.erb'
    response.should have_tag('link[href^="/stylesheets/pepper-grinder/jquery-ui-1.8.13.custom.css"][rel="stylesheet"][type="text/css"]', 1)
  end

  it 'should have the top bar image' do
    render '/layouts/application.html.erb'
    response.should have_tag('div#top-bar') do
      with_tag('img[src^="/images/tocs_logo.png"]', 1)
    end
  end
  
  it 'should have flash notice' do
    fake_flash_notice = random_string 15
    flash[:notice] = fake_flash_notice
    render '/layouts/application.html.erb'
    response.should have_tag('p#flash-notice', fake_flash_notice)
  end
end